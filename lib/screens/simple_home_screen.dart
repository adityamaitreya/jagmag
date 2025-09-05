import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../widgets/jagmag_logo.dart';
import '../services/jagmag_auth_service.dart';
import 'camera_capture_screen.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  final JagmagAuthService _authService = JagmagAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            JagmagLogo(size: ResponsiveHelper.getIconSize(context, 24)),
            const SizedBox(width: 10),
            Text(
              'Jagmag',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.account_circle,
              color: Colors.grey[600],
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                try {
                  await _authService.signOut();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $e')),
                    );
                  }
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    const Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.lightbulb_outline,
                size: ResponsiveHelper.getIconSize(context, 80),
                color: Colors.amber[600],
              ),
              const SizedBox(height: 20),
              Text(
                'Welcome to Jagmag!',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your partner in keeping our streets bright and safe.',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraCaptureScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.camera_alt,
                    size: ResponsiveHelper.getIconSize(context, 24),
                  ),
                  label: Text(
                    'Report a New Issue',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Your reports help us maintain better public infrastructure.',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
