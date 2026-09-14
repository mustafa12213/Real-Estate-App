import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _governceController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;
  final bool _obscurePassword = true;
  final bool _obscureConfirmPassword = true;

  static const _emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const _phonePattern = r'^01[012]\d{8}$';

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecialChar =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text);

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError ? Colors.white : AppColors.successGreen,
            fontSize: 14,
          ),
        ),
        backgroundColor: isError ? AppColors.errorRed : AppColors.successGreen,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = await AuthService.create();
      await authService.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        fullName:
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        email: _emailController.text.trim().toLowerCase(),
        phone: _phoneController.text.trim(),
        governce: _governceController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        password: _passwordController.text,
      );

      if (mounted) {
        _showSnackBar('Account created successfully! Welcome.', isError: false);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateName(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your $field';
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid $field';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Please use only letters for $field';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(_emailPattern).hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (!RegExp(_phonePattern).hasMatch(value)) {
      return 'Please enter a valid Egyptian phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!_hasUppercase) {
      return 'Password must contain an uppercase letter';
    }
    if (!_hasLowercase) {
      return 'Password must contain a lowercase letter';
    }
    if (!_hasNumber) {
      return 'Password must contain a number';
    }
    if (!_hasSpecialChar) {
      return 'Password must contain a special character';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateGovernce(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your governorate';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your age';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    if (age < 18 || age > 120) {
      return 'Age must be between 18 and 120';
    }
    return null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _governceController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 400;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundWhite,
              AppColors.backgroundLight,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 40 : 24,
              vertical: 20,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Welcome please sign up!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  CustomTextField(
                    label: 'First Name',
                    hint: 'Enter your first name',
                    controller: _firstNameController,
                    keyboardType: TextInputType.text,
                    validator: (v) => _validateName(v, 'first name'),
                    showValidationIcon: true,
                    enableObscureToggle: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z\s]'),
                      ),
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Last Name',
                    hint: 'Enter your last name',
                    controller: _lastNameController,
                    keyboardType: TextInputType.text,
                    validator: (v) => _validateName(v, 'last name'),
                    showValidationIcon: true,
                    enableObscureToggle: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z\s]'),
                      ),
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    showValidationIcon: true,
                    enableObscureToggle: false,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Phone Number',
                    hint: 'Enter your phone number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                    showValidationIcon: true,
                    enableObscureToggle: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    hint: 'Create a password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enableObscureToggle: true,
                    validator: _validatePassword,
                    showValidationIcon: true,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    enableObscureToggle: true,
                    validator: _validateConfirmPassword,
                    showValidationIcon: true,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Governorate',
                    hint: 'Enter your governorate',
                    controller: _governceController,
                    keyboardType: TextInputType.text,
                    validator: _validateGovernce,
                    showValidationIcon: true,
                    enableObscureToggle: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z\s]'),
                      ),
                      LengthLimitingTextInputFormatter(50),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Age',
                    hint: 'Enter your age',
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    validator: _validateAge,
                    showValidationIcon: true,
                    enableObscureToggle: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Requirements',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRequirementRow(
                          Icons.check_circle,
                          'At least 8 characters',
                          _hasMinLength,
                        ),
                        _buildRequirementRow(
                          Icons.check_circle,
                          'One uppercase letter',
                          _hasUppercase,
                        ),
                        _buildRequirementRow(
                          Icons.check_circle,
                          'One lowercase letter',
                          _hasLowercase,
                        ),
                        _buildRequirementRow(
                          Icons.check_circle,
                          'One number',
                          _hasNumber,
                        ),
                        _buildRequirementRow(
                          Icons.check_circle,
                          'One special character',
                          _hasSpecialChar,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    text: 'Sign up',
                    onPressed: _handleSignUp,
                    isLoading: _isLoading,
                    isDisabled: _isLoading,
                    height: 54,
                    backgroundColor: AppColors.primaryBlue,
                    textStyle: AppTextStyles.button.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementRow(
    IconData icon,
    String text,
    bool isValid,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isValid ? AppColors.successGreen : AppColors.textHint,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: isValid ? AppColors.successGreen : AppColors.textHint,
              fontWeight: isValid ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
