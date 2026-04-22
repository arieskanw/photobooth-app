import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/services/api_service.dart';
import 'core/services/printer_manager.dart';
import 'features/home/home_screen.dart';
import 'features/capture/capture_screen.dart';
import 'features/preview/preview_screen.dart';
import 'features/payment/payment_screen.dart';
import 'features/printing/printing_screen.dart';
import 'features/result/result_screen.dart';
import 'features/settings/settings_screen.dart';
import 'config/theme.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/',          builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/capture',   builder: (_, state) => CaptureScreen(extra: state.extra)),
    GoRoute(path: '/preview',   builder: (_, state) => PreviewScreen(extra: state.extra)),
    GoRoute(path: '/payment',   builder: (_, state) => PaymentScreen(extra: state.extra)),
    GoRoute(path: '/printing',  builder: (_, state) => PrintingScreen(extra: state.extra)),
    GoRoute(path: '/result',    builder: (_, state) => ResultScreen(extra: state.extra)),
    GoRoute(path: '/settings',  builder: (_, __) => const SettingsScreen()),
  ],
);

class PhotoboothApp extends StatelessWidget {
  const PhotoboothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<PrinterManager>(create: (_) => PrinterManager()),
      ],
      child: MaterialApp.router(
        title: 'Codezy Photobooth',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        routerConfig: _router,
      ),
    );
  }
}
