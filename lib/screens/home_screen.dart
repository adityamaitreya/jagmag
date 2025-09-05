import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/responsive_helper.dart';
import '../widgets/placeholder_image_widget.dart';
import '../widgets/jagmag_logo.dart';
import '../services/jagmag_auth_service.dart';
import '../services/jagmag_location_service.dart';
import 'camera_capture_screen.dart';
import 'your_issues_screen.dart';
import 'issues_list_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JagmagAuthService _authService = JagmagAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentIssues = [];
  String _userLocation = 'Loading location...';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Sign in anonymously if not already signed in
      if (!_authService.isLoggedIn) {
        await _authService.signInAnonymously();
      }

      // Load recent issues
      await _loadRecentIssues();

      // Get user location
      await _getUserLocation();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error initializing app: $e')));
      }
    }
  }

  Future<void> _loadRecentIssues() async {
    try {
      final snapshot = await _firestore
          .collection('issues')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      if (mounted) {
        setState(() {
          _recentIssues = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'description': data['description'] ?? '',
              'urgency': data['urgency'] ?? 'Medium Priority',
              'status': data['status'] ?? 'Pending',
              'timestamp': data['timestamp'],
              'imageUrls': data['imageUrls'] ?? [],
              'upvotes': data['upvotes'] ?? 0,
              'downvotes': data['downvotes'] ?? 0,
            };
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recentIssues = [];
        });
      }
    }
  }

  Future<void> _getUserLocation() async {
    try {
      final locationResult = await JagmagLocationService.getCurrentLocation();

      if (mounted) {
        setState(() {
          if (locationResult['success'] == true) {
            _userLocation = locationResult['address'] ?? 'Location unavailable';
          } else {
            _userLocation = 'Location unavailable';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userLocation = 'Location unavailable';
        });
      }
    }
  }

  Future<void> _refreshLocation() async {
    if (mounted) {
      setState(() {
        _userLocation = 'Updating location...';
      });
    }

    await _getUserLocation();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue[600]),
              const SizedBox(height: 20),
              Text(
                'Loading Jagmag...',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _refreshLocation,
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey[600],
                  size: ResponsiveHelper.getIconSize(context, 20),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _userLocation,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.refresh,
                  color: Colors.grey[400],
                  size: ResponsiveHelper.getIconSize(context, 16),
                ),
              ],
            ),
          ),
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
                  // The AuthWrapper will automatically redirect to initial screen
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
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      children: [
        // Jagmag Logo
        JagmagLogo(size: ResponsiveHelper.isMobile(context) ? 60 : 70),

        const SizedBox(width: 20),

        // Text Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Report Streetlight Issues',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 24),
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Help keep your neighborhood safe and well-lit',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const YourIssuesScreen(),
                ),
              );
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

        if (_recentIssues.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: ResponsiveHelper.getIconSize(context, 40),
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 10),
                Text(
                  'No issues reported yet',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Be the first to report an issue in your area',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: _recentIssues.map((issue) {
              return Column(
                children: [
                  _buildIssueCard(
                    imageType: _getIssueImageType(issue['urgency']),
                    title: issue['description'],
                    location: 'Nearby',
                    time: _formatTimestamp(issue['timestamp']),
                    status: issue['status'],
                    statusColor: _getStatusColor(issue['status']),
                    statusTextColor: _getStatusTextColor(issue['status']),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  String _getIssueImageType(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high priority':
        return 'streetlight';
      case 'medium priority':
        return 'pothole';
      case 'low priority':
        return 'garbage';
      default:
        return 'streetlight';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green[100]!;
      case 'in progress':
        return Colors.blue[100]!;
      case 'pending':
        return Colors.orange[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green[800]!;
      case 'in progress':
        return Colors.blue[800]!;
      case 'pending':
        return Colors.orange[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Recently';

    try {
      final DateTime dateTime = timestamp.toDate();
      final Duration difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Recently';
    }
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

          // Handle navigation
          switch (index) {
            case 0:
              // Home - already here
              break;
            case 1:
              // Issues
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IssuesListScreen(),
                ),
              );
              break;
            case 2:
              // Map
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
              break;
            case 3:
              // Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue[600],
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(context, 12),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(context, 12),
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.list,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Issues',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
