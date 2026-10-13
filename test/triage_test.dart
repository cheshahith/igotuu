import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:igotuu/features/triage/data/mock_triage_service.dart';
import 'package:igotuu/features/triage/domain/models/triage_result.dart';
import 'package:igotuu/features/triage/domain/services/ai_triage_service.dart';
import 'triage_samples.dart';

void main() {
  group('TriageResult Model & JSON Parsing', () {
    test('parses complete JSON payload accurately', () {
      final json = {
        'trade': 'plumber',
        'confidence': 'high',
        'summary': 'குழாய் உடைந்து தண்ணீர் கசிகிறது.',
        'summary_en': 'Burst pipe leaking water under bathroom sink.',
        'transcript': 'குழாய் உடைந்து தண்ணீர் கசிகிறது.',
        'detected_language': 'ta',
        'urgency': 'emergency',
        'safety_tip': 'Turn off the main overhead tank valve immediately.',
        'follow_up_question': null,
      };

      final result = TriageResult.fromJson(json);

      expect(result.trade, TradeType.plumber);
      expect(result.confidence, ConfidenceLevel.high);
      expect(result.summary, 'குழாய் உடைந்து தண்ணீர் கசிகிறது.');
      expect(result.summaryEn, 'Burst pipe leaking water under bathroom sink.');
      expect(result.transcript, 'குழாய் உடைந்து தண்ணீர் கசிகிறது.');
      expect(result.detectedLanguage, 'ta');
      expect(result.urgency, UrgencyLevel.emergency);
      expect(result.safetyTip, 'Turn off the main overhead tank valve immediately.');
      expect(result.followUpQuestion, isNull);
      expect(result.isUnknownOrLowConfidence, isFalse);

      final encoded = result.toJson();
      expect(encoded['trade'], 'plumber');
      expect(encoded['urgency'], 'emergency');
    });

    test('handles unknown trades and null optional fields gracefully', () {
      final json = {
        'trade': 'space_wizard',
        'confidence': 'low',
        'summary': 'Unclear request',
        'summary_en': 'Unclear request',
        'transcript': 'hello test',
        'detected_language': 'en',
        'urgency': 'low',
        'safety_tip': null,
        'follow_up_question': 'Can you provide more details?',
      };

      final result = TriageResult.fromJson(json);

      expect(result.trade, TradeType.unknown);
      expect(result.confidence, ConfidenceLevel.low);
      expect(result.safetyTip, isNull);
      expect(result.followUpQuestion, 'Can you provide more details?');
      expect(result.isUnknownOrLowConfidence, isTrue);
    });

    test('TradeType fromString parses variations of trades', () {
      expect(TradeType.fromString('plumber'), TradeType.plumber);
      expect(TradeType.fromString('ELECTRICIAN'), TradeType.electrician);
      expect(TradeType.fromString('ac_repair'), TradeType.acRepair);
      expect(TradeType.fromString('ac repair'), TradeType.acRepair);
      expect(TradeType.fromString('carpenter'), TradeType.carpenter);
      expect(TradeType.fromString('mechanic'), TradeType.mechanic);
      expect(TradeType.fromString('random_service'), TradeType.unknown);
      expect(TradeType.fromString(null), TradeType.unknown);
    });
  });

  group('AiTriageService Input Validation', () {
    test('throws ArgumentError when all inputs are null or empty', () {
      expect(
        () => AiTriageService.validateInputs(
          text: null,
          audio: null,
          image: null,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => AiTriageService.validateInputs(
          text: '   ',
          audio: Uint8List(0),
          image: Uint8List(0),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('passes validation when at least one input is provided', () {
      expect(
        () => AiTriageService.validateInputs(text: 'Water pipe leak'),
        returnsNormally,
      );

      expect(
        () => AiTriageService.validateInputs(audio: Uint8List.fromList([1, 2, 3])),
        returnsNormally,
      );

      expect(
        () => AiTriageService.validateInputs(image: Uint8List.fromList([1, 2, 3])),
        returnsNormally,
      );
    });
  });

  group('MockTriageService Tests', () {
    const service = MockTriageService();

    test('routes English plumbing problem to plumber', () async {
      final result = await service.triage(
        text: 'Kitchen sink pipe is leaking water all over the floor',
      );

      expect(result.trade, TradeType.plumber);
      expect(result.confidence, ConfidenceLevel.high);
      expect(result.safetyTip, isNotNull);
    });

    test('routes Tanglish electrical problem to electrician with high urgency', () async {
      final result = await service.triage(
        text: 'Switch board la spark varudhu and shock adikudhu!',
      );

      expect(result.trade, TradeType.electrician);
      expect(result.confidence, ConfidenceLevel.high);
      expect(result.urgency, UrgencyLevel.emergency);
      expect(result.safetyTip, contains('breaker'));
    });

    test('routes AC cooling issue to ac_repair', () async {
      final result = await service.triage(
        text: 'Hall AC is running but no cooling at all, gas refill needed',
      );

      expect(result.trade, TradeType.acRepair);
      expect(result.confidence, ConfidenceLevel.high);
    });

    test('routes Tamil wooden door lock problem to carpenter', () async {
      final result = await service.triage(
        text: 'வீட்டு முன்பக்க மர கதவு பூட்டு மாட்டிக்கொண்டது',
      );

      expect(result.trade, TradeType.carpenter);
      expect(result.confidence, ConfidenceLevel.high);
    });

    test('routes car battery dead issue to mechanic', () async {
      final result = await service.triage(
        text: 'Office poganum car engine start aagala battery down vandi la',
      );

      expect(result.trade, TradeType.mechanic);
      expect(result.confidence, ConfidenceLevel.high);
    });

    test('returns unknown with follow-up question for ambiguous statements', () async {
      final result = await service.triage(
        text: 'Edo oru problem aaiduchu therila enna nu',
      );

      expect(result.trade, TradeType.unknown);
      expect(result.confidence, ConfidenceLevel.low);
      expect(result.followUpQuestion, isNotNull);
    });

    test('handles photo-only triage request', () async {
      final result = await service.triage(
        image: Uint8List.fromList([1, 2, 3, 4, 5]),
      );

      expect(result.trade, isNot(TradeType.unknown));
      expect(result.confidence, isNotNull);
    });
  });

  group('30 Triage Benchmark Samples Verification', () {
    const service = MockTriageService();

    test('contains 30 curated samples across English, Tamil, Tanglish', () {
      expect(triageSamples.length, 30);
      final trades = triageSamples.map((s) => s.expectedTrade).toSet();
      expect(trades.contains(TradeType.plumber), isTrue);
      expect(trades.contains(TradeType.electrician), isTrue);
      expect(trades.contains(TradeType.carpenter), isTrue);
      expect(trades.contains(TradeType.acRepair), isTrue);
      expect(trades.contains(TradeType.mechanic), isTrue);
      expect(trades.contains(TradeType.unknown), isTrue);
    });

    test('evaluates mock service against benchmark samples with high accuracy', () async {
      int matchedCount = 0;

      for (final sample in triageSamples) {
        final result = await service.triage(text: sample.problemText);
        if (result.trade == sample.expectedTrade) {
          matchedCount++;
        }
      }

      final accuracy = matchedCount / triageSamples.length;
      expect(accuracy, greaterThanOrEqualTo(0.90),
          reason: 'Accuracy should exceed 90% across benchmark samples');
    });
  });
}
