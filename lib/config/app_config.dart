class AppConfig {
  // API
  static const String baseUrl = 'https://codezy.id/api';
  static const String downloadBaseUrl = 'https://codezy.id/foto';

  // Printer
  static const String printerName = 'XS80BT';
  static const int printWidthDots = 576;
  static const int printerChunkSize = 512;
  static const int printerChunkDelayMs = 20;

  // Business
  static const int hargaDefault = 15000;
  static const int paymentCountdownSeconds = 30;
  static const int autoResetSeconds = 60;
  static const int downloadExpireDays = 30;

  // Admin PIN
  static const String adminPin = '1234';
  static const int adminLongPressDurationMs = 3000;
}
