import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:nansan_flutter/shared/services/token_storage.dart';

// 기본 Gateway url http://nansan.site/api/v1
// 서비스 명은 뒤에 /service_name
class ApiClient {
  static const _critical500Paths = [
    "/user/me",
    "/user/user/detail-status",
    "/user/user/update-role"
  ];

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://nansan.site/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  )
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (TokenStorage.accessToken != null) {
            options.headers['Authorization'] =
            'Bearer ${TokenStorage.accessToken}';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final retryCount =
              (error.requestOptions.extra['retryCount'] ?? 0) + 1;

          // 1. 401 Unauthorized → 토큰 재발급
          if (error.response?.statusCode == 401 && retryCount <= 1) {
            final success = await _reissueToken();
            if (success) {
              final retryOptions = error.requestOptions;
              retryOptions.extra['retryCount'] = retryCount;

              dynamic retryData = retryOptions.data;

              if (retryOptions.extra.containsKey("formDataBuilder")) {
                final Future<FormData> Function() asyncBuilder =
                retryOptions.extra["formDataBuilder"];
                retryData = await asyncBuilder();
              }

              try {
                final retryResponse = await dio.request(
                  retryOptions.path,
                  data: retryData,
                  queryParameters: retryOptions.queryParameters,
                  options: Options(
                    method: retryOptions.method,
                    headers: retryOptions.headers,
                    extra: retryOptions.extra,
                    contentType: retryOptions.contentType,
                  ),
                );

                return handler.resolve(retryResponse);
              } catch (e) {
                return handler.reject(
                  e is DioException
                      ? e
                      : DioException(requestOptions: retryOptions),
                );
              }
            } else {
              TokenStorage.clear();
              return handler.reject(error);
            }
          }

          // 2. 서버 죽음(502/503) 또는 연결 오류 → 강제 로그아웃
          if ([
            DioExceptionType.connectionTimeout,
            DioExceptionType.receiveTimeout,
            DioExceptionType.sendTimeout,
            DioExceptionType.connectionError,
          ].contains(error.type) ||
              (error.response?.statusCode == 502 || error.response?.statusCode == 503)) {
            debugPrint('❗ 서버 연결 실패. 강제 로그아웃.');
            await _forceLogout();
            return handler.reject(error);
          }

          // 3. /user API에서 500 발생 → 강제 로그아웃 (토큰 유효성 문제 가능성)
          if (error.response?.statusCode == 500 &&
              _critical500Paths.any((path) => error.requestOptions.path.contains(path))) {
            debugPrint('❗ 서버 500 오류 (토큰 문제 가능성). 강제 로그아웃.');
            await _forceLogout();
            return handler.reject(error);
          }

          return handler.next(error);
        },
      ),
    );

  static Future<bool> _reissueToken() async {
    try {
      final response = await dio.post(
        '/user/reissue',
        options: Options(headers: {'refresh': TokenStorage.refreshToken}),
      );

      final newAccessToken = response.data['access'];
      final newRefreshToken = response.headers['refresh']?.join();

      TokenStorage.update(access: newAccessToken, refresh: newRefreshToken!);

      await SecureStorageService.saveAccessToken(newAccessToken);
      await SecureStorageService.saveRefreshToken(newRefreshToken);

      return true;
    } catch (e) {
      debugPrint('❗ 토큰 재발급 실패: $e');
      return false;
    }
  }

  static Future<void> _forceLogout() async {
    TokenStorage.clear();
    await SecureStorageService.clearAuthData();
    Modular.to.pushReplacementNamed('/auth/login');
  }
}