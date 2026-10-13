import 'package:flutter/material.dart';

/// Supported home-service trades strictly routed by the AI triage service.
enum TradeType {
  plumber,
  electrician,
  carpenter,
  acRepair,
  mechanic,
  unknown;

  static TradeType fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'plumber':
        return TradeType.plumber;
      case 'electrician':
        return TradeType.electrician;
      case 'carpenter':
        return TradeType.carpenter;
      case 'ac_repair':
      case 'ac repair':
      case 'acrepair':
        return TradeType.acRepair;
      case 'mechanic':
        return TradeType.mechanic;
      default:
        return TradeType.unknown;
    }
  }

  String toApiString() {
    switch (this) {
      case TradeType.plumber:
        return 'plumber';
      case TradeType.electrician:
        return 'electrician';
      case TradeType.carpenter:
        return 'carpenter';
      case TradeType.acRepair:
        return 'ac_repair';
      case TradeType.mechanic:
        return 'mechanic';
      case TradeType.unknown:
        return 'unknown';
    }
  }

  String get displayName {
    switch (this) {
      case TradeType.plumber:
        return 'Plumber';
      case TradeType.electrician:
        return 'Electrician';
      case TradeType.carpenter:
        return 'Carpenter';
      case TradeType.acRepair:
        return 'AC Repair';
      case TradeType.mechanic:
        return 'Mechanic';
      case TradeType.unknown:
        return 'Specialist';
    }
  }

  IconData get icon {
    switch (this) {
      case TradeType.plumber:
        return Icons.plumbing_rounded;
      case TradeType.electrician:
        return Icons.bolt_rounded;
      case TradeType.carpenter:
        return Icons.carpenter_rounded;
      case TradeType.acRepair:
        return Icons.ac_unit_rounded;
      case TradeType.mechanic:
        return Icons.car_repair_rounded;
      case TradeType.unknown:
        return Icons.help_outline_rounded;
    }
  }
}

/// Confidence level of the AI triage decision.
enum ConfidenceLevel {
  high,
  medium,
  low;

  static ConfidenceLevel fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'high':
        return ConfidenceLevel.high;
      case 'medium':
        return ConfidenceLevel.medium;
      case 'low':
      default:
        return ConfidenceLevel.low;
    }
  }

  String toApiString() => name;
}

/// Urgency level assessed from the problem description.
enum UrgencyLevel {
  low,
  medium,
  high,
  emergency;

  static UrgencyLevel fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'emergency':
        return UrgencyLevel.emergency;
      case 'high':
        return UrgencyLevel.high;
      case 'medium':
        return UrgencyLevel.medium;
      case 'low':
      default:
        return UrgencyLevel.low;
    }
  }

  String get displayName {
    switch (this) {
      case UrgencyLevel.emergency:
        return 'Emergency';
      case UrgencyLevel.high:
        return 'High Urgency';
      case UrgencyLevel.medium:
        return 'Moderate';
      case UrgencyLevel.low:
        return 'Low Urgency';
    }
  }

  Color get badgeColor {
    switch (this) {
      case UrgencyLevel.emergency:
        return const Color(0xFFD32F2F);
      case UrgencyLevel.high:
        return const Color(0xFFE65100);
      case UrgencyLevel.medium:
        return const Color(0xFFE5A122);
      case UrgencyLevel.low:
        return const Color(0xFF3F5A3E);
    }
  }
}

/// Structured AI triage result emitted by the Gemini model.
class TriageResult {
  final TradeType trade;
  final ConfidenceLevel confidence;
  final String summary;
  final String summaryEn;
  final String transcript;
  final String detectedLanguage;
  final UrgencyLevel urgency;
  final String? safetyTip;
  final String? followUpQuestion;

  const TriageResult({
    required this.trade,
    required this.confidence,
    required this.summary,
    required this.summaryEn,
    required this.transcript,
    required this.detectedLanguage,
    required this.urgency,
    this.safetyTip,
    this.followUpQuestion,
  });

  factory TriageResult.fromJson(Map<String, dynamic> json) {
    return TriageResult(
      trade: TradeType.fromString(json['trade'] as String?),
      confidence: ConfidenceLevel.fromString(json['confidence'] as String?),
      summary: (json['summary'] as String?)?.trim() ?? '',
      summaryEn: (json['summary_en'] as String?)?.trim() ?? '',
      transcript: (json['transcript'] as String?)?.trim() ?? '',
      detectedLanguage: (json['detected_language'] as String?)?.trim() ?? 'en',
      urgency: UrgencyLevel.fromString(json['urgency'] as String?),
      safetyTip: (json['safety_tip'] as String?)?.trim(),
      followUpQuestion: (json['follow_up_question'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trade': trade.toApiString(),
      'confidence': confidence.toApiString(),
      'summary': summary,
      'summary_en': summaryEn,
      'transcript': transcript,
      'detected_language': detectedLanguage,
      'urgency': urgency.name,
      'safety_tip': safetyTip,
      'follow_up_question': followUpQuestion,
    };
  }

  bool get isUnknownOrLowConfidence =>
      trade == TradeType.unknown || confidence == ConfidenceLevel.low;
}
