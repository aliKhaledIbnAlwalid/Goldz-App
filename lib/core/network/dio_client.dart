import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  final Dio dio;
  DioClient(this.dio);

  factory DioClient.create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          'Accept': 'application/json',
          // Identify the app properly. Default Dart UA gets
          // throttled by some WAFs.
          'User-Agent': 'Goldz/1.0 (Flutter; Android)',
        },
        // Let us inspect 429 bodies instead of Dio throwing blindly.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          responseHeader: true,
          responseBody: true,
          compact: true,
        ),
      );
    }

    return DioClient(dio);
  }
}