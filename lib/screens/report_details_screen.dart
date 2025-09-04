import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/responsive_helper.dart';
import '../services/jagmag_ai_service.dart';
import '../services/jagmag_location_service.dart';

class ReportDetailsScreen extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic> locationData;

  const ReportDetailsScreen({
    super.key,
    required this.imageFile,
    required this.locationData,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isAnalyzing = false;
  bool _isSubmitting = false;
  Map<String, dynamic>? _aiAnalysis;
  String _selectedCategory = '';
  String _selectedUrgency = '';

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final analysis = await JagmagAIService.analyzeImageAndText(
        imageFile: widget.imageFile,
        userDescription: _descriptionController.text,
      );

      if (mounted) {
        setState(() {
          _aiAnalysis = analysis;
          _selectedCategory = analysis['category'] ?? '';
          _selectedUrgency = analysis['urgency'] ?? '';
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image: $e')),
        );
      }
    }
  }

  Future<void> _submitReport() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a description')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Implement report submission to Firebase
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting report: $e')),
        );
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
        title: Text(
          'Report Issue',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Image Successfully Captured Section
            _buildImageSection(),
            
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

  Widget _buildImageSection() {
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
              'Image Successfully Captured',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: Colors.green[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          height: ResponsiveHelper.isMobile(context) ? 200 : 250,
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
            child: Stack(
              children: [
                Image.file(
                  widget.imageFile,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green[600],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: ResponsiveHelper.getIconSize(context, 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
              hintText: 'Describe the issue you\'ve captured. Be as detailed as possible to help authorities understand and prioritize the problem.',
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
              // Re-analyze if user adds description
              if (value.isNotEmpty && _aiAnalysis != null) {
                _analyzeImage();
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getPriorityColor(_selectedUrgency),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedUrgency.isNotEmpty ? _selectedUrgency : 'Analyzing...',
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
                  'Analyzing image...',
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
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
    );
  }
}
