import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:namkeen_tv/services/auth_service.dart';

enum LoginMode {
  email,
  username,
  phone,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  LoginMode _loginMode = LoginMode.email;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your ${_loginMode == LoginMode.email ? 'email' : _loginMode == LoginMode.username ? 'username' : 'phone number'}';
    }

    if (_loginMode == LoginMode.email) {
      // Email validation
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    } else if (_loginMode == LoginMode.username) {
      // Username validation
      if (value.length < 3) {
        return 'Username must be at least 3 characters';
      }
      final usernameRegex = RegExp(r'^[a-zA-Z0-9]+$');
      if (!usernameRegex.hasMatch(value)) {
        return 'Username can only contain letters and numbers';
      }
    } else {
      // Phone validation (10 digits only)
      final phoneRegex = RegExp(r'^[0-9]{10}$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Please enter a valid 10-digit phone number';
      }
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
        isEmail: _loginMode == LoginMode.email,
      );

      if (mounted) {
        if (result['success'] == true) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Login successful'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to home
          context.go('/home');
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setLoginMode(LoginMode mode) {
    setState(() {
      _loginMode = mode;
      _identifierController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  const Icon(
                    Icons.movie,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Namkeen TV',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Mode Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _loginMode == LoginMode.email
                            ? null
                            : () => _setLoginMode(LoginMode.email),
                        child: Text(
                          'Email',
                          style: TextStyle(
                            color: _loginMode == LoginMode.email
                                ? Colors.red
                                : Colors.white70,
                            fontSize: 16,
                            fontWeight: _loginMode == LoginMode.email
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '|',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _loginMode == LoginMode.username
                            ? null
                            : () => _setLoginMode(LoginMode.username),
                        child: Text(
                          'Username',
                          style: TextStyle(
                            color: _loginMode == LoginMode.username
                                ? Colors.red
                                : Colors.white70,
                            fontSize: 16,
                            fontWeight: _loginMode == LoginMode.username
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '|',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _loginMode == LoginMode.phone
                            ? null
                            : () => _setLoginMode(LoginMode.phone),
                        child: Text(
                          'Phone',
                          style: TextStyle(
                            color: _loginMode == LoginMode.phone
                                ? Colors.red
                                : Colors.white70,
                            fontSize: 16,
                            fontWeight: _loginMode == LoginMode.phone
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Email/Username/Phone Input
                  TextFormField(
                    controller: _identifierController,
                    keyboardType: _loginMode == LoginMode.phone
                        ? TextInputType.phone
                        : _loginMode == LoginMode.email
                            ? TextInputType.emailAddress
                            : TextInputType.text,
                    inputFormatters: _loginMode == LoginMode.phone
                        ? [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ]
                        : [],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: _loginMode == LoginMode.email
                          ? 'Email'
                          : _loginMode == LoginMode.username
                              ? 'Username'
                              : 'Phone Number',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: Icon(
                        _loginMode == LoginMode.email
                            ? Icons.email
                            : _loginMode == LoginMode.username
                                ? Icons.person
                                : Icons.phone,
                        color: Colors.white70,
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: _validateIdentifier,
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.white70,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Forgot password feature coming soon'),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/register');
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
