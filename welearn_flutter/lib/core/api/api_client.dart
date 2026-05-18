import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../constants/app_constants.dart';
import '../services/storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Client': 'flutter',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(dio),
    PrettyDioLogger(
      requestHeader: false,
      requestBody: true,
      responseBody: true,
      error: true,
      compact: true,
    ),
  ]);

  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path,
        queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(path,
        data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.put(path, data: data, options: options);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.patch(path, data: data, options: options);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return _dio.delete(path, data: data, options: options);
  }

  Future<Response> uploadFile(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
}

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      if (_isRefreshing) {
        _pendingRequests.add(err.requestOptions);
        return;
      }

      _isRefreshing = true;
      try {
        final refreshToken = await StorageService.getRefreshToken();
        if (refreshToken == null) {
          handler.next(err);
          return;
        }

        final response = await _dio.post(
          '/user/refresh-token',
          data: {'refreshToken': refreshToken},
          options: Options(headers: {'Authorization': null}),
        );

        final newToken = response.data['token'] as String?;
        if (newToken != null) {
          await StorageService.saveToken(newToken);

          // Retry original request
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);

          // Retry pending requests
          for (final pending in _pendingRequests) {
            pending.headers['Authorization'] = 'Bearer $newToken';
            await _dio.fetch(pending);
          }
          _pendingRequests.clear();
        } else {
          handler.next(err);
        }
      } catch (_) {
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}

AppException handleDioError(Object err) {
  if (err is DioException) {
    final data = err.response?.data;
    final message = (data is Map ? data['message'] : null) ??
        err.message ??
        'Something went wrong';
    return AppException(
      message: message,
      statusCode: err.response?.statusCode,
    );
  }
  if (err is SocketException) {
    return const AppException(
        message: 'No internet connection. Check your network.');
  }
  return AppException(message: err.toString());
}

class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}
