import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../utils/responsive_helper.dart';
import '../services/jagmag_ai_service.dart';
import '../services/jagmag_location_service.dart';
import '../models/jagmag_issue_model.dart';
import '../widgets/jagmag_logo.dart';
import 'dart:developer' as developer;

class ReportDetailsScreen extends StatefulWidget {
  final List<XFile> capturedImages;
  final XFile? recordedVideo;
  final Map<String, dynamic> locationData;

  const ReportDetailsScreen({
    super.key,
    required this.capturedImages,
    this.recordedVideo,
    required this.locationData,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isAnalyzing = false;
  bool _isSubmitting = false;
  bool _isUploading = false;
  Map<String, dynamic>? _aiAnalysis;
  String _selectedUrgency = '';

  // Upload progress
  double _uploadProgress = 0.0;
  List<String> _uploadedImageUrls = [];
  String? _uploadedVideoUrl;

  // Firebase services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _analyzeImages();
  }

  Future<void> _analyzeImages() async {
    if (widget.capturedImages.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Analyze the first image for AI insights
      final analysis = await JagmagAIService.analyzeImageAndText(
        imageFile: File(widget.capturedImages.first.path),
        userDescription: _descriptionController.text,
      );

      if (mounted) {
        setState(() {
          _aiAnalysis = analysis;
          _selectedUrgency = analysis['urgency'] ?? '';
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error analyzing image: $e')));
      }
    }
  }

  Future<void> _uploadMedia() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Upload images
      for (int i = 0; i < widget.capturedImages.length; i++) {
        final imageFile = File(widget.capturedImages[i].path);
        final fileName = '${_uuid.v4()}.jpg';
        final ref = _storage.ref().child('issues_images/$fileName');

        final uploadTask = ref.putFile(imageFile);

        // Track upload progress
        uploadTask.snapshotEvents.listen((snapshot) {
          if (mounted) {
            setState(() {
              _uploadProgress =
                  (i + snapshot.bytesTransferred / snapshot.totalBytes) /
                  widget.capturedImages.length;
            });
          }
        });

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        _uploadedImageUrls.add(downloadUrl);
      }

      // Upload video if exists
      if (widget.recordedVideo != null) {
        final videoFile = File(widget.recordedVideo!.path);
        final fileName = '${_uuid.v4()}.mp4';
        final ref = _storage.ref().child('issues_videos/$fileName');

        final uploadTask = ref.putFile(videoFile);
        final snapshot = await uploadTask;
        _uploadedVideoUrl = await snapshot.ref.getDownloadURL();
      }

      setState(() {
        _isUploading = false;
        _uploadProgress = 1.0;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      throw Exception('Error uploading media: $e');
    }
  }

  Future<void> _submitReport() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please add a description')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload media first
      await _uploadMedia();

      // Get current user
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create issue data
      final issueData = {
        'description': _descriptionController.text.trim(),
        'urgency': _selectedUrgency,
        'imageUrls': _uploadedImageUrls,
        'videoUrl': _uploadedVideoUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'location': widget.locationData,
        'userId': currentUser.uid,
        'username': currentUser.displayName ?? 'Anonymous',
        'status': 'Pending',
        'upvotes': 0,
        'downvotes': 0,
        'voters': {},
        'commentsCount': 0,
        'isUnresolved': true,
        'aiAnalysis': _aiAnalysis,
      };

      // Save to Firestore
      await _firestore.collection('issues').add(issueData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error submitting report: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Row(
          children: [
            JagmagLogo(size: 30),
            const SizedBox(width: 10),
            Text(
              'Report Issue',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 18),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Media Preview Section
            _buildMediaSection(),

            const SizedBox(height: 20),

            // Location Section
            _buildLocationSection(),

            const SizedBox(height: 20),

            // Description Section
            _buildDescriptionSection(),

            const SizedBox(height: 20),

            // Repair Priority Section
            _buildPrioritySection(),

            const SizedBox(height: 30),

            // Submit Button
            _buildSubmitButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green[600],
              size: ResponsiveHelper.getIconSize(context, 20),
            ),
            const SizedBox(width: 8),
            Text(
              'Media Successfully Captured',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: Colors.green[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Images Grid
        if (widget.capturedImages.isNotEmpty) ...[
          Text(
            'Images (${widget.capturedImages.length})',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: widget.capturedImages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300]!,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(widget.capturedImages[index].path),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ],

        // Video Preview
        if (widget.recordedVideo != null) ...[
          const SizedBox(height: 20),
          Text(
            'Video Recording',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[300]!,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.videocam, color: Colors.white, size: 60),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.blue[600],
                size: ResponsiveHelper.getIconSize(context, 20),
              ),
              const SizedBox(width: 8),
              Text(
                'Location',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.grey[500],
                size: ResponsiveHelper.getIconSize(context, 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.locationData['success'] == true
                      ? widget.locationData['address'] ?? 'Location unavailable'
                      : 'Location unavailable',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Captured at ${DateFormat('M/d/yyyy, h:mm:ss a').format(DateTime.now())}',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 12),
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText:
                  'Describe the issue you\'ve captured. Be as detailed as possible to help authorities understand and prioritize the problem.',
              hintStyle: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 14),
                color: Colors.grey[500],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue[600]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && _aiAnalysis != null) {
                _analyzeImages();
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${_descriptionController.text.length}/500 characters',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 12),
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repair Priority',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Automatically determined based on issue type and severity',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 14),
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getPriorityColor(_selectedUrgency),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedUrgency.isNotEmpty
                      ? _selectedUrgency
                      : 'Analyzing...',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 12),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  _getExpectedResponseTime(_selectedUrgency),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          if (_isAnalyzing) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Analyzing images...',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high priority':
        return Colors.red[400]!;
      case 'medium priority':
        return Colors.orange[400]!;
      case 'low priority':
        return Colors.green[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  String _getExpectedResponseTime(String priority) {
    switch (priority.toLowerCase()) {
      case 'high priority':
        return 'Expected response: 2-4 hours';
      case 'medium priority':
        return 'Expected response: 24-48 hours';
      case 'low priority':
        return 'Expected response: 3-5 days';
      default:
        return 'Expected response: 24-48 hours';
    }
  }

  Widget _buildSubmitButton() {
    return Column(
      children: [
        if (_isUploading) ...[
          Column(
            children: [
              Text(
                'Uploading media...',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isSubmitting || _isUploading) ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: (_isSubmitting || _isUploading)
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Submit Issue Report',
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
}
