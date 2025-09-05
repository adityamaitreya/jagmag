import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/responsive_helper.dart';
import '../widgets/jagmag_logo.dart';

class YourIssuesScreen extends StatefulWidget {
  const YourIssuesScreen({super.key});

  @override
  State<YourIssuesScreen> createState() => _YourIssuesScreenState();
}

class _YourIssuesScreenState extends State<YourIssuesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _userIssues = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadUserIssues();
  }

  Future<void> _loadUserIssues() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final snapshot = await _firestore
          .collection('issues')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _userIssues = snapshot.docs.map((doc) {
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
              'location': data['location'] ?? 'Unknown Location',
            };
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading your issues: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredIssues {
    if (_selectedFilter == 'All') {
      return _userIssues;
    }
    return _userIssues
        .where((issue) => issue['status'] == _selectedFilter)
        .toList();
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
              'Your Issues',
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
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Issues')),
              const PopupMenuItem(value: 'Pending', child: Text('Pending')),
              const PopupMenuItem(
                value: 'In Progress',
                child: Text('In Progress'),
              ),
              const PopupMenuItem(value: 'Resolved', child: Text('Resolved')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedFilter,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.filter_list,
                    color: Colors.blue[700],
                    size: ResponsiveHelper.getIconSize(context, 16),
                  ),
                ],
              ),
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
                    'Loading your issues...',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : _filteredIssues.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: ResponsiveHelper.getIconSize(context, 80),
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No issues found',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 20),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _selectedFilter == 'All'
                        ? 'You haven\'t reported any issues yet'
                        : 'No $_selectedFilter issues found',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 14),
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.add,
                      size: ResponsiveHelper.getIconSize(context, 20),
                    ),
                    label: Text(
                      'Report Your First Issue',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(context, 16),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadUserIssues,
              child: ListView.builder(
                padding: ResponsiveHelper.getScreenPadding(context),
                itemCount: _filteredIssues.length,
                itemBuilder: (context, index) {
                  final issue = _filteredIssues[index];
                  return Column(
                    children: [
                      _buildIssueCard(issue),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildIssueCard(Map<String, dynamic> issue) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: _getUrgencyColor(issue['urgency']),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue['description'],
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
                          issue['location'],
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 14),
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Icon(
                          Icons.access_time,
                          size: ResponsiveHelper.getIconSize(context, 14),
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(issue['timestamp']),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(issue['status']),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  issue['status'],
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 12),
                    fontWeight: FontWeight.w500,
                    color: _getStatusTextColor(issue['status']),
                  ),
                ),
              ),
            ],
          ),
          if (issue['imageUrls'] != null &&
              (issue['imageUrls'] as List).isNotEmpty) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(
                  Icons.image,
                  size: ResponsiveHelper.getIconSize(context, 16),
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 8),
                Text(
                  '${(issue['imageUrls'] as List).length} image${(issue['imageUrls'] as List).length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.thumb_up,
                size: ResponsiveHelper.getIconSize(context, 16),
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                '${issue['upvotes']}',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(width: 15),
              Icon(
                Icons.thumb_down,
                size: ResponsiveHelper.getIconSize(context, 16),
                color: Colors.grey[500],
              ),
              const SizedBox(width: 4),
              Text(
                '${issue['downvotes']}',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: Colors.grey[500],
                ),
              ),
            ],
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
}
