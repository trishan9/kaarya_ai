import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaarya/core/api/api_endpoints.dart';
import 'package:kaarya/core/services/storage/token_service.dart';
import 'package:kaarya/core/services/storage/user_session_service.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokenService: ref.read(tokenServiceProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class ApiClient {
  late final Dio _dio;

  ApiClient({
    required TokenService tokenService,
    required UserSessionService userSessionService,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      _AuthInterceptor(
        tokenService: tokenService,
        userSessionService: userSessionService,
      ),
    );

    // Auto retry on network failures
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          // Retry on connection errors and timeouts, not on 4xx/5xx
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    final requestOptions = (options ?? Options()).copyWith(
      method: options?.method ?? 'POST',
      contentType: 'multipart/form-data',
    );

    return _dio.request(
      path,
      data: formData,
      options: requestOptions,
      onSendProgress: onSendProgress,
    );
  }
}

class _AuthInterceptor extends Interceptor {
  final TokenService _tokenService;
  final UserSessionService _userSessionService;

  _AuthInterceptor({
    required TokenService tokenService,
    required UserSessionService userSessionService,
  }) : _tokenService = tokenService,
       _userSessionService = userSessionService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isAuthEndpoint =
        options.path == ApiEndpoints.userLogin ||
        options.path == ApiEndpoints.userSignup;

    if (!isAuthEndpoint) {
      final token = await _tokenService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _tokenService.removeToken();
      await _userSessionService.clearSession();
    }
    handler.next(err);
  }
}
