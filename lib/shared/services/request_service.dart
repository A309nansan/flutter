import 'package:dio/dio.dart';
import 'dio_api_client.dart';

class RequestService {
  static Future<dynamic> send({
    required String method,
    required String path,
    dynamic data, // Map or List<Map<String, dynamic>>
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await ApiClient.dio.request(
        path,
        data: data,
        queryParameters: queryParams,
        options: Options(method: method.toUpperCase(), headers: headers),
      );

      return response.data;
    } on DioException catch (e) {
      rethrow;
    }
  }

  static Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
  }) {
    return send(
      method: 'GET',
      path: path,
      queryParams: queryParams,
      headers: headers,
    );
  }

  static Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) {
    return send(method: 'POST', path: path, data: data, headers: headers);
  }

  static Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) {
    return send(method: 'PUT', path: path, data: data, headers: headers);
  }

  static Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) {
    return send(method: 'DELETE', path: path, data: data, headers: headers);
  }

  static Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) {
    return send(method: 'PATCH', path: path, data: data, headers: headers);
  }

  static Future<Response<dynamic>> rawGet(
    String path, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        path,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  static Future<Response<dynamic>> rawPost(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }
}
