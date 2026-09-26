import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PokeApiException implements Exception {
  PokeApiException(this.message);

  final String message;

  @override
  String toString() => 'PokeApiException: $message';
}

/// Thin wrapper around a single shared [Dio] instance. Every current call
/// site passes a fully-qualified URL (PokeAPI or the species/evolution-chain
/// follow-up URLs it returns), so no `baseUrl` is configured here.
class DioClient {
  DioClient({Dio? dio})
      : _dio = dio ??
            (Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            )..interceptors.addAll(
                kDebugMode ? [LogInterceptor(responseBody: false)] : [],
              ));

  final Dio _dio;

  Future<Map<String, dynamic>> getJson(String url) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(url);
      final data = response.data;
      if (response.statusCode != 200 || data == null) {
        throw PokeApiException(
          'Unexpected response from $url (status ${response.statusCode})',
        );
      }
      return data;
    } on DioException catch (e) {
      throw PokeApiException('Request to $url failed: ${e.message}');
    }
  }
}
