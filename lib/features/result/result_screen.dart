import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/app_config.dart';
import '../../config/theme.dart';
import '../../models/session_model.dart';

class ResultScreen extends StatefulWidget {
  final Object? extra;
  const ResultScreen({super.key, this.extra});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late SessionModel _session;
  late bool _printed;
  int _countdown = AppConfig.autoResetSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final data = widget.extra as Map<String, dynamic>;
    _session = data['session'] as SessionModel;
    _printed = data['printed'] as bool? ?? false;
    _startAutoReset();
  }

  void _startAutoReset() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _countdown--);
      if (_countdown <= 0) {
        t.cancel();
        if (mounted) context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final downloadUrl = _session.downloadUrl;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            children: [
              // Success header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.greenAccent.withOpacity(0.4),
                            width: 2),
                      ),
                      child: const Icon(Icons.check_circle_outline,
                          color: Colors.greenAccent, size: 44),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Berhasil!',
                      style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _printed
                          ? 'Foto sudah dicetak dan siap diambil'
                          : 'Foto berhasil diproses',
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // QR Code section
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Scan untuk download foto digital',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withOpacity(0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: downloadUrl,
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Valid selama ${AppConfig.downloadExpireDays} hari',
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Session code
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tag, color: AppTheme.textMuted, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Kode: ${_session.sessionCode.toUpperCase()}',
                      style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 13,
                          fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Auto-reset countdown
              Column(
                children: [
                  Text(
                    'Kembali ke beranda dalam $_countdown detik',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _countdown / AppConfig.autoResetSeconds,
                      backgroundColor: AppTheme.surface,
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.accent),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _timer?.cancel();
                        context.go('/');
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Kembali ke Beranda'),
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
