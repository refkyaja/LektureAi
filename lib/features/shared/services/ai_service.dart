import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../chat/domain/chat_model.dart';
import '../../study/domain/study_model.dart';

class AIService {
  final Dio _dio;
  final String? customApiKey;
  final bool useCustomApiKey;

  AIService({
    this.customApiKey,
    this.useCustomApiKey = false,
  }) : _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  String? get _apiKey {
    if (useCustomApiKey && customApiKey != null && customApiKey!.isNotEmpty) {
      return customApiKey;
    }
    return dotenv.env['GEMINI_API_KEY'];
  }

  String _getEndpoint(String model) {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      throw Exception('Gemini API key is not configured. Please configure it in Settings or add GEMINI_API_KEY to your .env file.');
    }
    return 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$key';
  }

  // --- Tutor Chat ---
  Future<String> tutorChat(List<ChatMessage> conversationHistory) async {
    try {
      final systemPrompt = 
          'You are Lekture, an AI study assistant for students. '
          'Answer questions clearly, use examples, and keep explanations concise and easy to understand. '
          'Use markdown sparingly.';

      // Map chat messages to Gemini contents format
      final List<Map<String, dynamic>> contents = [];
      for (final msg in conversationHistory) {
        contents.add({
          'role': msg.role == 'user' ? 'user' : 'model',
          'parts': [
            {'text': msg.content}
          ]
        });
      }

      final body = {
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt}
          ]
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
        }
      };

      final response = await _dio.post(
        _getEndpoint('gemini-1.5-flash'),
        data: body,
      );

      return _extractText(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Tutor chat failed: $e');
    }
  }

  // --- Quiz Generator ---
  Future<List<QuizQuestion>> generateQuiz(String noteContent, {int count = 5, String difficulty = 'medium'}) async {
    try {
      final systemPrompt = 
          'You are a quiz generator. Given study notes, return STRICT JSON only '
          'of shape: {"questions":[{"q":"Question text...","options":["Option A","Option B","Option C","Option D"],"answer":0}]} '
          'with exactly $count questions and 4 options each. "answer" is the 0-based index of the correct option. '
          'Difficulty: $difficulty (easy = recall basics, medium = comprehension, hard = applied/analytical).';

      final userPrompt = 'Generate $count $difficulty-difficulty multiple-choice questions from these notes:\n\n$noteContent';

      final body = {
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt}
          ]
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': userPrompt}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.2,
        }
      };

      final response = await _dio.post(
        _getEndpoint('gemini-1.5-flash'),
        data: body,
      );

      final jsonText = _extractText(response.data);
      // Clean JSON formatting if Gemini wrapped it in markdown fences despite instructions
      final cleanJson = jsonText.replaceAll(RegExp(r'```json|```'), '').trim();
      
      // Parse JSON
      final Map<String, dynamic> parsed = jsonDecode(cleanJson);
      final List<dynamic> questionsJson = parsed['questions'] ?? [];
      
      return questionsJson.map((q) => QuizQuestion.fromJson(Map<String, dynamic>.from(q))).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to generate quiz: $e');
    }
  }

  // --- Flashcard Generator ---
  Future<List<Flashcard>> generateFlashcards(String noteContent, {int count = 10}) async {
    try {
      final systemPrompt = 
          'You are a flashcard generator. Extract key concepts from notes and return STRICT JSON only: '
          '{"cards":[{"term":"Key term...","definition":"Detailed definition..."}]} with exactly $count key concept pairs.';

      final userPrompt = 'Extract $count flashcards from:\n\n$noteContent';

      final body = {
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt}
          ]
        },
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': userPrompt}
            ]
          }
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
          'temperature': 0.3,
        }
      };

      final response = await _dio.post(
        _getEndpoint('gemini-1.5-flash'),
        data: body,
      );

      final jsonText = _extractText(response.data);
      final cleanJson = jsonText.replaceAll(RegExp(r'```json|```'), '').trim();
      
      final Map<String, dynamic> parsed = jsonDecode(cleanJson);
      final List<dynamic> cardsJson = parsed['cards'] ?? [];
      
      return cardsJson.map((c) => Flashcard.fromJson(Map<String, dynamic>.from(c))).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to generate flashcards: $e');
    }
  }

  // --- OCR Image to Text ---
  Future<String> ocrImage(String base64Image) async {
    try {
      // Clean up base64 prefix if present
      String mimeType = 'image/jpeg';
      String base64Data = base64Image;
      
      if (base64Image.startsWith('data:')) {
        final parts = base64Image.split(';base64,');
        if (parts.length == 2) {
          mimeType = parts[0].substring(5); // Remove 'data:'
          base64Data = parts[1];
        }
      }

      final body = {
        'contents': [
          {
            'parts': [
              {
                'inlineData': {
                  'mimeType': mimeType,
                  'data': base64Data
                }
              },
              {
                'text': 'Extract all readable text from this image, preserving structure. Return plain text only.'
              }
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.1,
        }
      };

      final response = await _dio.post(
        _getEndpoint('gemini-1.5-flash'),
        data: body,
      );

      return _extractText(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('OCR extraction failed: $e');
    }
  }

  // --- Helper Methods ---
  String _extractText(dynamic responseData) {
    try {
      final candidates = responseData['candidates'] as List;
      final parts = candidates[0]['content']['parts'] as List;
      return parts[0]['text'] as String;
    } catch (e) {
      throw Exception('Failed to parse AI response. Raw payload: $responseData');
    }
  }

  Exception _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    
    if (status == 400) {
      return Exception('Invalid request context. The model couldn\'t parse the input.');
    } else if (status == 403) {
      return Exception('API key verification failed. Check that GEMINI_API_KEY is correct.');
    } else if (status == 429) {
      return Exception('Rate limit reached. Please wait a bit before requesting again.');
    } else if (status == 500 || status == 503) {
      return Exception('Gemini servers are currently busy. Try again in a moment.');
    }
    
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timed out. Please check your network connection.');
    }

    return Exception('AI connection error: ${e.message ?? 'Unknown error'}');
  }
}
