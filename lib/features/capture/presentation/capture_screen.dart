import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:lekture_ai/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../shared/providers/global_providers.dart';
import '../../shared/widgets/app_header.dart';

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  String _mode = 'voice'; // 'voice' or 'scan'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppHeader(title: l10n.capture),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _mode = 'voice'),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _mode == 'voice' ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _mode == 'voice'
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.voice,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _mode == 'voice' ? Colors.white : (isDark ? AppColors.textMuted : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _mode = 'scan'),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _mode == 'scan' ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _mode == 'scan'
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.scan,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _mode == 'scan' ? Colors.white : (isDark ? AppColors.textMuted : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _mode == 'voice' ? const VoiceCaptureWidget() : const ScanCaptureWidget(),
          ],
        ),
      ),
    );
  }
}

// ================= Voice Capture Widget =================
class VoiceCaptureWidget extends ConsumerStatefulWidget {
  const VoiceCaptureWidget({super.key});

  @override
  ConsumerState<VoiceCaptureWidget> createState() => _VoiceCaptureWidgetState();
}

class _VoiceCaptureWidgetState extends ConsumerState<VoiceCaptureWidget> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _transcript = '';
  String _savedTranscript = '';
  String _currentSessionWords = '';
  String _interim = '';
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isListening) {
      await _speech.stop();
      setState(() {
        _isListening = false;
        if (_currentSessionWords.isNotEmpty) {
          _savedTranscript = _savedTranscript.isEmpty
              ? _currentSessionWords
              : '$_savedTranscript $_currentSessionWords';
          _currentSessionWords = '';
        }
        _transcript = _savedTranscript.trim();
        _scrollToBottom();
      });
    } else {
      bool available = await _speech.initialize(
        onStatus: (status) {
          debugPrint('STT Status: $status');
          if (status == 'done' || status == 'notListening') {
            setState(() {
              _isListening = false;
              if (_currentSessionWords.isNotEmpty) {
                _savedTranscript = _savedTranscript.isEmpty
                    ? _currentSessionWords
                    : '$_savedTranscript $_currentSessionWords';
                _currentSessionWords = '';
              }
              _transcript = _savedTranscript.trim();
              _scrollToBottom();
            });
          }
        },
        onError: (error) {
          debugPrint('STT Error: $error');
          setState(() {
            _isListening = false;
            if (_currentSessionWords.isNotEmpty) {
              _savedTranscript = _savedTranscript.isEmpty
                  ? _currentSessionWords
                  : '$_savedTranscript $_currentSessionWords';
              _currentSessionWords = '';
            }
            _transcript = _savedTranscript.trim();
            _scrollToBottom();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.dictationError(error.errorMsg))),
          );
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          _savedTranscript = _transcript.trim();
          _currentSessionWords = '';
          _interim = '';
        });
        final settings = ref.read(settingsProvider);
        _speech.listen(
          onResult: (result) {
            setState(() {
              String currentWords = result.recognizedWords.trim();

              // Detect segment reset (common in continuous listening on Android/iOS)
              if (_currentSessionWords.isNotEmpty && currentWords.isNotEmpty) {
                List<String> oldWordsList = _currentSessionWords.toLowerCase().split(' ');
                List<String> newWordsList = currentWords.toLowerCase().split(' ');

                if (newWordsList.isNotEmpty && oldWordsList.isNotEmpty) {
                  String firstNewWord = newWordsList.first;
                  // If the new first word is not in the old words list at all,
                  // and the new text is shorter or does not start with the old text,
                  // it indicates the engine has reset its buffer to start a new segment.
                  if (!oldWordsList.contains(firstNewWord) &&
                      !currentWords.toLowerCase().startsWith(_currentSessionWords.toLowerCase())) {
                    _savedTranscript = _savedTranscript.isEmpty
                        ? _currentSessionWords
                        : '$_savedTranscript $_currentSessionWords';
                  }
                }
              }

              if (result.finalResult) {
                if (currentWords.isNotEmpty) {
                  _savedTranscript = _savedTranscript.isEmpty
                      ? currentWords
                      : '$_savedTranscript $currentWords';
                }
                _currentSessionWords = '';
              } else {
                _currentSessionWords = currentWords;
              }

              _transcript = _savedTranscript.trim();
              if (_currentSessionWords.isNotEmpty) {
                _transcript = _transcript.isEmpty
                    ? _currentSessionWords
                    : '$_transcript $_currentSessionWords';
              }
              _scrollToBottom();
            });
          },
          localeId: settings.language == 'id' ? 'id_ID' : 'en_US',
          listenMode: stt.ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
          listenFor: const Duration(minutes: 20),
          pauseFor: const Duration(seconds: 30),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.speechNotAvailable)),
        );
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clear() {
    setState(() {
      _transcript = '';
      _savedTranscript = '';
      _currentSessionWords = '';
      _interim = '';
    });
  }

  void _saveAsNote() {
    final l10n = AppLocalizations.of(context)!;
    final text = _transcript.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nothingToSave)),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    context.push(
      '/notes/edit?id=new&prefillTitle=${Uri.encodeComponent(l10n.voiceNoteTitle(dateStr))}&prefillBody=${Uri.encodeComponent(text)}&prefillTag=General',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        // Circle Dictate Button
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _toggleListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _isListening
                        ? const LinearGradient(
                            colors: [AppColors.success, AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? AppColors.success : AppColors.primary).withOpacity(0.4),
                        blurRadius: _isListening ? 24 : 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isListening ? l10n.listening : l10n.tapToStartDictating,
                style: theme.textTheme.displaySmall?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                _isListening ? l10n.speakClearly : l10n.realTimeStt,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Live wave form
        WaveformWidget(active: _isListening),
        const SizedBox(height: 24),

        // Transcript display box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.transcript,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: _transcript.isEmpty
                      ? Text(
                          l10n.wordsAppearHere,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                        )
                      : RichText(
                          text: TextSpan(
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 13.5,
                              height: 1.5,
                            ),
                            children: [
                              if (_savedTranscript.isNotEmpty)
                                TextSpan(text: '$_savedTranscript '),
                              if (_currentSessionWords.isNotEmpty)
                                TextSpan(
                                  text: _currentSessionWords,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clear,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.clear, style: TextStyle(color: isDark ? AppColors.text : Colors.black87)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveAsNote,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.saveAsNote, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom Waveform Widget
class WaveformWidget extends StatefulWidget {
  final bool active;

  const WaveformWidget({super.key, required this.active});

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int _barCount = 20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant WaveformWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: 36,
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_barCount, (index) {
              double heightFactor = 0.2;
              if (widget.active) {
                // Generate simulated audio wave height
                final sine = math.sin((_controller.value * 2 * math.pi) + (index * 0.4));
                heightFactor = 0.2 + (sine.abs() * 0.8);
              }
              return Container(
                width: 3.5,
                height: 36 * heightFactor,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: widget.active ? AppColors.accent : AppColors.textMuted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

// ================= Scan Capture Widget =================
class ScanCaptureWidget extends ConsumerStatefulWidget {
  const ScanCaptureWidget({super.key});

  @override
  ConsumerState<ScanCaptureWidget> createState() => _ScanCaptureWidgetState();
}

class _ScanCaptureWidgetState extends ConsumerState<ScanCaptureWidget> {
  File? _imageFile;
  String _extractedText = '';
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() {
          _imageFile = File(picked.path);
          _extractedText = '';
          _isLoading = true;
        });

        // Convert image to base64
        final bytes = await _imageFile!.readAsBytes();
        final base64Image = base64Encode(bytes);
        
        final ai = ref.read(aiServiceProvider);
        final result = await ai.ocrImage(base64Image);

        setState(() {
          _extractedText = result;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.textExtracted)),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.ocrFailed(e.toString()))),
      );
    }
  }

  void _retake() {
    setState(() {
      _imageFile = null;
      _extractedText = '';
    });
  }

  void _saveAsNote() {
    final l10n = AppLocalizations.of(context)!;
    if (_extractedText.trim().isEmpty) return;
    context.push(
      '/notes/edit?id=new&prefillTitle=${Uri.encodeComponent(l10n.scannedPageTitle)}&prefillBody=${Uri.encodeComponent(_extractedText)}&prefillTag=General',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    if (_imageFile == null) {
      return InkWell(
        onTap: () {
          // Open camera/gallery picker sheet
          showModalBottomSheet(
            context: context,
            useRootNavigator: true,
            backgroundColor: AppColors.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                    title: Text(l10n.takePhoto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
                    title: Text(l10n.chooseFromGallery, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
              style: BorderStyle.solid,
            ),
            color: isDark ? AppColors.surface.withOpacity(0.4) : Colors.grey[100],
          ),
          child: Column(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.scanTextbook,
                style: theme.textTheme.displaySmall?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.takePhotoOrPick,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11.5),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preview image with blur overlay if loading
        Stack(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: FileImage(_imageFile!),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                ),
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.accent),
                      const SizedBox(height: 12),
                      Text(
                        l10n.readingPage,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Text area or skeleton loader
        if (_isLoading)
          const SkeletonLinesWidget()
        else
          TextField(
            maxLines: 10,
            controller: TextEditingController(text: _extractedText),
            onChanged: (val) => _extractedText = val,
            style: const TextStyle(fontSize: 13.5, height: 1.4),
            decoration: InputDecoration(
              hintText: l10n.extractedTextHint,
              fillColor: isDark ? AppColors.surface : Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _retake,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.retake, style: TextStyle(color: isDark ? AppColors.text : Colors.black87)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _extractedText.trim().isEmpty ? null : _saveAsNote,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.saveAsNote, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Skeleton loading lines widget
class SkeletonLinesWidget extends StatefulWidget {
  const SkeletonLinesWidget({super.key});

  @override
  State<SkeletonLinesWidget> createState() => _SkeletonLinesWidgetState();
}

class _SkeletonLinesWidgetState extends State<SkeletonLinesWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.surface : Colors.grey[200]!;
    final highlightColor = isDark ? AppColors.surfaceVariant : Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLine(180, baseColor, highlightColor),
              const SizedBox(height: 10),
              _buildLine(120, baseColor, highlightColor),
              const SizedBox(height: 10),
              _buildLine(220, baseColor, highlightColor),
              const SizedBox(height: 10),
              _buildLine(160, baseColor, highlightColor),
              const SizedBox(height: 10),
              _buildLine(200, baseColor, highlightColor),
              const SizedBox(height: 10),
              _buildLine(100, baseColor, highlightColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLine(double width, Color base, Color highlight) {
    return Container(
      width: width,
      height: 12,
      decoration: BoxDecoration(
        color: Color.lerp(base, highlight, _controller.value),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
