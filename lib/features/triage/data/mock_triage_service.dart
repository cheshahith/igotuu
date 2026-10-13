import 'dart:typed_data';
import '../domain/models/triage_result.dart';
import '../domain/services/ai_triage_service.dart';

/// Offline mock implementation of [AiTriageService].
/// Used for unit testing, when Firebase is unconfigured, or during offline testing.
class MockTriageService implements AiTriageService {
  const MockTriageService();

  @override
  Future<TriageResult> triage({
    String? text,
    Uint8List? audio,
    String? audioMime,
    Uint8List? image,
  }) async {
    AiTriageService.validateInputs(
      text: text,
      audio: audio,
      image: image,
    );

    // Simulate short network latency for realism
    await Future.delayed(const Duration(milliseconds: 250));

    final input = (text ?? '').toLowerCase().trim();
    final transcript = text ?? (audio != null ? 'Voice description of problem' : 'Photo problem inspection');

    // 1. AC Repair checks (higher specificity than generic water leaks or switch mentions)
    final hasElectricalFault = _matchesKeywords(input, ['mcb', 'tripping', 'trip', 'shock', 'spark', 'தீப்பொறி', 'short circuit']);
    if (!hasElectricalFault && _matchesKeywords(input, [
      'ac', 'air conditioner', 'cooling', 'ice forming', 'compressor',
      'gas leak', 'gas filling', 'gas refill', 'ac not cooling', 'split ac', 'ac smell',
      'water dripping from ac', 'cool aagala', 'kulirchi illa', 'indoor unit',
      'outdoor unit',
      'ஏசி', 'குளிர்ந்த காற்று', 'கேஸ்', 'உட்புற யூனிட்',
    ])) {
      return TriageResult(
        trade: TradeType.acRepair,
        confidence: ConfidenceLevel.high,
        summary: input.contains('kulirchi') || input.contains('aagala') || input.contains('ஏசி')
            ? 'ஏசி கூலிங் அல்லது யூனிட் பழுது கண்டறியப்பட்டது.'
            : 'Air conditioner cooling, water leak, or compressor fault identified.',
        summaryEn: 'Air conditioner cooling, water leak, or compressor fault identified.',
        transcript: transcript,
        detectedLanguage: _detectLang(input),
        urgency: UrgencyLevel.medium,
        safetyTip: 'Turn off the AC unit to prevent compressor coil burnout.',
      );
    }

    // 2. Mechanic checks (automotive & two-wheeler domain, evaluated before generic wire/battery)
    if (_matchesKeywords(input, [
      'car', 'bike', 'scooter', 'engine', 'brake', 'clutch', 'tyre',
      'tire', 'puncture', 'starting problem', 'battery down', 'oil leak car',
      'vandi', 'start aagala', 'wheel', 'radiator', 'chain', 'silencer', 'two wheeler',
      'வாகனம்', 'ஸ்டார்ட்', 'கிக்', 'டயர்', 'பிரேக்', 'பேட்டரி',
    ])) {
      final isEmergency = input.contains('brake fail') || input.contains('smoke from engine');
      return TriageResult(
        trade: TradeType.mechanic,
        confidence: ConfidenceLevel.high,
        summary: input.contains('vandi') || input.contains('வாகனம்')
            ? 'வாகன பழுது அல்லது இன்ஜின் கோளாறு கண்டறியப்பட்டது.'
            : 'Vehicle engine, tire puncture, or mechanical breakdown identified.',
        summaryEn: 'Vehicle engine, tire puncture, or mechanical breakdown identified.',
        transcript: transcript,
        detectedLanguage: _detectLang(input),
        urgency: isEmergency ? UrgencyLevel.emergency : UrgencyLevel.medium,
        safetyTip: isEmergency
            ? 'Park safely on the curb and turn on hazard flashers.'
            : 'Do not continuously crank the ignition to protect the starter motor.',
      );
    }

    // 3. Electrician checks
    if (_matchesKeywords(input, [
      'spark', 'shock', 'mcb', 'switch', 'fuse', 'breaker', 'short circuit',
      'wire', 'smoke', 'voltage', 'current', 'power', 'tripping', 'fan not working',
      'plug', 'socket', 'bulb', 'light flicker', 'current varala', 'shock adikudhu',
      'current illa', 'bijli', 'meter box',
      'சுவிட்ச்', 'போர்டு', 'தீப்பொறி', 'கருகிய', 'கரண்ட்', 'பியூஸ்', 'மின்சாரம்',
    ])) {
      final isEmergency = input.contains('spark') || input.contains('smoke') || input.contains('shock') || input.contains('தீப்பொறி');
      return TriageResult(
        trade: TradeType.electrician,
        confidence: ConfidenceLevel.high,
        summary: input.contains('current') || input.contains('shock') || input.contains('மின்சாரம்')
            ? 'மின்சார கோளாறு அல்லது சுவிட்ச் பிரச்சனை கண்டறியப்பட்டது.'
            : 'Electrical circuit, breaker, or wiring malfunction identified.',
        summaryEn: 'Electrical circuit, breaker, or wiring malfunction identified.',
        transcript: transcript,
        detectedLanguage: _detectLang(input),
        urgency: isEmergency ? UrgencyLevel.emergency : UrgencyLevel.high,
        safetyTip: isEmergency
            ? 'Switch off the main power breaker immediately and do not touch wet switches.'
            : 'Avoid running high-power appliances on this circuit until inspected.',
      );
    }

    // 4. Plumber checks
    if (_matchesKeywords(input, [
      'leak', 'pipe', 'tap', 'sink', 'drain', 'flush', 'toilet', 'shower',
      'faucet', 'clog', 'sewage', 'motor', 'tank overflow', 'water',
      'thanni', 'kulai', 'kuzhai', 'otha', 'leak aagudhu', 'paani',
      'தண்ணீர்', 'குழாய்', 'பைப்', 'சிங்க்', 'மோட்டார்', 'கசி',
    ])) {
      final isEmergency = input.contains('burst') || input.contains('flooding') || input.contains('overflow') || input.contains('fountain');
      return TriageResult(
        trade: TradeType.plumber,
        confidence: ConfidenceLevel.high,
        summary: input.contains('thanni') || input.contains('தண்ணீர்')
            ? 'தண்ணீர் கசிவு அல்லது குழாய் பிரச்சனை கண்டறியப்பட்டது.'
            : 'Plumbing leak or pipe fixture issue identified.',
        summaryEn: 'Plumbing leak or pipe fixture issue identified.',
        transcript: transcript,
        detectedLanguage: _detectLang(input),
        urgency: isEmergency ? UrgencyLevel.emergency : UrgencyLevel.medium,
        safetyTip: isEmergency
            ? 'Turn off the main overhead tank valve to prevent room flooding.'
            : 'Keep a bucket underneath the leak to prevent floor damage.',
      );
    }

    // 5. Carpenter checks
    if (_matchesKeywords(input, [
      'door', 'wood', 'table', 'chair', 'cupboard', 'hinge', 'wardrobe',
      'lock', 'handle', 'drawer', 'shelf', 'furniture', 'maram', 'kadhavu',
      'almarah', 'beero', 'wood polish', 'wood termite',
      'மர', 'கதவு', 'பூட்டு', 'அலமாரி', 'கீல்', 'கைப்பிடி', 'மேஜை',
    ])) {
      return TriageResult(
        trade: TradeType.carpenter,
        confidence: ConfidenceLevel.high,
        summary: input.contains('kadhavu') || input.contains('maram') || input.contains('மர')
            ? 'மர வேலை அல்லது கதவு/பூட்டு பழுது கண்டறியப்பட்டது.'
            : 'Woodwork, door alignment, or furniture repair issue identified.',
        summaryEn: 'Woodwork, door alignment, or furniture repair issue identified.',
        transcript: transcript,
        detectedLanguage: _detectLang(input),
        urgency: UrgencyLevel.low,
        safetyTip: null,
      );
    }

    // If image only was provided with no text keywords
    if (image != null && input.isEmpty) {
      return TriageResult(
        trade: TradeType.plumber,
        confidence: ConfidenceLevel.medium,
        summary: 'Photo inspection indicates potential plumbing or fixture issue.',
        summaryEn: 'Photo inspection indicates potential plumbing or fixture issue.',
        transcript: transcript,
        detectedLanguage: 'en',
        urgency: UrgencyLevel.medium,
        safetyTip: 'Ensure the area around the appliance remains dry.',
      );
    }

    // 6. Unknown fallback
    return TriageResult(
      trade: TradeType.unknown,
      confidence: ConfidenceLevel.low,
      summary: input.contains('illa') || input.contains('therila')
          ? 'உங்கள் பிரச்சனை தெளிவாக இல்லை.'
          : 'Could not confidently identify the exact trade needed.',
      summaryEn: 'Could not confidently identify the exact trade needed.',
      transcript: transcript,
      detectedLanguage: _detectLang(input),
      urgency: UrgencyLevel.low,
      safetyTip: null,
      followUpQuestion: 'Is this issue related to water/pipes, electricity/wires, furniture, AC, or a vehicle?',
    );
  }

  bool _matchesKeywords(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (kw.length <= 2) {
        if (RegExp(r'\b' + RegExp.escape(kw) + r'\b', caseSensitive: false).hasMatch(text)) {
          return true;
        }
      } else {
        if (text.contains(kw)) return true;
      }
    }
    return false;
  }

  String _detectLang(String input) {
    if (input.contains('thanni') ||
        input.contains('aagala') ||
        input.contains('kadhavu') ||
        input.contains('vandi') ||
        input.contains('therila') ||
        input.contains('varala') ||
        RegExp(r'[\u0B80-\u0BFF]').hasMatch(input)) {
      return 'ta';
    }
    if (input.contains('paani') ||
        input.contains('bijli') ||
        RegExp(r'[\u0900-\u097F]').hasMatch(input)) {
      return 'hi';
    }
    return 'en';
  }
}
