import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../widgets/placeholder_image_widget.dart';
import 'camera_capture_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Location
            _buildTopBar(),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getScreenPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Header Section with Icon and Text
                    _buildHeaderSection(),

                    const SizedBox(height: 30),

                    // Action Buttons
                    _buildActionButtons(),

                    const SizedBox(height: 30),

                    // Recent Issues Section
                    _buildRecentIssuesSection(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: ResponsiveHelper.getScreenPadding(
        context,
      ).copyWith(top: 10, bottom: 10),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.grey[600],
            size: ResponsiveHelper.getIconSize(context, 20),
          ),
          const SizedBox(width: 8),
          Text(
            'Bangalore, Karnataka',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      children: [
        // Streetlight Icon
        Container(
          width: ResponsiveHelper.isMobile(context) ? 60 : 70,
          height: ResponsiveHelper.isMobile(context) ? 60 : 70,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            Icons.lightbulb,
            color: Colors.orange[400],
            size: ResponsiveHelper.getIconSize(context, 35),
          ),
        ),

        const SizedBox(width: 20),

        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Got an Issue?',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'JAGMAG has a find.',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Report Button
        Expanded(
          flex: 3,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraCaptureScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Report',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(width: 15),

        // Your Issues Button
        Expanded(
          flex: 2,
          child: OutlinedButton(
            onPressed: () {
              // TODO: Navigate to your issues screen
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Your Issues',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentIssuesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Issues in Nearby Areas',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),

        const SizedBox(height: 15),

        // Issue Cards
        _buildIssueCard(
          imageType: 'streetlight',
          title: 'Street light not working',
          location: 'MG Road',
          time: '2 hours ago',
          status: 'Pending',
          statusColor: Colors.orange[100]!,
          statusTextColor: Colors.orange[800]!,
        ),

        const SizedBox(height: 12),

        _buildIssueCard(
          imageType: 'pothole',
          title: 'Pothole on main street',
          location: 'Brigade Road',
          time: '4 hours ago',
          status: 'In Progress',
          statusColor: Colors.blue[100]!,
          statusTextColor: Colors.blue[800]!,
        ),

        const SizedBox(height: 12),

        _buildIssueCard(
          imageType: 'water_leakage',
          title: 'Water leakage',
          location: 'Koramangala',
          time: '6 hours ago',
          status: 'Resolved',
          statusColor: Colors.green[100]!,
          statusTextColor: Colors.green[800]!,
        ),

        const SizedBox(height: 12),

        _buildIssueCard(
          imageType: 'garbage',
          title: 'Garbage not collected',
          location: 'Indiranagar',
          time: '1 day ago',
          status: 'Pending',
          statusColor: Colors.orange[100]!,
          statusTextColor: Colors.orange[800]!,
        ),
      ],
    );
  }

  Widget _buildIssueCard({
    required String imageType,
    required String title,
    required String location,
    required String time,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Blue Line
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(width: 15),

          // Image
          PlaceholderImageWidget(
            type: imageType,
            size: ResponsiveHelper.isMobile(context) ? 50 : 60,
          ),

          const SizedBox(width: 15),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: ResponsiveHelper.getIconSize(context, 14),
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$location • $time',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 14),
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 12),
                fontWeight: FontWeight.w500,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Your reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Capture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
