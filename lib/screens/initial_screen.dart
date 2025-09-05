import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../widgets/jagmag_logo.dart';
import 'login_screen.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // Logo Section
              Center(child: JagmagLogo(size: 80)),

              const SizedBox(height: 40),

              // Welcome Text
              Text(
                'Welcome to JAGMAG',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 28),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Streetlight Issue Reporter',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 50),

              // Description Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200]!,
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      size: ResponsiveHelper.getIconSize(context, 40),
                      color: Colors.blue[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Help Keep Your City Bright',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 18),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Report streetlight issues and help maintain safe, well-lit neighborhoods. Join our community of responsible citizens.',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 14),
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Citizen Option Card
              _buildCitizenCard(context),

              const SizedBox(height: 30),

              // Footer
              Text(
                'Join our community today',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitizenCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue[200]!,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Icon and Title Row
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join as Citizen',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 20),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Report issues and track progress',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 14),
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.8),
                  size: 18,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Features List
            Column(
              children: [
                _buildFeatureItem(
                  context,
                  Icons.camera_alt,
                  'Capture issues with photos/videos',
                ),
                const SizedBox(height: 8),
                _buildFeatureItem(
                  context,
                  Icons.location_on,
                  'Auto GPS location tagging',
                ),
                const SizedBox(height: 8),
                _buildFeatureItem(
                  context,
                  Icons.psychology,
                  'AI-powered analysis',
                ),
                const SizedBox(height: 8),
                _buildFeatureItem(
                  context,
                  Icons.track_changes,
                  'Track resolution progress',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // CTA Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[600],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 13),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }
}
