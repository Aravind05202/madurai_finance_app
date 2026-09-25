import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'constants.dart';

/// Thrown for any non-ok API response (the PHP backend always replies with
/// {"ok": false, "error": "..."} or, for apply.php, {"success": false, "message": "..."}).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

/// Thin wrapper around every backend/api/*.php endpoint.
///
/// The PHP backend authenticates with PHP's native session cookie
/// (see helpers.php -> session_start()), NOT a bearer token. So this
/// client keeps a persistent cookie jar and sends every request with
/// credentials, exactly like the existing web frontend's fetch(..., {
/// credentials: 'include' }) calls.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late Dio _dio;
  PersistCookieJar? _cookieJar;
  bool _ready = false;

  String get baseUrl => kBaseUrl;

  Future<void> init() async {
    if (_ready) return;

    final dir = await getApplicationDocumentsDirectory();
    _cookieJar = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage('${dir.path}/.mf_cookies/'),
    );

    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 MaduraiFinanceApp/1.0',
      },
      validateStatus: (_) => true, // we inspect status ourselves below
    ));
    _dio.interceptors.add(CookieManager(_cookieJar!));
    _ready = true;
  }

  Future<void> clearSession() async {
    await _cookieJar?.deleteAll();
  }

  String _url(String path) {
    return '${kBaseUrl.replaceAll(RegExp(r'/+$'), '')}/$path';
  }

  Map<String, dynamic> _asMap(dynamic data, int statusCode) {
    if (data is Map<String, dynamic>) return data;
    if (data is String && data.trim().isEmpty) {
      throw ApiException('Server returned an empty response (HTTP $statusCode). '
          'Check that the API URL points at backend/api and that CORS is configured.');
    }
    throw ApiException('Server returned an unexpected response (HTTP $statusCode). '
        'Raw: ${data.toString().substring(0, data.toString().length.clamp(0, 200))}');
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? query}) async {
    await init();
    try {
      final res = await _dio.get(_url(endpoint), queryParameters: query);
      final map = _asMap(res.data, res.statusCode ?? 0);
      _throwIfFailed(map, res.statusCode ?? 0);
      return map;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    await init();
    try {
      final res = await _dio.post(_url(endpoint), data: body ?? {});
      final map = _asMap(res.data, res.statusCode ?? 0);
      _throwIfFailed(map, res.statusCode ?? 0);
      return map;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  void _throwIfFailed(Map<String, dynamic> map, int statusCode) {
    // login.php/loans.php/etc use {"ok": false, ...}; apply.php (public) uses {"success": false, ...}.
    final ok = map['ok'];
    final success = map['success'];
    if (ok == false || success == false) {
      final msg = (map['error'] ?? map['message'] ?? 'Request failed.').toString();
      throw ApiException(msg, statusCode: statusCode);
    }
    if (statusCode >= 400 && ok == null && success == null) {
      throw ApiException('Request failed (HTTP $statusCode).', statusCode: statusCode);
    }
  }

  ApiException _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException('Could not reach the server. Check the API URL and your connection.');
    }
    if (e.type == DioExceptionType.connectionError) {
      final detail = e.error != null ? ' (${e.error})' : (e.message != null ? ' (${e.message})' : '');
      return ApiException(
          'Connection failed$detail. Make sure the API URL is correct and reachable.');
    }
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = (data['error'] ?? data['message'])?.toString();
      if (msg != null) return ApiException(msg, statusCode: e.response?.statusCode);
    }
    return ApiException(e.message ?? 'Unexpected network error.', statusCode: e.response?.statusCode);
  }
}
