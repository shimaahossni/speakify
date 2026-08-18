import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice_to_text/core/constants/app_strings.dart';
import 'package:voice_to_text/core/theme/app_theme.dart';
import 'package:voice_to_text/widgets/action_buttons_row.dart';
import 'package:voice_to_text/widgets/animated_mic_button.dart';
import 'package:voice_to_text/widgets/status_indicator.dart';
import 'package:voice_to_text/widgets/transcription_card.dart';
import 'package:voice_to_text/widgets/waveform_indicator.dart';

class Speakify extends StatefulWidget {
  const Speakify({super.key});

  @override
  State<Speakify> createState() => _SpeakifyState();
}

class _SpeakifyState extends State<Speakify> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  bool _isListening = false;
  String? _currentLocaleId;
  List<stt.LocaleName> _availableLocales = [];

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _configureTts();
  }

  Future<bool> _ensureMicPermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;

    // Ask for permission if not already determined
    status = await Permission.microphone.request();
    if (status.isGranted) return true;

    // Permission denied — show guidance
    if (!mounted) return false;
    final isPermanent = status.isPermanentlyDenied;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade800,
        duration: const Duration(seconds: 4),
        content: Text(
          isPermanent
              ? 'Microphone access is blocked. Open Settings → App → Permissions and enable Microphone.'
              : 'Microphone permission is required to use voice input.',
        ),
        action: isPermanent
            ? SnackBarAction(
                label: 'Open Settings',
                textColor: Colors.white,
                onPressed: openAppSettings,
              )
            : null,
      ),
    );
    return false;
  }

  Future<void> _initializeSpeech() async {
    final available = await _speech.initialize(
      debugLogging: true,
      onStatus: (status) {
        debugPrint('STT Status: $status');
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        debugPrint('STT Error: ${error.errorMsg}');
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (available) {
      final locales = await _speech.locales();
      final systemLocale = await _speech.systemLocale();
      if (mounted) {
        setState(() {
          _availableLocales = locales;
          _currentLocaleId = systemLocale?.localeId;
        });
      }
      debugPrint('Available STT locales: ${locales.map((l) => l.localeId).join(', ')}');
      debugPrint('STT Initialized with locale: $_currentLocaleId');
    } else {
      debugPrint(AppStrings.speechNotAvailable);
    }
  }

  /// Shows a bottom sheet so the user can pick their speech language.
  void _showLanguagePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Select Speech Language',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(color: Colors.white24),
            ..._availableLocales.map((locale) {
              final isSelected = locale.localeId == _currentLocaleId;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.language,
                  color: isSelected ? AppTheme.primary : Colors.white54,
                ),
                title: Text(
                  locale.name,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  locale.localeId,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                onTap: () {
                  setState(() => _currentLocaleId = locale.localeId);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        );
      },
    );
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage(AppStrings.defaultTtsLanguage);
  }

  String _previousText = '';

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    // Check mic permission before every listen attempt
    final hasPermission = await _ensureMicPermission();
    if (!hasPermission) return;

    await _flutterTts.stop();
    _previousText = _textController.text.trim();

    await _speech.listen(
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(seconds: 30),
      // Do NOT force a localeId — let Android pick what matches the device
      listenMode: stt.ListenMode.search,
      cancelOnError: false,
      partialResults: true,
      onResult: (result) {
        if (!mounted) return;
        // Skip empty partial results — they would clear the text box
        if (result.recognizedWords.isEmpty) return;
        debugPrint('STT result: "${result.recognizedWords}" final=${result.finalResult}');
        setState(() {
          _textController.text = _previousText.isEmpty
              ? result.recognizedWords
              : '$_previousText ${result.recognizedWords}';
        });
      },
    );
    if (mounted) setState(() => _isListening = true);
  }

  Future<void> _speakText() async {
    final text = _textController.text.trim();
    await _flutterTts.speak(
      text.isNotEmpty ? text : AppStrings.emptyTextWarning,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final keyboardOpen = mediaQuery.viewInsets.bottom > 0;

    return Scaffold(
      // Match scaffold bg to gradient start so no bleed-through
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        // SizedBox.expand ensures gradient always covers the full body,
        // regardless of how much content is in the scroll view
        child: SizedBox.expand(
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding:
                  EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
              // ConstrainedBox ensures the Column fills at least the full
              // visible area so there is never a gap below the buttons
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenSize.height -
                      mediaQuery.padding.top -
                      mediaQuery.padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!keyboardOpen) ...[
                      SizedBox(height: screenSize.height * 0.03),
                      // Header row: title + language picker button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _AppHeader(screenSize: screenSize),
                          ),
                          if (_availableLocales.isNotEmpty)
                            IconButton(
                              onPressed: _showLanguagePicker,
                              tooltip: 'Speech language',
                              icon: Icon(
                                Icons.language,
                                color: AppTheme.textHint,
                                size: screenSize.width * 0.06,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: screenSize.height * 0.04),
                      SizedBox(
                        height: screenSize.height * 0.07,
                        child: WaveformIndicator(isActive: _isListening),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                      StatusIndicator(isListening: _isListening),
                      SizedBox(height: screenSize.height * 0.025),
                      AnimatedMicButton(
                        isListening: _isListening,
                        onTap: _toggleListening,
                      ),
                      SizedBox(height: screenSize.height * 0.035),
                    ] else ...[
                      SizedBox(height: screenSize.height * 0.015),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusIndicator(isListening: _isListening),
                          AnimatedMicButton(
                            isListening: _isListening,
                            onTap: _toggleListening,
                          ),
                        ],
                      ),
                      SizedBox(height: screenSize.height * 0.015),
                    ],

                    // Text field with proportional, bounded height
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenSize.height * 0.25,
                        maxHeight: keyboardOpen
                            ? screenSize.height * 0.3
                            : screenSize.height * 0.32,
                      ),
                      child: TranscriptionCard(controller: _textController),
                    ),

                    SizedBox(height: screenSize.height * 0.025),

                    ActionButtonsRow(
                      textController: _textController,
                      onSpeak: _speakText,
                    ),

                    SizedBox(height: screenSize.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  final Size screenSize;

  const _AppHeader({required this.screenSize});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            AppStrings.appName,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: screenSize.width * 0.1,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(height: screenSize.height * 0.005),
        Text(
          AppStrings.appSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 0.8),
        ),
      ],
    );
  }
}
