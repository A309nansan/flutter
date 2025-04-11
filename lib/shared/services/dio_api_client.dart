import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nansan_flutter/shared/services/secure_storage_service.dart';
import 'package:nansan_flutter/shared/services/token_storage.dart';

// 기본 Gateway url http://nansan.site/api/v1
// 서비스 명은 뒤에 /service_name
class ApiClient {
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
}
