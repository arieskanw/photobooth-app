import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../../config/app_config.dart';
import '../constants/layout_type.dart';

class ImageComposer {
  static const int canvasWidth = AppConfig.printWidthDots; // 576px
  static const int padding = 4;

  static Future<img.Image> compose({
    required List<File> photos,
    required LayoutType layoutType,
    File? frameOverlay,
  }) async {
    final decodedPhotos = await Future.wait(
      photos.map((f) async => img.decodeImage(await f.readAsBytes())!),
    );

    img.Image canvas;

    switch (layoutType) {
      case LayoutType.single:
        canvas = _composeSingle(decodedPhotos[0]);
        break;
      case LayoutType.double:
        canvas = _composeDouble(decodedPhotos);
        break;
      case LayoutType.quad:
        canvas = _composeQuad(decodedPhotos);
        break;
    }

    // Apply frame overlay if provided
    if (frameOverlay != null) {
      final frameImg = img.decodeImage(await frameOverlay.readAsBytes());
      if (frameImg != null) {
        final resizedFrame = img.copyResize(
          frameImg,
          width: canvas.width,
          height: canvas.height,
        );
        img.compositeImage(canvas, resizedFrame);
      }
    }

    return canvas;
  }

  static img.Image _composeSingle(img.Image photo) {
    final cellH = (canvasWidth * 3 / 4).round(); // 4:3 ratio
    final canvas = img.Image(width: canvasWidth, height: cellH + padding * 2);
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
    final resized = img.copyResize(photo, width: canvasWidth - padding * 2, height: cellH);
    img.compositeImage(canvas, resized, dstX: padding, dstY: padding);
    return canvas;
  }

  static img.Image _composeDouble(List<img.Image> photos) {
    final cellW = canvasWidth - padding * 2;
    final cellH = (cellW * 3 / 4).round();
    final totalH = (cellH * 2) + (padding * 3);
    final canvas = img.Image(width: canvasWidth, height: totalH);
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
    for (int i = 0; i < photos.length; i++) {
      final resized = img.copyResize(photos[i], width: cellW, height: cellH);
      img.compositeImage(
        canvas, resized,
        dstX: padding,
        dstY: padding + i * (cellH + padding),
      );
    }
    return canvas;
  }

  static img.Image _composeQuad(List<img.Image> photos) {
    final cellW = ((canvasWidth - padding * 3) / 2).round();
    final cellH = (cellW * 3 / 4).round();
    final totalH = (cellH * 2) + (padding * 3);
    final canvas = img.Image(width: canvasWidth, height: totalH);
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));
    for (int i = 0; i < photos.length; i++) {
      final col = i % 2;
      final row = i ~/ 2;
      final resized = img.copyResize(photos[i], width: cellW, height: cellH);
      img.compositeImage(
        canvas, resized,
        dstX: padding + col * (cellW + padding),
        dstY: padding + row * (cellH + padding),
      );
    }
    return canvas;
  }

  static Future<Uint8List> toJpegBytes(img.Image image, {int quality = 85}) async {
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }
}
