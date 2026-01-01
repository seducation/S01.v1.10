import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import 'widgets/oauth_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// Handles OAuth sign-up/sign-in with the specified provider
  /// Note: Appwrite automatically creates an account if it doesn't exist
  Future<void> _handleOAuthSignUp(String provider) async {
    try {
      await Provider.of<AuthService>(
        context,
        listen: false,
      ).signInWithOAuth(provider, context: context);
      // Navigation is handled by auth state change listener or router
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // OAuth Section
              OAuthButton.google(
                onPressed: () => _handleOAuthSignUp('google'),
                label: 'Sign up with Google',
              ),
              const SizedBox(height: 12),
              OAuthButton.github(
                onPressed: () => _handleOAuthSignUp('github'),
                label: 'Sign up with GitHub',
              ),
              const SizedBox(height: 12),
              OAuthButton.apple(
                onPressed: () => _handleOAuthSignUp('apple'),
                label: 'Sign up with Apple',
              ),
              const SizedBox(height: 24),
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR CONTINUE WITH EMAIL',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your password' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final authService = Provider.of<AuthService>(
                        context,
                        listen: false,
                      );
                      // Start the signup process (sends OTP)
                      final userId = await authService.startSignUp(
                        _emailController.text,
                      );

                      if (context.mounted) {
                        context.go(
                          '/verify-otp',
                          extra: {
                            'userId': userId,
                            'email': _emailController.text,
                            'name': _nameController.text,
                            'password': _passwordController.text,
                          },
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }
                  }
                },
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/signin'),
                child: const Text('Already have an account? Sign in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
