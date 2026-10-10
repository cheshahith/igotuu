import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../widgets/frosted_glass.dart';

class AiAssistCard extends StatefulWidget {
  const AiAssistCard({super.key});

  @override
  State<AiAssistCard> createState() => _AiAssistCardState();
}

class _AiAssistCardState extends State<AiAssistCard>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ImagePicker _imagePicker = ImagePicker();

  // State flags
  String _selectedLanguageCode = 'en_US';
  bool _isSpeechInitialized = false;
  bool _isListening = false;
  bool _isRecording = false;
  String? _recordedAudioPath;
  bool _isPlayingAudio = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerPositionSubscription;
  StreamSubscription? _playerDurationSubscription;

  // Camera image thumbnail
  XFile? _capturedImage;

  // Pulse animation for recording state
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initSpeech();
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _playerCompleteSubscription =
        _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
          _audioPosition = Duration.zero;
        });
      }
    });

    _playerPositionSubscription =
        _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _audioPosition = position;
        });
      }
    });

    _playerDurationSubscription =
        _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _audioDuration = duration;
        });
      }
    });
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (_isListening && mounted) {
              _stopListeningAndRecording();
            }
          }
        },
        onError: (errorNotification) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _isSpeechInitialized = available;
        });
      }
    } catch (_) {
      // Graceful fallback if device/emulator lacks speech support
      if (mounted) {
        setState(() {
          _isSpeechInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _playerCompleteSubscription?.cancel();
    _playerPositionSubscription?.cancel();
    _playerDurationSubscription?.cancel();
    super.dispose();
  }

  bool get _hasTextOrVoice =>
      _textController.text.trim().isNotEmpty || _recordedAudioPath != null;

  // Toggle voice listening + recording
  Future<void> _toggleVoiceRecording() async {
    if (_isListening || _isRecording) {
      await _stopListeningAndRecording();
    } else {
      await _startListeningAndRecording();
    }
  }

  Future<void> _startListeningAndRecording() async {
    // 1. Check microphone permission via record
    final hasMicPermission = await _audioRecorder.hasPermission();
    if (!hasMicPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Microphone permission is required to record voice problems.'),
          ),
        );
      }
      return;
    }

    try {
      // 2. Start audio file recording
      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/igotuu_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );

      // 3. Start Speech-to-Text transcription if initialized
      if (!_isSpeechInitialized) {
        await _initSpeech();
      }

      if (_isSpeechInitialized) {
        await _speech.listen(
          onResult: (result) {
            if (mounted) {
              setState(() {
                _textController.text = result.recognizedWords;
                // Move cursor to end
                _textController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _textController.text.length),
                );
              });
            }
          },
          listenOptions: stt.SpeechListenOptions(
            localeId: _selectedLanguageCode,
            listenFor: const Duration(seconds: 45),
            pauseFor: const Duration(seconds: 4),
          ),
        );
      }

      if (mounted) {
        setState(() {
          _isListening = true;
          _isRecording = true;
          _recordedAudioPath = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start recording: $e'),
          ),
        );
      }
    }
  }

  Future<void> _stopListeningAndRecording() async {
    String? path;
    try {
      if (_isRecording) {
        path = await _audioRecorder.stop();
      }
      if (_isListening) {
        await _speech.stop();
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isListening = false;
        _isRecording = false;
        if (path != null && path.isNotEmpty) {
          _recordedAudioPath = path;
        }
      });
    }
  }

  // Play / Pause recorded voice preview
  Future<void> _toggleAudioPlayback() async {
    if (_recordedAudioPath == null) return;

    if (_isPlayingAudio) {
      await _audioPlayer.pause();
      if (mounted) setState(() => _isPlayingAudio = false);
    } else {
      if (kIsWeb) {
        await _audioPlayer.play(UrlSource(_recordedAudioPath!));
      } else {
        await _audioPlayer.play(DeviceFileSource(_recordedAudioPath!));
      }
      if (mounted) setState(() => _isPlayingAudio = true);
    }
  }

  // Retake voice
  Future<void> _retakeVoice() async {
    await _audioPlayer.stop();
    if (_recordedAudioPath != null && !kIsWeb) {
      try {
        final file = File(_recordedAudioPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _recordedAudioPath = null;
        _isPlayingAudio = false;
        _audioPosition = Duration.zero;
        _audioDuration = Duration.zero;
      });
    }
  }

  // Capture photo from camera
  Future<void> _captureCameraPhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        setState(() {
          _capturedImage = photo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera access error or permission denied: $e'),
          ),
        );
      }
    }
  }

  void _removeCapturedImage() {
    setState(() {
      _capturedImage = null;
    });
  }

  void _handleSubmit() {
    if (!_hasTextOrVoice) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.lightSage,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'AI Diagnosis coming soon! Matching your issue with top verified pros.',
                style: AppTypography.bodySmall(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.textDark,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FrostedGlass(
        borderRadius: 28,
        blurSigma: 20,
        padding: const EdgeInsets.all(20),
        fillColor: Colors.white.withValues(alpha: 0.38),
        borderColor: Colors.white.withValues(alpha: 0.65),
        shadows: [
          const BoxShadow(
            color: Color(0x1626332A),
            blurRadius: 26,
            spreadRadius: 0,
            offset: Offset(0, 10),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Title Row: "Find your problem?" with AI sparkles icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.sageDark,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Find your problem?',
                    style: AppTypography.headingMedium(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'AI Assist',
                    style: AppTypography.label(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sageDark,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Multi-line text field container
            FrostedGlass(
              borderRadius: 20,
              blurSigma: 16,
              fillColor: Colors.white.withValues(alpha: 0.45),
              borderColor: Colors.white.withValues(alpha: 0.70),
              padding: const EdgeInsets.all(14),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                minLines: 3,
                onChanged: (_) => setState(() {}),
                style: AppTypography.bodyMedium(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tell us what\'s wrong...',
                  hintStyle: AppTypography.bodyMedium(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Language Selection Chips: English, Tamil, Hindi
            Row(
              children: [
                Text(
                  'Speak in:',
                  style: AppTypography.bodySmall(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: AppConstants.supportedLanguages.map((lang) {
                      final isSelected =
                          _selectedLanguageCode == lang['code'];
                      return _buildLanguageChip(
                        name: lang['name']!,
                        code: lang['code']!,
                        isSelected: isSelected,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Voice Control and Action Bar
            Row(
              children: [
                // Mic Button (Tap to start / stop)
                _buildMicButton(),

                const SizedBox(width: 12),

                // Audio recording status hint or player status
                Expanded(
                  child: Text(
                    _isListening || _isRecording
                        ? 'Listening & recording... Tap mic to stop'
                        : (_recordedAudioPath != null
                            ? 'Audio recorded. Listen below'
                            : 'Tap mic to speak your problem'),
                    style: AppTypography.bodySmall(
                      fontSize: 12,
                      color: _isListening
                          ? AppColors.recordingRed
                          : AppColors.textMuted,
                      fontWeight:
                          _isListening ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),

                // Animated Camera Icon (Appears only once there is text or voice!)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: _hasTextOrVoice
                      ? _buildCameraButton()
                      : const SizedBox.shrink(key: ValueKey('empty_camera')),
                ),
              ],
            ),

            // Small Audio Player (Appears after stopping recording)
            if (_recordedAudioPath != null) ...[
              const SizedBox(height: 14),
              _buildAudioPlayerBar(),
            ],

            // Photo Thumbnail Preview (Appears after capturing photo)
            if (_capturedImage != null) ...[
              const SizedBox(height: 14),
              _buildPhotoThumbnail(),
            ],

            const SizedBox(height: 18),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip({
    required String name,
    required String code,
    required bool isSelected,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Select $name language for voice input',
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLanguageCode = code;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.sage.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.sageDark
                  : Colors.white.withValues(alpha: 0.6),
              width: 1.1,
            ),
          ),
          child: Text(
            name,
            style: AppTypography.label(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.sageDark : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton() {
    final isRecordingActive = _isListening || _isRecording;

    Widget buttonContent = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isRecordingActive
            ? AppColors.recordingRed.withValues(alpha: 0.20)
            : AppColors.sage.withValues(alpha: 0.22),
        shape: BoxShape.circle,
        border: Border.all(
          color: isRecordingActive
              ? AppColors.recordingRed
              : AppColors.sageDark.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          isRecordingActive ? Icons.stop_rounded : Icons.mic_rounded,
          color:
              isRecordingActive ? AppColors.recordingRed : AppColors.sageDark,
          size: 24,
        ),
      ),
    );

    if (isRecordingActive) {
      buttonContent = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        ),
        child: buttonContent,
      );
    }

    return FrostedGlass(
      borderRadius: 24,
      blurSigma: 16,
      fillColor: Colors.transparent,
      borderColor: Colors.transparent,
      onTap: _toggleVoiceRecording,
      semanticLabel: isRecordingActive
          ? 'Stop recording voice'
          : 'Start recording voice',
      child: buttonContent,
    );
  }

  Widget _buildCameraButton() {
    return FrostedGlass(
      key: const ValueKey('camera_button_active'),
      borderRadius: 24,
      blurSigma: 18,
      fillColor: AppColors.lightSage.withValues(alpha: 0.40),
      borderColor: AppColors.sage.withValues(alpha: 0.55),
      onTap: _captureCameraPhoto,
      semanticLabel: 'Take a photo of the problem area with camera',
      child: const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Icon(
            Icons.camera_alt_rounded,
            color: AppColors.sageDark,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildAudioPlayerBar() {
    final timeDisplay = _audioDuration > Duration.zero
        ? '${_formatDuration(_audioPosition)} / ${_formatDuration(_audioDuration)}'
        : _formatDuration(_audioPosition);

    return FrostedGlass(
      borderRadius: 18,
      blurSigma: 16,
      fillColor: Colors.white.withValues(alpha: 0.48),
      borderColor: AppColors.sage.withValues(alpha: 0.35),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Play / Pause Button
          IconButton(
            onPressed: _toggleAudioPlayback,
            icon: Icon(
              _isPlayingAudio
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_fill_rounded,
              color: AppColors.sageDark,
              size: 34,
            ),
            tooltip: _isPlayingAudio ? 'Pause preview' : 'Play voice preview',
          ),

          const SizedBox(width: 8),

          // Audio Info / Time display
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Voice Note Recorded',
                  style: AppTypography.headingSmall(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isPlayingAudio ? 'Playing: $timeDisplay' : 'Ready ($timeDisplay)',
                  style: AppTypography.bodySmall(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Retake button to discard & re-record
          TextButton.icon(
            onPressed: _retakeVoice,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 16,
              color: AppColors.recordingRed,
            ),
            label: Text(
              'Retake',
              style: AppTypography.label(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.recordingRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail() {
    return FrostedGlass(
      borderRadius: 18,
      blurSigma: 16,
      fillColor: Colors.white.withValues(alpha: 0.48),
      borderColor: AppColors.sage.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          // Thumbnail image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 58,
              height: 58,
              child: kIsWeb
                  ? Image.network(
                      _capturedImage!.path,
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(_capturedImage!.path),
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // Photo details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Problem Photo Attached',
                  style: AppTypography.headingSmall(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'High resolution capture ready',
                  style: AppTypography.bodySmall(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Retake option
          TextButton.icon(
            onPressed: _captureCameraPhoto,
            icon: const Icon(
              Icons.camera_alt_outlined,
              size: 15,
              color: AppColors.sageDark,
            ),
            label: Text(
              'Retake',
              style: AppTypography.label(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.sageDark,
              ),
            ),
          ),

          IconButton(
            onPressed: _removeCapturedImage,
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
            tooltip: 'Remove photo',
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final enabled = _hasTextOrVoice;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: enabled ? 1.0 : 0.45,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: enabled
                ? [
                    AppColors.sageDark,
                    AppColors.sage,
                  ]
                : [
                    AppColors.sageDark.withValues(alpha: 0.6),
                    AppColors.sage.withValues(alpha: 0.6),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.sage.withValues(alpha: 0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? _handleSubmit : null,
            borderRadius: BorderRadius.circular(20),
            splashColor: Colors.white.withValues(alpha: 0.2),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Analyze & Find Workers',
                    style: AppTypography.label(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
