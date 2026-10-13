import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/location_service.dart';
import '../../../widgets/blurred_background_blobs.dart';
import 'widgets/ai_assist_card.dart';
import 'widgets/home_header.dart';
import 'widgets/services_grid.dart';
import 'widgets/top_rated_strip.dart';

/// Main Home Screen for igotuu
/// Scrollable top-to-bottom layout:
/// 1. Header (Logo + Glass location button)
/// 2. Pick a service (2x2 glass panels + More)
/// 3. Top rated near you (Auto-scrolling horizontal glass strip)
/// 4. AI assist card (Find your problem, voice, player, camera, submit)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentAddress = AppConstants.defaultAddress;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final saved = await LocationService.instance.getSavedAddress();
    if (mounted) {
      setState(() {
        _currentAddress = saved;
      });
    }
  }

  void _onAddressChanged(String newAddress) {
    setState(() {
      _currentAddress = newAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlurredBackgroundBlobs(
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          // Bottom padding ensures content scrolls completely above the floating glass bar
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header
              HomeHeader(
                currentAddress: _currentAddress,
                onAddressChanged: _onAddressChanged,
              ),

              const SizedBox(height: 16),

              // 2. AI Assist Card ("Find your problem?") - placed first per requirement
              const AiAssistCard(),

              const SizedBox(height: 24),

              // 3. The 4 panels: Plumber, Electrician, Carpenter, Mechanic
              const ServicesGrid(),

              const SizedBox(height: 26),

              // 4. Service provider train moving sideways continuously
              const TopRatedStrip(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
