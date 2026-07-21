import 'dart:convert';

import 'package:dio/dio.dart';

import 'parse_exception.dart';
import 'parse_failure.dart';

class RakutenPageClient {
  RakutenPageClient({Dio? dio}) : _dio = dio ?? _buildDio();

  final Dio _dio;

  static Dio _buildDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        followRedirects: true,
        maxRedirects: 5,
        responseType: ResponseType.bytes,
        validateStatus: (status) => status != null && status < 400,
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'ja,en-US;q=0.9,en;q=0.8',
          'Referer': 'https://music.rakuten.co.jp/',
        },
      ),
    );
  }

  Future<String> fetchHtml(String url) async {
    try {
      final response = await _dio.get<List<int>>(url);
      final body = response.data;
      if (body == null || body.isEmpty) {
        throw const ParseException(PageUnavailableFailure());
      }
      return utf8.decode(body, allowMalformed: true);
    } on DioException catch (error) {
      throw ParseException(_mapDioError(error));
    }
  }

  ParseFailure _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NoConnectionFailure();
      case DioExceptionType.badResponse:
        return const PageUnavailableFailure();
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        final inner = error.error;
        if (inner is FormatException) {
          return const ParsingFailure();
        }
        return const NoConnectionFailure();
    }
  }
}
