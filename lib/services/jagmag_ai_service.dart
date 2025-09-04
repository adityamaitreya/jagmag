import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../secrets.dart';

class JagmagAIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro-vision:generateContent';
  
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

1. **Issue Category** (choose from these Jagmag-specific categories):
   - Streetlight Outage (light not working, broken bulb, flickering)
   - Streetlight Damage (broken pole, damaged fixture, vandalism)
   - Streetlight Maintenance (dirty lens, overgrown vegetation, loose wiring)
   - Streetlight Safety (exposed wires, dangerous conditions, leaning poles)
   - Road Surface Damage (potholes, cracks, damaged asphalt)
   - Road Markings (faded lines, missing crosswalks, unclear signs)
   - Manhole Covers (missing, damaged, or loose covers)
   - Road Drainage (blocked drains, flooding issues, poor drainage)
   - Traffic Signals (broken lights, malfunctioning signals, timing issues)
   - Traffic Signs (damaged, missing, or unclear signs)
   - Electrical Boxes (damaged, exposed, or vandalized electrical boxes)
   - Power Lines (hanging wires, damaged poles, electrical hazards)
   - Water Leaks (broken pipes, water main breaks, leaks)
   - Sewer Issues (blocked drains, sewer backups, pipe damage)
   - Sidewalk Issues (broken sidewalks, trip hazards, accessibility)
   - Public Lighting (insufficient lighting, dark areas, safety concerns)
   - Garbage & Waste (overflowing bins, illegal dumping, litter)
   - Tree Hazards (fallen branches, dangerous trees, overgrown vegetation)
   - Bus Stops (damaged shelters, missing benches, poor lighting)
   - Public Facilities (damaged public spaces, recreational areas)
   - Other Infrastructure (damaged public facilities, communication infrastructure)

2. **Urgency Level**:
   - High Priority (immediate safety risk, major infrastructure failure)
   - Medium Priority (moderate inconvenience, needs attention soon)
   - Low Priority (minor issue, can be addressed later)

3. **Detailed Description**: Provide a clear, professional description of the issue that would help maintenance crews understand what needs to be fixed.

4. **Risk Assessment**: Brief assessment of any safety risks or potential hazards.

Please respond in JSON format:
{
  "category": "exact category name from the list above",
  "urgency": "High Priority/Medium Priority/Low Priority",
  "description": "detailed description",
  "riskAssessment": "brief risk assessment"
}
''';

      if (userDescription != null && userDescription.isNotEmpty) {
        prompt += '\n\nUser Description: $userDescription\n\nConsider the user description when analyzing the image.';
      }

      // Prepare request body
      Map<String, dynamic> requestBody = {
        'contents': [
          {
            'parts': [
              {
                'text': prompt,
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                },
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
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        
        if (responseData['candidates'] != null && 
            responseData['candidates'].isNotEmpty &&
            responseData['candidates'][0]['content'] != null &&
            responseData['candidates'][0]['content']['parts'] != null &&
            responseData['candidates'][0]['content']['parts'].isNotEmpty) {
          
          String responseText = responseData['candidates'][0]['content']['parts'][0]['text'];
          
          // Try to parse JSON from response
          try {
            // Extract JSON from the response (it might be wrapped in markdown)
            String jsonText = responseText;
            if (responseText.contains('```json')) {
              jsonText = responseText.split('```json')[1].split('```')[0];
            } else if (responseText.contains('{') && responseText.contains('}')) {
              jsonText = responseText.substring(
                responseText.indexOf('{'),
                responseText.lastIndexOf('}') + 1,
              );
            }
            
            Map<String, dynamic> analysis = jsonDecode(jsonText);
            
            return {
              'success': true,
              'category': analysis['category'] ?? 'Other Infrastructure',
              'urgency': analysis['urgency'] ?? 'Medium Priority',
              'description': analysis['description'] ?? 'Issue detected in the image',
              'riskAssessment': analysis['riskAssessment'] ?? 'No immediate risks identified',
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
        'category': 'Other Infrastructure',
        'urgency': 'Medium Priority',
        'description': 'Unable to analyze image automatically',
        'riskAssessment': 'Manual assessment required',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error analyzing image: $e',
        'category': 'Other Infrastructure',
        'urgency': 'Medium Priority',
        'description': 'Error occurred during analysis',
        'riskAssessment': 'Manual assessment required',
      };
    }
  }

  static Map<String, dynamic> _parseTextResponse(String responseText) {
    // Fallback parsing for non-JSON responses
    String category = 'Other Infrastructure';
    String urgency = 'Medium Priority';
    String description = 'Issue detected in the image';
    String riskAssessment = 'No immediate risks identified';

    // Try to extract category
    if (responseText.toLowerCase().contains('streetlight')) {
      if (responseText.toLowerCase().contains('outage') || responseText.toLowerCase().contains('not working')) {
        category = 'Streetlight Outage';
      } else if (responseText.toLowerCase().contains('damage') || responseText.toLowerCase().contains('broken')) {
        category = 'Streetlight Damage';
      } else {
        category = 'Streetlight Maintenance';
      }
    } else if (responseText.toLowerCase().contains('road') || responseText.toLowerCase().contains('pothole')) {
      category = 'Road Infrastructure';
    } else if (responseText.toLowerCase().contains('traffic')) {
      category = 'Traffic Infrastructure';
    } else if (responseText.toLowerCase().contains('water') || responseText.toLowerCase().contains('leak')) {
      category = 'Water Infrastructure';
    } else if (responseText.toLowerCase().contains('electrical') || responseText.toLowerCase().contains('power')) {
      category = 'Electrical Infrastructure';
    }

    // Try to extract urgency
    if (responseText.toLowerCase().contains('high priority') || responseText.toLowerCase().contains('urgent')) {
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
      'category': category,
      'urgency': urgency,
      'description': description,
      'riskAssessment': riskAssessment,
    };
  }
}
