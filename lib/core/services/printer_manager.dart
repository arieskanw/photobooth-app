import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:image/image.dart' as img;
import '../../config/app_config.dart';

enum PrinterConnectionType { bluetooth, usb }
enum PrinterStatus { disconnected, connecting, connected, printing, error }

class PrinterManager {
  PrinterConnectionType _connectionType = PrinterConnectionType.bluetooth;
  PrinterStatus _status = PrinterStatus.disconnected;

  PrinterStatus get status => _status;

  Future<List<BluetoothInfo>> scanBluetooth() async {
    return await PrintBluetoothThermal.pairedBluetooths;
  }

  Future<bool> connectBluetooth(String macAddress) async {
    _status = PrinterStatus.connecting;
    final result = await PrintBluetoothThermal.connect(
      macPrinterAddress: macAddress,
    );
    _status = result ? PrinterStatus.connected : PrinterStatus.error;
    _connectionType = PrinterConnectionType.bluetooth;
    return result;
  }

  Future<bool> disconnect() async {
    final result = await PrintBluetoothThermal.disconnect;
    _status = PrinterStatus.disconnected;
    return result;
  }

  Future<bool> isConnected() async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  /// Print composed photo image + auto cut
  Future<bool> printPhoto(img.Image composedImage) async {
    try {
      _status = PrinterStatus.printing;

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);

      List<int> bytes = [];
      bytes += generator.reset();

      // Convert to 576-dot width grayscale then to ESC/POS image
      final resized = img.copyResize(
        composedImage,
        width: AppConfig.printWidthDots,
      );
      final grayscale = img.grayscale(resized);
      bytes += generator.image(grayscale);

      // Feed before cut (required for XS80BT)
      bytes += generator.feed(3);

      // Auto cut
      bytes += generator.cut(mode: PosCutMode.full);

      // Send in chunks to avoid BT buffer overflow
      final success = await _sendInChunks(Uint8List.fromList(bytes));
      _status = success ? PrinterStatus.connected : PrinterStatus.error;
      return success;
    } catch (e) {
      _status = PrinterStatus.error;
      return false;
    }
  }

  Future<bool> _sendInChunks(Uint8List data) async {
    final chunkSize = AppConfig.printerChunkSize;
    for (int i = 0; i < data.length; i += chunkSize) {
      final end = (i + chunkSize < data.length) ? i + chunkSize : data.length;
      final chunk = data.sublist(i, end);
      final result = await PrintBluetoothThermal.writeBytes(chunk);
      if (!result) return false;
      await Future.delayed(
        Duration(milliseconds: AppConfig.printerChunkDelayMs),
      );
    }
    return true;
  }

  /// Test print — 576 dot width test bar
  Future<bool> testPrint() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];
    bytes += generator.reset();
    bytes += generator.text(
      'CODEZY PHOTOBOOTH',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text('Test Print — 80mm OK');
    bytes += generator.feed(3);
    bytes += generator.cut();
    return await PrintBluetoothThermal.writeBytes(Uint8List.fromList(bytes));
  }
}
