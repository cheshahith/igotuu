import 'dart:typed_data';
import '../models/triage_result.dart';

/// Abstract contract for AI triage service.
/// Requires at least one input (text, audio, or image).
abstract class AiTriageService {
  Future<TriageResult> triage({
    String? text,
    Uint8List? audio,
    String? audioMime,
    Uint8List? image,
  });

  /// Utility validator ensuring at least one input parameter is present and non-empty.
  static void validateInputs({
    String? text,
    Uint8List? audio,
    Uint8List? image,
  }) {
    final hasText = text != null && text.trim().isNotEmpty;
    final hasAudio = audio != null && audio.isNotEmpty;
    final hasImage = image != null && image.isNotEmpty;

    if (!hasText && !hasAudio && !hasImage) {
      throw ArgumentError(
        'At least one input (text, voice recording, or photo) is required for AI triage.',
      );
    }
  }
}
