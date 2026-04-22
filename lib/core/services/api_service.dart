import 'dart:io';
import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../models/session_model.dart';
import '../constants/layout_type.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ));
  }

  Future<SessionModel> uploadPhoto({
    required File photoFile,
    required LayoutType layoutType,
  }) async {
    final formData = FormData.fromMap({
      'layout_type': layoutType.apiValue,
      'photo': await MultipartFile.fromFile(
        photoFile.path,
        filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    });

    int retries = 0;
    while (retries < 3) {
      try {
        final response = await _dio.post('/photobooth/upload', data: formData);
        return SessionModel.fromJson(response.data);
      } on DioException catch (e) {
        retries++;
        if (retries >= 3) rethrow;
        await Future.delayed(Duration(seconds: retries * 2));
      }
    }
    throw Exception('Upload gagal setelah 3 percobaan');
  }
}
