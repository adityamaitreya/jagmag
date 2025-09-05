import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/responsive_helper.dart';
import '../widgets/jagmag_logo.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _issues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIssuesForMap();
  }

  Future<void> _loadIssuesForMap() async {
    try {
      final snapshot = await _firestore
          .collection('issues')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      if (mounted) {
        setState(() {
          _issues = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'description': data['description'] ?? '',
              'urgency': data['urgency'] ?? 'Medium Priority',
              'status': data['status'] ?? 'Pending',
              'timestamp': data['timestamp'],
              'latitude': data['latitude'],
              'longitude': data['longitude'],
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading map data: $e')));
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
              'Issues Map',
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
            onPressed: _loadIssuesForMap,
            icon: Icon(
              Icons.refresh,
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
                    'Loading map data...',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getFontSize(context, 16),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Map placeholder
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: ResponsiveHelper.getScreenPadding(context),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: ResponsiveHelper.getIconSize(context, 80),
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Interactive Map',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 20),
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Map integration coming soon!\nGoogle Maps will show issue locations',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getFontSize(context, 14),
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Map integration will be added in the next update!',
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.map_outlined,
                            size: ResponsiveHelper.getIconSize(context, 20),
                          ),
                          label: Text(
                            'Enable Map View',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getFontSize(
                                context,
                                16,
                              ),
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
                  ),
                ),

                // Issues list
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: ResponsiveHelper.getScreenPadding(
                      context,
                    ).copyWith(top: 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
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
                                Icons.list,
                                color: Colors.grey[600],
                                size: ResponsiveHelper.getIconSize(context, 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recent Issues (${_issues.length})',
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
                        Expanded(
                          child: _issues.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_off,
                                        size: ResponsiveHelper.getIconSize(
                                          context,
                                          40,
                                        ),
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'No issues with location data',
                                        style: TextStyle(
                                          fontSize:
                                              ResponsiveHelper.getFontSize(
                                                context,
                                                16,
                                              ),
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _issues.length,
                                  itemBuilder: (context, index) {
                                    final issue = _issues[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey[200]!,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                              color: _getStatusColor(
                                                issue['status'],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                        ),
                      ],
                    ),
                  ),
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
