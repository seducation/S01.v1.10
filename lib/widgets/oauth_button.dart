import 'package:flutter/material.dart';

/// Reusable OAuth button widget with provider branding
class OAuthButton extends StatelessWidget {
  final String provider;
  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  const OAuthButton({
    super.key,
    required this.provider,
    required this.label,
    required this.onPressed,
    required this.icon,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
  });

  /// Factory constructor for Google OAuth button
  factory OAuthButton.google({
    required VoidCallback onPressed,
    String label = 'Continue with Google',
  }) {
    return OAuthButton(
      provider: 'google',
      label: label,
      onPressed: onPressed,
      icon: Icons.g_mobiledata,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
    );
  }

  /// Factory constructor for GitHub OAuth button
  factory OAuthButton.github({
    required VoidCallback onPressed,
    String label = 'Continue with GitHub',
  }) {
    return OAuthButton(
      provider: 'github',
      label: label,
      onPressed: onPressed,
      icon: Icons.code,
      backgroundColor: const Color(0xFF24292e),
      textColor: Colors.white,
    );
  }

  /// Factory constructor for Apple OAuth button
  factory OAuthButton.apple({
    required VoidCallback onPressed,
    String label = 'Continue with Apple',
  }) {
    return OAuthButton(
      provider: 'apple',
      label: label,
      onPressed: onPressed,
      icon: Icons.apple,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
