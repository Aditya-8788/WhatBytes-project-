import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

abstract final class AuthValidators {
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return 'Please enter your email';
    }
    final isValid = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.]+$').hasMatch(v);
    if (!isValid) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) {
      return 'Please enter your password';
    }
    if (v.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

class AuthSubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AuthSubmitButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) => current is! AuthSuccess,
      builder: (context, state) {
        if (state is AuthLoading) {
          return const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onPressed,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }
}