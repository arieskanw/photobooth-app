import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import '../../config/theme.dart';
import '../../core/constants/layout_type.dart';
import '../../core/utils/image_composer.dart';

class PreviewScreen extends StatefulWidget {
  final Object? extra;
  const PreviewScreen({super.key, this.extra});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late List<File> _photos;
  late LayoutType _layout;
  Uint8List? _previewBytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final data = widget.extra as Map<String, dynamic>;
    _photos = data['photos'] as List<File>;
    _layout = data['layout'] as LayoutType;
    _compose();
  }

  Future<void> _compose() async {
    final composed = await ImageComposer.compose(
      photos: _photos,
      layoutType: _layout,
    );
    final bytes = await ImageComposer.toJpegBytes(composed, quality: 90);
    if (mounted) setState(() { _previewBytes = bytes; _loading = false; });
  }

  void _retake() {
    context.pop();
  }

  void _lanjut() {
    context.push('/payment', extra: widget.extra);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: _retake,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: AppTheme.textLight, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Preview Foto',
                      style: TextStyle(color: AppTheme.textLight,
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _layout.label,
                      style: const TextStyle(
                          color: AppTheme.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Preview Image
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _loading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: AppTheme.accent),
                              SizedBox(height: 16),
                              Text('Memproses foto...',
                                  style: TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 14)),
                            ],
                          ),
                        )
                      : Image.memory(
                          _previewBytes!,
                          fit: BoxFit.contain,
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _retake,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Ulangi'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textMuted,
                        side: const BorderSide(color: AppTheme.surface),
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _lanjut,
                      icon: const Icon(Icons.payment),
                      label: const Text('Lanjut Bayar'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
