import '../core/constants/layout_type.dart';

class SessionModel {
  final String sessionCode;
  final LayoutType layoutType;
  final String downloadUrl;
  final DateTime createdAt;

  SessionModel({
    required this.sessionCode,
    required this.layoutType,
    required this.downloadUrl,
    required this.createdAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionCode: json['session_code'],
      layoutType: LayoutType.values.firstWhere(
        (e) => e.apiValue == json['layout_type'],
        orElse: () => LayoutType.single,
      ),
      downloadUrl: json['download_url'],
      createdAt: DateTime.now(),
    );
  }
}
