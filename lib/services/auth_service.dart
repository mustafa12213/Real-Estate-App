import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/unit_model.dart';
import 'api_service.dart';
import 'token_storage.dart';

class AuthService {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;
  UserModel? _currentUser;

  AuthService({
    required ApiService apiService,
    required TokenStorage tokenStorage,
  })  : _apiService = apiService,
        _tokenStorage = tokenStorage;

  bool isLoggedIn() => _tokenStorage.isLoggedIn();

  String? getToken() => _tokenStorage.getToken();

  UserModel? get currentUser => _currentUser;

  Future<UserModel> login(String phone, String password) async {
    final user = await _apiService.login(phone, password);
    await _tokenStorage.saveToken(user.token!);
    _currentUser = user;
    await _tokenStorage.saveUser(user);
    return user;
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
    final user = await _apiService.register(
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      email: email,
      phone: phone,
      governce: governce,
      age: age,
      password: password,
    );
    if (user.token != null && user.token!.isNotEmpty) {
      await _tokenStorage.saveToken(user.token!);
    }
    _currentUser = user;
    await _tokenStorage.saveUser(user);
    return user;
  }

  Future<UnitsResponse> getUnits() async {
    final token = getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('No authentication token found. Please log in.');
    }
    return _apiService.getUnits(token);
  }

  Future<void> logout() async {
    _currentUser = null;
    await _tokenStorage.clearAll();
  }

  Future<void> init() async {
    final token = _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      _currentUser = _tokenStorage.getUser();
    }
  }

  static Future<AuthService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenStorage = TokenStorage(prefs);
    final apiService = ApiService();
    return AuthService(
      apiService: apiService,
      tokenStorage: tokenStorage,
    );
  }
}
