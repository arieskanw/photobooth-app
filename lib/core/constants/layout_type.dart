enum LayoutType {
  single,  // 1 foto
  double,  // 2 foto strip vertikal
  quad,    // 4 foto grid 2x2
}

extension LayoutTypeExtension on LayoutType {
  String get label {
    switch (this) {
      case LayoutType.single: return '1 Foto';
      case LayoutType.double: return '2 Foto Strip';
      case LayoutType.quad:   return '4 Foto Grid';
    }
  }

  int get photoCount {
    switch (this) {
      case LayoutType.single: return 1;
      case LayoutType.double: return 2;
      case LayoutType.quad:   return 4;
    }
  }

  String get frameAsset {
    switch (this) {
      case LayoutType.single: return 'assets/frames/frame_single.png';
      case LayoutType.double: return 'assets/frames/frame_double.png';
      case LayoutType.quad:   return 'assets/frames/frame_quad.png';
    }
  }

  String get apiValue {
    switch (this) {
      case LayoutType.single: return 'single';
      case LayoutType.double: return 'double';
      case LayoutType.quad:   return 'quad';
    }
  }
}
