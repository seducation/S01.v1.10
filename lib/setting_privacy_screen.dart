import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingPrivacyScreen extends StatelessWidget {
  const SettingPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for MyApps',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Last Updated: 24th July 2024',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(
              'Owned & Operated By: MyApps Inc.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 16),
            Text(
              'MyApps (“we”, “our”, “us”) provides a social media platform that allows users to create profiles, share posts, upload media, and communicate with others. This Privacy Policy explains how we collect, use, store, and protect your information.',
            ),
            SizedBox(height: 16),
            Text(
              '1. Information We Collect',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We may collect the following information when you use MyApps:',
            ),
            SizedBox(height: 8),
            Text(
              '1.1 Personal Information',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Name\nUsername\nEmail address\nPhone number\nProfile photo\nDate of birth (if provided)'),
            SizedBox(height: 8),
            Text(
              '1.2 User-Generated Content',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Posts, photos, videos, comments\nStories, status updates\nMessages and chats'),
             SizedBox(height: 8),
            Text(
              '1.3 Device & Usage Data',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Device model, operating system\nIP address\nApp usage information\nLog files and crash reports'),
             SizedBox(height: 8),
            Text(
              '1.4 Location Data',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Approximate location based on IP\n(Optional) Precise GPS location if user allows it'),
             SizedBox(height: 8),
            Text(
              '1.5 Third-Party Services',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('If you use third-party login or analytics/ads, these services may collect data:\n\nGoogle AdMob (advertising)\nAppwrite or other backend services\nAnalytics tools (if used)'),
            SizedBox(height: 16),
            Text(
              '2. How We Use Your Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('We use the collected data to:\n\nCreate and manage user accounts\nProvide social features (posting, messaging, etc.)\nImprove app performance\nPersonalize content and recommendations\nPrevent fraud, spam, and abuse\nDisplay ads (if enabled)\nCommunicate updates, security notices, and support messages'),
            SizedBox(height: 16),
            Text(
              '3. How We Share Your Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('We do not sell user information.\n\nWe may share information only with:\n\nService Providers (hosting, database, ads, analytics)\nLaw enforcement (only if legally required)\nOther users (only content you choose to share publicly)\n\nPrivate messages are not shared publicly, except for security/legal reasons.'),
            SizedBox(height: 16),
            Text(
              '4. How We Protect Your Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('We use:\n\nEncrypted connections (HTTPS)\nSecure data storage\nAccess control and authentication\n\nHowever, no method is 100% secure. Users should keep passwords safe.'),
            SizedBox(height: 16),
            Text(
              '5. Your Rights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('You may:\n\nAccess and update your information\nDelete your account\nRequest deletion of your data\nChange privacy settings inside the app'),
             SizedBox(height: 16),
            Text(
              '6. Children’s Privacy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('MyApps is not intended for users under 13 years of age.\nIf we learn that a minor’s data was collected, we will delete it immediately.'),
            SizedBox(height: 16),
            Text(
              '7. Changes to This Policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('We may update this Privacy Policy from time to time. Continued use of the app after changes means you accept the updated policy.'),
             SizedBox(height: 16),
            Text(
              '8. Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('For questions or concerns, contact:\nMyApps Inc.\nEmail: support@myapps.com'),
            Divider(height: 40, thickness: 1),
            Text(
              'Terms & Conditions for MyApps',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
             Text(
              'Last Updated: 24th July 2024',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(
              'Owned & Operated By: MyApps Inc.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
             SizedBox(height: 16),
            Text('By using MyApps, you agree to follow these Terms & Conditions. If you do not agree, please do not use the app.'),
             SizedBox(height: 16),
            Text(
              '1. Use of the App',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('You must be 13 years or older.\nYou are responsible for the security of your account.\nDo not share your password with others.'),
             SizedBox(height: 16),
            Text(
              '2. User Responsibilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 8),
            Text('You agree not to:\n\nPost harmful, abusive, illegal, or inappropriate content\nImpersonate others\nSpread spam, viruses, or malware\nHarass or threaten other users\nViolate privacy of others\nUpload copyrighted content without permission'),
            SizedBox(height: 16),
            Text(
              '3. User Content',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('You own the content you upload.\n\nBy posting on MyApps, you give us permission to display your content within the app.\n\nWe may remove content that violates our policies.'),
            SizedBox(height: 16),
            Text(
              '4. Messaging & Communication',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Users are responsible for their messages.\n\nWe may review messages if required for security, abuse, or legal reasons.'),
            SizedBox(height: 16),
            Text(
              '5. Advertisements & Third-Party Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('The app may show ads or link to third-party services.\nWe are not responsible for:\n\nThird-party content\nTheir policies\nTheir actions\n\nUse them at your own risk.'),
            SizedBox(height: 16),
            Text(
              '6. Termination',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('We may suspend or delete accounts that violate terms, including:\n\nPosting illegal content\nHarassment\nRepeated policy violations\nAttempting to hack or damage the app\n\nUsers can also delete their account at any time.'),
            SizedBox(height: 16),
            Text(
              '7. Liability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('MyApps is provided “as-is.”\nWe are not responsible for:\n\nData loss\nService interruptions\nUser conflicts or misuse\n\nUse the app at your own risk.'),
             SizedBox(height: 16),
            Text(
              '8. Changes to Terms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('We may update these Terms at any time. You will be notified of changes within the app.'),
             SizedBox(height: 16),
            Text(
              '9. Contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
             SizedBox(height: 8),
            Text('For any issues, contact:\nMyApps Inc.\nEmail: support@myapps.com'),
          ],
        ),
      ),
    );
  }
}
