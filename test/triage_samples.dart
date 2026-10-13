import 'package:igotuu/features/triage/domain/models/triage_result.dart';

/// Test benchmark model for evaluating AI triage accuracy against Gemini.
class TriageSample {
  final String id;
  final String problemText;
  final String language; // 'English', 'Tamil', 'Tanglish'
  final TradeType expectedTrade;
  final UrgencyLevel expectedUrgency;
  final String contextNote;

  const TriageSample({
    required this.id,
    required this.problemText,
    required this.language,
    required this.expectedTrade,
    required this.expectedUrgency,
    required this.contextNote,
  });
}

/// 30 realistic, curated sample home-service problems across Tamil Nadu / South India
/// covering English, Tamil script, and Tanglish.
const List<TriageSample> triageSamples = [
  // --- Plumber (6 samples) ---
  TriageSample(
    id: 'P01',
    problemText: 'Kitchen sink pipe is leaking water all over the floor continuously.',
    language: 'English',
    expectedTrade: TradeType.plumber,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Standard drainage pipe leak under sink',
  ),
  TriageSample(
    id: 'P02',
    problemText: 'Bathroom tap is completely broken and water is gushing out like a fountain.',
    language: 'English',
    expectedTrade: TradeType.plumber,
    expectedUrgency: UrgencyLevel.emergency,
    contextNote: 'High pressure burst faucet requiring immediate attention',
  ),
  TriageSample(
    id: 'P03',
    problemText: 'குளியலறை குழாயில் தண்ணீர் வரவில்லை, தொட்டி மோட்டார் இயங்கவில்லை.',
    language: 'Tamil',
    expectedTrade: TradeType.plumber,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Bathroom tap dry and water supply issue',
  ),
  TriageSample(
    id: 'P04',
    problemText: 'சமையலறை சிங்க் அடியில் உள்ள பைப் உடைந்து தண்ணீர் கசிகிறது.',
    language: 'Tamil',
    expectedTrade: TradeType.plumber,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Broken drainage pipe under kitchen sink',
  ),
  TriageSample(
    id: 'P05',
    problemText: 'Bathroom la tap leak aagite irukku, thanni full ah waste aagudhu.',
    language: 'Tanglish',
    expectedTrade: TradeType.plumber,
    expectedUrgency: UrgencyLevel.low,
    contextNote: 'Continuous leaking tap causing water waste',
  ),
  TriageSample(
    id: 'P06',
    problemText: 'Overhead water tank pipe burst aaiduchu, terrace la thanni overflow aagudhu!',
    language: 'Tanglish',
    expectedTrade: TradeType.plumber,
    expectedUrgency: UrgencyLevel.emergency,
    contextNote: 'Overhead tank pipe burst and overflow',
  ),

  // --- Electrician (6 samples) ---
  TriageSample(
    id: 'E01',
    problemText: 'Main MCB switch is tripping every time I turn on the geyser or air conditioner.',
    language: 'English',
    expectedTrade: TradeType.electrician,
    expectedUrgency: UrgencyLevel.high,
    contextNote: 'Electrical trip and circuit overload',
  ),
  TriageSample(
    id: 'E02',
    problemText: 'Switch board is sparking and giving burning smell with smoke in living room.',
    language: 'English',
    expectedTrade: TradeType.electrician,
    expectedUrgency: UrgencyLevel.emergency,
    contextNote: 'Active electrical sparking and smoke hazard',
  ),
  TriageSample(
    id: 'E03',
    problemText: 'சுவிட்ச் போர்டில் தீப்பொறி பறக்கிறது, கருகிய வாசனை வருகிறது.',
    language: 'Tamil',
    expectedTrade: TradeType.electrician,
    expectedUrgency: UrgencyLevel.emergency,
    contextNote: 'Sparking switch board with burning smell',
  ),
  TriageSample(
    id: 'E04',
    problemText: 'வீட்டில் இரண்டு அறைகளில் மட்டும் கரண்ட் வரவில்லை, மெயின் பியூஸ் போயிருச்சு போல.',
    language: 'Tamil',
    expectedTrade: TradeType.electrician,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Partial power outage due to blown fuse wire',
  ),
  TriageSample(
    id: 'E05',
    problemText: 'Bedroom ceiling fan speed controller pota shock adikudhu switch la.',
    language: 'Tanglish',
    expectedTrade: TradeType.electrician,
    expectedUrgency: UrgencyLevel.high,
    contextNote: 'Electric shock hazard from regulator switch',
  ),
  TriageSample(
    id: 'E06',
    problemText: 'Heavy rain la meter box pakkathula wire cut aagi current cut aaiduchu.',
    language: 'Tanglish',
    expectedTrade: TradeType.electrician,
    expectedUrgency: UrgencyLevel.high,
    contextNote: 'Damaged electrical meter box wiring',
  ),

  // --- Carpenter (6 samples) ---
  TriageSample(
    id: 'C01',
    problemText: 'Main entrance wooden door lock is jammed and hinges are loose, cannot close properly.',
    language: 'English',
    expectedTrade: TradeType.carpenter,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Jammed entrance door lock and loose hinges',
  ),
  TriageSample(
    id: 'C02',
    problemText: 'Kitchen wooden cabinet hinges broke off and dining table leg is shaky.',
    language: 'English',
    expectedTrade: TradeType.carpenter,
    expectedUrgency: UrgencyLevel.low,
    contextNote: 'Broken cabinet hinge and unstable dining table',
  ),
  TriageSample(
    id: 'C03',
    problemText: 'வீட்டு முன்பக்க மர கதவு பூட்டு மாட்டிக்கொண்டது, திறக்க முடியவில்லை.',
    language: 'Tamil',
    expectedTrade: TradeType.carpenter,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Stuck wooden door lock preventing opening',
  ),
  TriageSample(
    id: 'C04',
    problemText: 'மர அலமாரி கதவு கீல் உடைந்து விட்டது, புது கைப்பிடி பொருத்த வேண்டும்.',
    language: 'Tamil',
    expectedTrade: TradeType.carpenter,
    expectedUrgency: UrgencyLevel.low,
    contextNote: 'Broken wardrobe hinge and handle installation',
  ),
  TriageSample(
    id: 'C05',
    problemText: 'Bedroom door sariya close aagala, frame la urasudhu and lock panna mudiyala.',
    language: 'Tanglish',
    expectedTrade: TradeType.carpenter,
    expectedUrgency: UrgencyLevel.low,
    contextNote: 'Misaligned wooden door rubbing against frame',
  ),
  TriageSample(
    id: 'C06',
    problemText: 'Wood dining table leg loose aagi aattama irukku, screw tighten pannanum.',
    language: 'Tanglish',
    expectedTrade: TradeType.carpenter,
    expectedUrgency: UrgencyLevel.low,
    contextNote: 'Loose furniture joint needing wood carpentry fix',
  ),

  // --- AC Repair (6 samples) ---
  TriageSample(
    id: 'A01',
    problemText: 'Split AC is running and blower is blowing air, but no cooling at all.',
    language: 'English',
    expectedTrade: TradeType.acRepair,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Air conditioner compressor or refrigerant issue',
  ),
  TriageSample(
    id: 'A02',
    problemText: 'Water is dripping heavily inside the room from the indoor AC unit onto the mattress.',
    language: 'English',
    expectedTrade: TradeType.acRepair,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Clogged AC indoor drain tray leaking water',
  ),
  TriageSample(
    id: 'A03',
    problemText: 'ஏசி ஓடுகிறது ஆனால் குளிர்ந்த காற்று வரவில்லை, கேஸ் தீர்ந்து விட்டதா தெரியவில்லை.',
    language: 'Tamil',
    expectedTrade: TradeType.acRepair,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'No cooling from AC unit, suspected gas leak',
  ),
  TriageSample(
    id: 'A04',
    problemText: 'ஏசி உட்புற யூனிட்டில் இருந்து தண்ணீர் உள்ளே சொட்டுகிறது.',
    language: 'Tamil',
    expectedTrade: TradeType.acRepair,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Water dripping from AC unit inside the room',
  ),
  TriageSample(
    id: 'A05',
    problemText: '1.5 ton split AC cooling eh aagala bro, romba heat ah irukku room, gas refill pannanum.',
    language: 'Tanglish',
    expectedTrade: TradeType.acRepair,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Room AC not cooling, needs gas refill',
  ),
  TriageSample(
    id: 'A06',
    problemText: 'Hall AC switch on pannale outdoor unit la irundhu bayangarama sound varudhu.',
    language: 'Tanglish',
    expectedTrade: TradeType.acRepair,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Loud noise from AC outdoor compressor unit',
  ),

  // --- Mechanic (4 samples) ---
  TriageSample(
    id: 'M01',
    problemText: 'Car battery is dead and engine is clicking but not starting in the parking lot.',
    language: 'English',
    expectedTrade: TradeType.mechanic,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Discharged automotive battery needing jump start',
  ),
  TriageSample(
    id: 'M02',
    problemText: 'Two wheeler scooter rear tyre got punctured and brake wire snapped.',
    language: 'English',
    expectedTrade: TradeType.mechanic,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Punctured tire and damaged brake wire on scooter',
  ),
  TriageSample(
    id: 'M03',
    problemText: 'இருசக்கர வாகனம் ஸ்டார்ட் ஆகவில்லை, கிக் ஸ்டார்ட் கூட வேலை செய்யவில்லை.',
    language: 'Tamil',
    expectedTrade: TradeType.mechanic,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Motorcycle not starting with kick or self start',
  ),
  TriageSample(
    id: 'M04',
    problemText: 'Office poganum car engine self start edukkala, battery down aaiduchu vandi la.',
    language: 'Tanglish',
    expectedTrade: TradeType.mechanic,
    expectedUrgency: UrgencyLevel.medium,
    contextNote: 'Car engine failing to crank due to dead battery',
  ),

  // --- Unknown / Ambiguous (2 samples) ---
  TriageSample(
    id: 'U01',
    problemText: 'Something is making a weird rattling noise in the house, not sure what it is.',
    language: 'English',
    expectedTrade: TradeType.unknown,
    expectedUrgency: UrgencyLevel.low,
    contextNote: 'Ambiguous noise requiring follow-up question',
  ),
  TriageSample(
    id: 'U02',
    problemText: 'Edo oru problem aaiduchu bro, enna nu therila konjam help pannunga.',
    language: 'Tanglish',
    expectedTrade: TradeType.unknown,
    expectedUrgency: UrgencyLevel.low,
    contextNote: 'Completely unspecific Tanglish statement',
  ),
];
