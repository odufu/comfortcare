import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class GeminiService {
  static const String _systemInstruction = 
      'You are Dr. Comfort, the AI Senior Clinical Pharmacist for ComfortCare Pharmaceuticals Ltd in Nigeria. '
      'Your role is to provide empathetic, medically accurate, and concise health advice (under 120 words). '
      'When appropriate, reference standard Nigerian clinical guidance (such as ACT antimalarials, NAFDAC-approved medications, and cold-chain safety for biologics/insulin). '
      'Always clearly explain dosage instructions and safety precautions. '
      'If red flags or severe acute symptoms are detected, advise immediate clinical hospital consultation. '
      'Keep formatting clean with bullet points where helpful. Do not use Markdown headings.';

  /// Generates real-time clinical responses using Gemini API
  static Future<String> generateClinicalResponse({
    required String prompt,
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    final apiKey = ApiConstants.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Gemini API Key is not configured.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/${ApiConstants.geminiModel}:generateContent?key=$apiKey',
    );

    // Build conversation contents
    final contents = <Map<String, dynamic>>[];

    // Add prior dialogue turns if provided
    for (final turn in conversationHistory) {
      contents.add({
        'role': turn['role'] == 'user' ? 'user' : 'model',
        'parts': [{'text': turn['text'] ?? ''}],
      });
    }

    // Add the current prompt
    contents.add({
      'role': 'user',
      'parts': [{'text': prompt}],
    });

    final payload = {
      'system_instruction': {
        'parts': [{'text': _systemInstruction}]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.65,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 450,
      },
    };

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
        throw Exception('Empty content returned from Gemini model.');
      } else {
        final errorBody = response.body;
        if (kDebugMode) {
          debugPrint('[GeminiService] API error (${response.statusCode}): $errorBody');
        }
        throw Exception('Gemini API returned status ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GeminiService] Exception during generation: $e');
      }
      rethrow;
    }
  }
}
