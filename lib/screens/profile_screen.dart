import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/responsive_helper.dart';
import '../widgets/jagmag_logo.dart';
import '../services/jagmag_auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final JagmagAuthService _authService = JagmagAuthService();

  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _userIssues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Load user's issues
      final issuesSnapshot = await _firestore
          .collection('issues')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _userIssues = issuesSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'description': data['description'] ?? '',
              'urgency': data['urgency'] ?? 'Medium Priority',
              'status': data['status'] ?? 'Pending',
              'timestamp': data['timestamp'],
              'location': data['location'] ?? 'Unknown Location',
            };
          }).toList();

          _userProfile = {
            'email': user.email ?? 'Anonymous User',
            'uid': user.uid,
            'totalIssues': issuesSnapshot.docs.length,
            'resolvedIssues': issuesSnapshot.docs
                .where((doc) => doc.data()['status'] == 'Resolved')
                .length,
            'pendingIssues': issuesSnapshot.docs
                .where((doc) => doc.data()['status'] == 'Pending')
                .length,
          };
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
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            JagmagLogo(size: 30),
            const SizedBox(width: 10),
            Text(
              'Profile',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await _authService.signOut();
                // Navigation will be handled by AuthWrapper
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              }
            },
            icon: Icon(
              Icons.logout,
              color: Colors.grey[600],
              size: ResponsiveHelper.getIconSize(context, 24),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue[600]),
                  const SizedBox(height: 20),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: ResponsiveHelper.getScreenPadding(context),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
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
                        CircleAvatar(
                          radius: ResponsiveHelper.isMobile(context) ? 40 : 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: ResponsiveHelper.isMobile(context) ? 40 : 50,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userProfile?['email'] ?? 'Anonymous User',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 20),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Community Member',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 14),
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Issues',
                          '${_userProfile?['totalIssues'] ?? 0}',
                          Icons.report_problem,
                          Colors.blue[600]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Resolved',
                          '${_userProfile?['resolvedIssues'] ?? 0}',
                          Icons.check_circle,
                          Colors.green[600]!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Pending',
                          '${_userProfile?['pendingIssues'] ?? 0}',
                          Icons.pending,
                          Colors.orange[600]!,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // My Issues Section
                  Container(
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
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.history,
                                color: Colors.grey[600],
                                size: ResponsiveHelper.getIconSize(context, 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'My Reported Issues',
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(
                                    context,
                                    16,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_userIssues.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: ResponsiveHelper.getIconSize(
                                    context,
                                    60,
                                  ),
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No issues reported yet',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      16,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start reporting streetlight issues in your area',
                                  style: TextStyle(
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      14,
                                    ),
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _userIssues.length,
                            itemBuilder: (context, index) {
                              final issue = _userIssues[index];
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[200]!,
                                      width: index < _userIssues.length - 1
                                          ? 1
                                          : 0,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getUrgencyColor(
                                          issue['urgency'],
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            issue['description'],
                                            style: TextStyle(
                                              fontSize:
                                                  ResponsiveHelper.getFontSize(
                                                    context,
                                                    14,
                                                  ),
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey[800],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            issue['location'],
                                            style: TextStyle(
                                              fontSize:
                                                  ResponsiveHelper.getFontSize(
                                                    context,
                                                    12,
                                                  ),
                                              color: Colors.grey[500],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(issue['status']),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        issue['status'],
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveHelper.getFontSize(
                                                context,
                                                10,
                                              ),
                                          fontWeight: FontWeight.w500,
                                          color: _getStatusTextColor(
                                            issue['status'],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // App Info
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
                          Icons.info_outline,
                          size: ResponsiveHelper.getIconSize(context, 24),
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Jagmag v1.0.0',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 16),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Streetlight Issue Reporter',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 14),
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getIconSize(context, 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 12),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high priority':
        return Colors.red[600]!;
      case 'medium priority':
        return Colors.orange[600]!;
      case 'low priority':
        return Colors.green[600]!;
      default:
        return Colors.blue[600]!;
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
}
