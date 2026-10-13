import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import '../domain/models/triage_result.dart';
import '../domain/services/ai_triage_service.dart';
import 'mock_triage_service.dart';

/// Custom exception representing user-friendly triage failure modes
/// that offer fallback to manual trade selection.
class TriageException implements Exception {
  final String message;
  final String? technicalDetails;
  final bool canFallbackManually;

  const TriageException({
    required this.message,
    this.technicalDetails,
    this.canFallbackManually = true,
  });

  @override
  String toString() => message;
}

/// Firebase AI Logic implementation using the Gemini Developer API (`gemini-3.8-flash`).
class FirebaseAiTriageService implements AiTriageService {
  /// Featured model from official Firebase AI Logic documentation
  static const String modelName = 'gemini-3.8-flash';

  final GenerativeModel? _model;
  final AiTriageService _fallbackService;

  // Rate limiting & concurrency controls
  bool _isRequestInProgress = false;
  final List<DateTime> _recentRequestTimestamps = [];
  static const int _maxRequestsPerMinute = 5;
  static const Duration _requestTimeout = Duration(seconds: 20);

  FirebaseAiTriageService({
    GenerativeModel? model,
    AiTriageService? fallbackService,
  })  : _model = model,
        _fallbackService = fallbackService ?? const MockTriageService();

  /// Factory creating the production instance configured with the Gemini Developer API.
  factory FirebaseAiTriageService.create() {
    try {
      final googleAI = FirebaseAI.googleAI();

      final schema = Schema.object(
        properties: {
          'trade': Schema.enumString(
            enumValues: [
              'plumber',
              'electrician',
              'carpenter',
              'ac_repair',
              'mechanic',
              'unknown',
            ],
            description: 'Exactly one trade from the fixed allowed list.',
          ),
          'confidence': Schema.enumString(
            enumValues: ['high', 'medium', 'low'],
            description: 'Confidence in the trade diagnosis.',
          ),
          'summary': Schema.string(
            description:
                'One concise sentence summarizing the problem in the user detected language.',
          ),
          'summary_en': Schema.string(
            description:
                'One concise sentence summarizing the problem in English.',
          ),
          'transcript': Schema.string(
            description:
                'Transcription of voice input in original language, or repeat of input text.',
          ),
          'detected_language': Schema.string(
            description:
                'Language code (e.g. en, ta, hi, tanglish) of user input.',
          ),
          'urgency': Schema.enumString(
            enumValues: ['low', 'medium', 'high', 'emergency'],
            description: 'Urgency classification of the hazard or problem.',
          ),
          'safety_tip': Schema.string(
            nullable: true,
            description:
                'Generic safety tip only if hazardous; otherwise null. Do NOT give repair steps.',
          ),
          'follow_up_question': Schema.string(
            nullable: true,
            description:
                'One short question to clarify if trade is unknown or confidence is low; otherwise null.',
          ),
        },
        optionalProperties: ['safety_tip', 'follow_up_question'],
      );

      final model = googleAI.generativeModel(
        model: modelName,
        systemInstruction: Content.system(
          'You are an expert home-service triage AI for the "igotuu" app in India.\n'
          'Your job is to route user requests (text, voice audio, or photo) to exactly ONE trade from this fixed list:\n'
          '- plumber\n'
          '- electrician\n'
          '- carpenter\n'
          '- ac_repair\n'
          '- mechanic\n'
          '- unknown\n\n'
          'CRITICAL RULES:\n'
          '1. The input may be in any language (Tamil, Hindi, English, Tanglish, Hinglish).\n'
          '2. Transcribe voice in its original language in "transcript". Provide an English summary in "summary_en".\n'
          '3. Provide "summary" as one clear sentence in the user\'s language.\n'
          '4. NEVER invent a trade outside the 6 allowed values.\n'
          '5. If the problem is unclear or ambiguous, return trade "unknown", confidence "low", and exactly ONE short "follow_up_question".\n'
          '6. Give NO repair instructions. Only generic safety tips (e.g., "switch off the main power", "turn off the main water valve").\n'
          '7. Categorize urgency as low, medium, high, or emergency.',
        ),
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: schema,
          temperature: 0.1,
        ),
      );

      return FirebaseAiTriageService(model: model);
    } catch (e) {
      debugPrint('FirebaseAiTriageService: initializing with fallback: $e');
      return FirebaseAiTriageService(fallbackService: const MockTriageService());
    }
  }

  @override
  Future<TriageResult> triage({
    String? text,
    Uint8List? audio,
    String? audioMime,
    Uint8List? image,
  }) async {
    // 1. Validate inputs
    AiTriageService.validateInputs(
      text: text,
      audio: audio,
      image: image,
    );

    // 2. Concurrency check (allow only one request at a time)
    if (_isRequestInProgress) {
      throw const TriageException(
        message: 'A triage request is already processing. Please wait a moment.',
        canFallbackManually: false,
      );
    }

    // 3. Local Rate limit check (~5 requests per minute)
    final now = DateTime.now();
    _recentRequestTimestamps.removeWhere(
      (ts) => now.difference(ts) > const Duration(minutes: 1),
    );
    if (_recentRequestTimestamps.length >= _maxRequestsPerMinute) {
      throw const TriageException(
        message:
            'You have reached the local limit of 5 requests per minute. Please choose a trade manually or try again in a minute.',
        canFallbackManually: true,
      );
    }

    _isRequestInProgress = true;
    _recentRequestTimestamps.add(now);

    try {
      // If model is null (e.g. Firebase not configured on platform), use fallback
      if (_model == null) {
        return await _fallbackService
            .triage(text: text, audio: audio, audioMime: audioMime, image: image)
            .timeout(_requestTimeout);
      }

      // 4. Build multimodal prompt parts (WITHOUT persisting or logging content)
      final parts = <Part>[];

      if (text != null && text.trim().isNotEmpty) {
        parts.add(TextPart('Problem description: ${text.trim()}'));
      }

      if (audio != null && audio.isNotEmpty) {
        final mime = audioMime ?? 'audio/m4a';
        parts.add(InlineDataPart(mime, audio));
      }

      if (image != null && image.isNotEmpty) {
        parts.add(InlineDataPart('image/jpeg', image));
      }

      // 5. Send to Gemini with 20-second timeout
      final response = await _model
          .generateContent([Content.multi(parts)])
          .timeout(_requestTimeout);

      final rawText = response.text;
      if (rawText == null || rawText.trim().isEmpty) {
        throw const TriageException(
          message:
              'No response received from AI triage. Please select a trade manually.',
        );
      }

      // 6. Parse structured JSON
      final decoded = jsonDecode(rawText) as Map<String, dynamic>;
      return TriageResult.fromJson(decoded);
    } on TimeoutException {
      throw const TriageException(
        message:
            'AI triage timed out (took longer than 20 seconds). Please check your connection or choose a trade manually.',
      );
    } on SocketException {
      throw const TriageException(
        message:
            'No internet connection detected. Please check your network or choose a trade manually.',
      );
    } on FirebaseAIException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('quota') || msg.contains('resource_exhausted') || msg.contains('429')) {
        throw TriageException(
          message:
              'AI service quota exceeded. Please choose a trade manually.',
          technicalDetails: e.message,
        );
      } else if (msg.contains('app check') || msg.contains('unauthenticated') || msg.contains('401') || msg.contains('403')) {
        throw TriageException(
          message:
              'App Check verification notice. You can select your trade manually.',
          technicalDetails: e.message,
        );
      } else if (msg.contains('safety') || msg.contains('blocked')) {
        throw TriageException(
          message:
              'Input was flagged by safety filters. Please describe your home service issue differently or pick a trade.',
          technicalDetails: e.message,
        );
      }
      throw TriageException(
        message:
            'AI triage is currently unavailable. Please choose your trade manually.',
        technicalDetails: e.message,
      );
    } catch (e) {
      if (e is TriageException) rethrow;

      // Fallback on unexpected errors
      try {
        return await _fallbackService.triage(
          text: text,
          audio: audio,
          audioMime: audioMime,
          image: image,
        );
      } catch (_) {
        throw TriageException(
          message:
              'Unable to triage request: ${e.toString()}. Please choose a trade manually.',
          technicalDetails: e.toString(),
        );
      }
    } finally {
      _isRequestInProgress = false;
    }
  }
}
