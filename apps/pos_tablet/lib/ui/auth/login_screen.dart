import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_core/ui/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late AuthViewModel _authViewModel;

  @override
  void initState() {
    super.initState();
    // Resolve viewmodel reference safely outside the build loop
    _authViewModel = context.read<AuthViewModel>();

    // Wire up the result callback listener exactly like your addFuel implementation
    _authViewModel.login.addListener(_onLoginResult);
  }

  @override
  void dispose() {
    _authViewModel.login.removeListener(_onLoginResult);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginResult() {
    final command = _authViewModel.login;

    // Handle failure propagation cleanly
    if (command.error) {
      final result = command.result;
      String errorMessage = 'Authentication failed.';

      if (result is Error) {
        // Unpack your standard system exception message
        errorMessage = result.toString().replaceAll('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      // Prevent stale error states on subsequent clicks
      command.clearResult();
    }

    // Note: Success tracking is automatically caught by GoRouter's
    // refreshListenable redirect loop, handling navigation away to '/' for us!
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // Execute command with bundled wrapper credentials payload
      _authViewModel.login.execute(
        LoginCredentials(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen directly to the login command to react to the 'running' flag state
    final isLoggingIn = context.watch<AuthViewModel>().login.running;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Musakanye Stores',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Username input
                  TextFormField(
                    controller: _usernameController,
                    enabled: !isLoggingIn,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Username required'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Password input
                  TextFormField(
                    controller: _passwordController,
                    enabled: !isLoggingIn,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Password required'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Action Button
                  ElevatedButton(
                    onPressed: isLoggingIn ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: isLoggingIn
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
