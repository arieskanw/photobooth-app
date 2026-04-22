import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../config/theme.dart';
import '../../core/constants/layout_type.dart';
import '../../core/services/api_service.dart';
import '../../core/services/printer_manager.dart';
import '../../core/utils/image_composer.dart';

enum _Step { composing, uploading, printing, done, error }

class PrintingScreen extends StatefulWidget {
  final Object? extra;
  const PrintingScreen({super.key, this.extra});

  @override
  State<PrintingScreen> createState() => _PrintingScreenState();
}

class _PrintingScreenState extends State<PrintingScreen>
    with TickerProviderStateMixin {
  late List<File> _photos;
  late LayoutType _layout;
  _Step _step = _Step.composing;
  String? _errorMsg;
  late AnimationController _spinController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final data = widget.extra as Map<String, dynamic>;
    _photos = data['photos'] as List<File>;
    _layout = data['layout'] as LayoutType;

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _process();
  }

  @override
  void dispose() {
    _spinController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _process() async {
    try {
      // Step 1: Compose image
      setState(() => _step = _Step.composing);
      final composed = await ImageComposer.compose(
        photos: _photos,
        layoutType: _layout,
      );

      // Step 2: Upload to API
      setState(() => _step = _Step.uploading);
      final jpegFile = await _saveComposedToTemp(composed);
      final apiService = context.read<ApiService>();
      final session = await apiService.uploadPhoto(
        photoFile: jpegFile,
        layoutType: _layout,
      );

      // Step 3: Print
      setState(() => _step = _Step.printing);
      final printerManager = context.read<PrinterManager>();
      final connected = await printerManager.isConnected();
      if (connected) {
        await printerManager.printPhoto(composed);
      }
      // Don't block user if printer not connected — still show result

      setState(() => _step = _Step.done);
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        context.pushReplacement('/result', extra: {
          'session': session,
          'printed': connected,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _step = _Step.error;
          _errorMsg = e.toString();
        });
      }
    }
  }

  Future<File> _saveComposedToTemp(dynamic composed) async {
    final bytes = await ImageComposer.toJpegBytes(composed, quality: 90);
    final dir = Directory.systemTemp;
    final file = File('${dir.path}/composed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes);
    return file;
  }

  String get _stepLabel {
    switch (_step) {
      case _Step.composing:  return 'Memproses foto...';
      case _Step.uploading:  return 'Mengupload foto...';
      case _Step.printing:   return 'Mencetak foto...';
      case _Step.done:       return 'Selesai!';
      case _Step.error:      return 'Terjadi kesalahan';
    }
  }

  int get _stepIndex {
    switch (_step) {
      case _Step.composing:  return 0;
      case _Step.uploading:  return 1;
      case _Step.printing:   return 2;
      case _Step.done:       return 3;
      case _Step.error:      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isError = _step == _Step.error;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon / animation
              SizedBox(
                width: 120,
                height: 120,
                child: isError
                    ? const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 80)
                    : _step == _Step.done
                        ? const Icon(Icons.check_circle,
                            color: Colors.greenAccent, size: 80)
                        : RotationTransition(
                            turns: _spinController,
                            child: const Icon(Icons.sync,
                                color: AppTheme.accent, size: 80),
                          ),
              ),

              const SizedBox(height: 32),

              // Step label
              FadeTransition(
                opacity: _step == _Step.done || isError
                    ? const AlwaysStoppedAnimation(1.0)
                    : _pulseController,
                child: Text(
                  _stepLabel,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Step indicators
              if (!isError) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StepDot(label: 'Proses',  done: _stepIndex > 0, active: _stepIndex == 0),
                    _StepLine(done: _stepIndex > 0),
                    _StepDot(label: 'Upload',  done: _stepIndex > 1, active: _stepIndex == 1),
                    _StepLine(done: _stepIndex > 1),
                    _StepDot(label: 'Cetak',   done: _stepIndex > 2, active: _stepIndex == 2),
                  ],
                ),
              ],

              // Error detail
              if (isError) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMsg ?? 'Unknown error',
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.go('/'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textMuted,
                          side: const BorderSide(color: AppTheme.surface),
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Ke Beranda'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _step = _Step.composing;
                            _errorMsg = null;
                          });
                          _process();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  const _StepDot({required this.label, required this.done, required this.active});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (done) color = Colors.greenAccent;
    else if (active) color = AppTheme.accent;
    else color = AppTheme.surface;

    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: active
                ? Border.all(color: AppTheme.accent.withOpacity(0.4), width: 4)
                : null,
          ),
          child: done
              ? const Icon(Icons.check, color: Colors.black, size: 18)
              : active
                  ? const SizedBox()
                  : null,
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                color: active || done ? AppTheme.textLight : AppTheme.textMuted,
                fontSize: 11)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool done;
  const _StepLine({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 2,
      margin: const EdgeInsets.only(bottom: 24),
      color: done ? Colors.greenAccent : AppTheme.surface,
    );
  }
}
