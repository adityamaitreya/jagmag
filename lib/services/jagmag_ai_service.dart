import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class JagmagAIService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent';

  static Future<Map<String, dynamic>> analyzeImageAndText({
    required File imageFile,
    String? userDescription,
  }) async {
    try {
      // Read image file as base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Prepare the prompt for streetlight and infrastructure issues
      String prompt = '''
Analyze this image and provide the following information for a streetlight and infrastructure reporting app called JAGMAG:

1. **Urgency Level**:
   - High Priority (immediate safety risk, major infrastructure failure)
   - Medium Priority (moderate inconvenience, needs attention soon)
   - Low Priority (minor issue, can be addressed later)

2. **Detailed Description**: Provide a clear, professional description of the issue that would help maintenance crews understand what needs to be fixed.

3. **Risk Assessment**: Brief assessment of any safety risks or potential hazards.

Please respond in JSON format:
{
  "urgency": "High Priority/Medium Priority/Low Priority",
  "description": "detailed description",
  "riskAssessment": "brief risk assessment"
}
''';

      if (userDescription != null && userDescription.isNotEmpty) {
        prompt +=
            '\n\nUser Description: $userDescription\n\nConsider the user description when analyzing the image.';
      }

      // Prepare request body
      Map<String, dynamic> requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 1024,
        },
      };

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['candidates'] != null &&
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0]['content'] != null &&
            responseData['candidates'][0]['content']['parts'] != null &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty) {
          String responseText =
              responseData['candidates'][0]['content']['parts'][0]['text'];

          // Try to parse JSON from response
          try {
            // Extract JSON from the response (it might be wrapped in markdown)
            String jsonText = responseText;
            if (responseText.contains('```json')) {
              jsonText = responseText.split('```json')[1].split('```')[0];
            } else if (responseText.contains('{') &&
                responseText.contains('}')) {
              jsonText = responseText.substring(
                responseText.indexOf('{'),
                responseText.lastIndexOf('}') + 1,
              );
            }

            Map<String, dynamic> analysis = jsonDecode(jsonText);

            return {
              'success': true,
              'urgency': analysis['urgency'] ?? 'Medium Priority',
              'description':
                  analysis['description'] ?? 'Issue detected in the image',
              'riskAssessment':
                  analysis['riskAssessment'] ?? 'No immediate risks identified',
            };
          } catch (e) {
            // Fallback parsing if JSON parsing fails
            return _parseTextResponse(responseText);
          }
        }
      }

      return {
        'success': false,
        'error': 'Failed to analyze image',
        'urgency': 'Medium Priority',
        'description': 'Unable to analyze image automatically',
        'riskAssessment': 'Manual assessment required',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error analyzing image: $e',
        'urgency': 'Medium Priority',
        'description': 'Error occurred during analysis',
        'riskAssessment': 'Manual assessment required',
      };
    }
  }

  static Map<String, dynamic> _parseTextResponse(String responseText) {
    // Fallback parsing for non-JSON responses
    String urgency = 'Medium Priority';
    String description = 'Issue detected in the image';
    String riskAssessment = 'No immediate risks identified';

    // Try to extract urgency
    if (responseText.toLowerCase().contains('high priority') ||
        responseText.toLowerCase().contains('urgent')) {
      urgency = 'High Priority';
    } else if (responseText.toLowerCase().contains('low priority')) {
      urgency = 'Low Priority';
    }

    // Extract description
    if (responseText.contains('description:')) {
      description = responseText.split('description:')[1].split('\n')[0].trim();
    }

    return {
      'success': true,
      'urgency': urgency,
      'description': description,
      'riskAssessment': riskAssessment,
    };
  }
}
