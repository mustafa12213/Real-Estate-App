import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/unit_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    String baseUrl = 'http://dealer.marwan-gaber.com/api',
    http.Client? client,
  })  : baseUrl = baseUrl,
        _client = client ?? http.Client();

  Future<UserModel> login(String phone, String password) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));
      return _handleLoginResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e is TimeoutException) {
        throw ApiException('Connection timeout. Please check your internet.');
      }
      if (e is SocketException) {
        throw ApiException('No internet connection.');
      }
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  UserModel _handleLoginResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final body = jsonDecode(response.body);
        final user = UserModel.fromApiResponse(body);
        if (user.token != null && user.token!.isNotEmpty) {
          return user;
        }
        throw ApiException(
          body['error']?.toString() ?? 'Invalid response from server',
        );
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          'Failed to parse server response. Please try again.',
        );
      }
    } else if (response.statusCode == 401) {
      try {
        final body = jsonDecode(response.body);
        final error = body['error'];
        if (error is Map) {
          final messages = error.values.map((v) => v.join(', ')).join('; ');
          throw ApiException(messages.isNotEmpty ? messages : 'Invalid credentials');
        }
        throw ApiException(error?.toString() ?? 'Invalid credentials');
      } catch (_) {
        throw ApiException('Invalid phone or password');
      }
    } else {
      throw ApiException('Server error (HTTP ${response.statusCode})');
    }
  }

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String fullName,
    required String email,
    required String phone,
    required String governce,
    required int age,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'full_name': fullName,
              'email': email,
              'phone': phone,
              'governce': governce,
              'age': age,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));
      return _handleRegisterResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e is TimeoutException) {
        throw ApiException('Connection timeout. Please check your internet.');
      }
      if (e is SocketException) {
        throw ApiException('No internet connection.');
      }
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  UserModel _handleRegisterResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final body = jsonDecode(response.body);
        final user = UserModel.fromApiResponse(body);
        if (user.token != null && user.token!.isNotEmpty) {
          return user;
        }
        throw ApiException(
          body['message']?.toString() ?? 'Registration succeeded but no token received',
        );
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException(
          'Failed to parse server response. Please try again.',
        );
      }
    } else {
      try {
        final body = jsonDecode(response.body);
        final error = body['error'];
        if (error is Map) {
          final messages = <String>[];
          error.forEach((key, value) {
            if (value is List) {
              messages.addAll(value.map((v) => '$key: $v').toList());
            } else {
              messages.add('$key: $value');
            }
          });
          throw ApiException(messages.join('; '));
        }
        throw ApiException(
          error?.toString() ?? 'Registration failed (HTTP ${response.statusCode})',
        );
      } catch (_) {
        throw ApiException(
          'Registration failed (HTTP ${response.statusCode})',
        );
      }
    }
  }

  Future<UnitsResponse> getUnits(String token) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/user/units'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));
      return _handleUnitsResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      if (e is TimeoutException) {
        throw ApiException('Connection timeout. Please check your internet.');
      }
      if (e is SocketException) {
        throw ApiException('No internet connection.');
      }
      throw ApiException('An unexpected error occurred: ${e.toString()}');
    }
  }

  UnitsResponse _handleUnitsResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final body = jsonDecode(response.body);
        return UnitsResponse.fromJson(body);
      } on FormatException {
        throw ApiException('Your session has expired. Please log in again.');
      } catch (e) {
        throw ApiException(
          'Failed to parse units data. Please try again.',
        );
      }
    } else if (response.statusCode == 401) {
      throw ApiException('Your session has expired. Please log in again.');
    } else if (response.statusCode == 403) {
      throw ApiException('Access denied. Please log in again.');
    } else {
      throw ApiException('Failed to load units (HTTP ${response.statusCode})');
    }
  }

  void dispose() {
    _client.close();
  }
}
