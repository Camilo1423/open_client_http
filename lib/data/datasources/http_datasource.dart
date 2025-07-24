import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:open_client_http/domain/models/current_request.dart';
import 'package:open_client_http/domain/models/http_response.dart' as app_response;

abstract class HttpDatasource {
  Future<app_response.HttpResponse> executeRequest(CurrentRequest request, int connectionTimeout, int readTimeout, int writeTimeout);
}

class HttpDatasourceImpl implements HttpDatasource {
  late final Dio _dio;
  late final CookieJar _cookieJar;

  HttpDatasourceImpl() {
    _cookieJar = CookieJar();
    _dio = Dio();
    _dio.interceptors.add(CookieManager(_cookieJar));
    
    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
    ));
  }

  @override
  Future<app_response.HttpResponse> executeRequest(
    CurrentRequest request, 
    int connectionTimeout, 
    int readTimeout, 
    int writeTimeout
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Configure timeouts
      _dio.options.connectTimeout = Duration(seconds: connectionTimeout);
      _dio.options.receiveTimeout = Duration(seconds: readTimeout);
      _dio.options.sendTimeout = Duration(seconds: writeTimeout);

      // Build request URL with query parameters
      final uri = _buildUri(request.url, request.queryParams);
      
      // Prepare headers
      final headers = Map<String, String>.from(request.headers);
      _addAuthorizationHeader(headers, request);

      // Prepare request data
      dynamic requestData;
      if (request.rawBody.isNotEmpty && 
          ['POST', 'PUT', 'PATCH'].contains(request.method.toUpperCase())) {
        requestData = request.rawBody;
        // Set content type if not provided
        if (!headers.containsKey('Content-Type')) {
          headers['Content-Type'] = 'application/json';
        }
      }

      // Execute request
      final response = await _dio.request(
        uri,
        options: Options(
          method: request.method.toUpperCase(),
          headers: headers,
        ),
        data: requestData,
      );

      stopwatch.stop();

      // Extract cookies
      final cookies = await _extractCookies(request.url);

      return app_response.HttpResponse(
        statusCode: response.statusCode ?? 0,
        reasonPhrase: response.statusMessage ?? '',
        headers: _extractHeaders(response.headers),
        cookies: cookies,
        body: _formatResponseBody(response.data),
        contentType: response.headers['content-type']?.first ?? '',
        timestamp: DateTime.now(),
        responseTime: stopwatch.elapsed,
      );

    } on DioException catch (e) {
      stopwatch.stop();
      return _handleDioException(e, stopwatch.elapsed);
    } catch (e) {
      stopwatch.stop();
      return app_response.HttpResponse(
        statusCode: 0,
        reasonPhrase: 'Unknown Error',
        headers: {},
        cookies: {},
        body: 'An unexpected error occurred: $e',
        contentType: 'text/plain',
        timestamp: DateTime.now(),
        responseTime: stopwatch.elapsed,
      );
    }
  }

  String _buildUri(String baseUrl, Map<String, String> queryParams) {
    if (queryParams.isEmpty) return baseUrl;
    
    final uri = Uri.parse(baseUrl);
    final newUri = uri.replace(queryParameters: {...uri.queryParameters, ...queryParams});
    return newUri.toString();
  }

  void _addAuthorizationHeader(Map<String, String> headers, CurrentRequest request) {
    switch (request.authMethod) {
      case AuthorizationMethod.bearerToken:
        if (request.authToken != null && request.authToken!.isNotEmpty) {
          headers['Authorization'] = 'Bearer ${request.authToken}';
        }
        break;
      case AuthorizationMethod.basicAuth:
        if (request.authUsername != null && request.authPassword != null) {
          final credentials = '${request.authUsername}:${request.authPassword}';
          final encoded = base64Encode(utf8.encode(credentials));
          headers['Authorization'] = 'Basic $encoded';
        }
        break;
      case AuthorizationMethod.apiKey:
        if (request.authToken != null && request.authToken!.isNotEmpty) {
          headers['X-API-Key'] = request.authToken!;
        }
        break;
      case AuthorizationMethod.none:
        break;
    }
  }

  Map<String, String> _extractHeaders(Headers headers) {
    final result = <String, String>{};
    headers.forEach((name, values) {
      if (values.isNotEmpty) {
        result[name] = values.join(', ');
      }
    });
    return result;
  }

  Future<Map<String, String>> _extractCookies(String url) async {
    final uri = Uri.parse(url);
    final cookies = await _cookieJar.loadForRequest(uri);
    final result = <String, String>{};
    
    for (final cookie in cookies) {
      result[cookie.name] = cookie.value;
    }
    
    return result;
  }

  String _formatResponseBody(dynamic data) {
    if (data is String) {
      return data;
    } else if (data is Map || data is List) {
      return jsonEncode(data);
    } else {
      return data.toString();
    }
  }

  app_response.HttpResponse _handleDioException(DioException e, Duration responseTime) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return app_response.HttpResponse(
          statusCode: 0,
          reasonPhrase: 'Connection Timeout',
          headers: {},
          cookies: {},
          body: 'Connection timeout. Please check your internet connection and try again.',
          contentType: 'text/plain',
          timestamp: DateTime.now(),
          responseTime: responseTime,
        );
      
      case DioExceptionType.sendTimeout:
        return app_response.HttpResponse(
          statusCode: 0,
          reasonPhrase: 'Send Timeout',
          headers: {},
          cookies: {},
          body: 'Request timeout while sending data.',
          contentType: 'text/plain',
          timestamp: DateTime.now(),
          responseTime: responseTime,
        );
      
      case DioExceptionType.receiveTimeout:
        return app_response.HttpResponse(
          statusCode: 0,
          reasonPhrase: 'Receive Timeout',
          headers: {},
          cookies: {},
          body: 'Request timeout while receiving data.',
          contentType: 'text/plain',
          timestamp: DateTime.now(),
          responseTime: responseTime,
        );
      
      case DioExceptionType.badResponse:
        final response = e.response;
        return app_response.HttpResponse(
          statusCode: response?.statusCode ?? 0,
          reasonPhrase: response?.statusMessage ?? 'Bad Response',
          headers: response != null ? _extractHeaders(response.headers) : {},
          cookies: {},
          body: _formatResponseBody(response?.data) ?? 'No response body',
          contentType: response?.headers['content-type']?.first ?? 'text/plain',
          timestamp: DateTime.now(),
          responseTime: responseTime,
        );
      
      case DioExceptionType.cancel:
        return app_response.HttpResponse(
          statusCode: 0,
          reasonPhrase: 'Request Cancelled',
          headers: {},
          cookies: {},
          body: 'Request was cancelled.',
          contentType: 'text/plain',
          timestamp: DateTime.now(),
          responseTime: responseTime,
        );
      
      case DioExceptionType.badCertificate:
        return app_response.HttpResponse(
          statusCode: 0,
          reasonPhrase: 'Bad Certificate',
          headers: {},
          cookies: {},
          body: 'SSL certificate error. The server certificate is not trusted.',
          contentType: 'text/plain',
          timestamp: DateTime.now(),
          responseTime: responseTime,
        );
      
      case DioExceptionType.connectionError:
        return app_response.HttpResponse(
          statusCode: 0,
          reasonPhrase: 'Connection Error',
          headers: {},
          cookies: {},
          body: 'Connection error: ${e.message}',
          contentType: 'text/plain',
          timestamp: DateTime.now(),
          responseTime: responseTime,
        );
      
      default:
        return app_response.HttpResponse(
          statusCode: 0,
          reasonPhrase: 'Unknown Error',
          headers: {},
          cookies: {},
          body: 'An unknown error occurred: ${e.message}',
          contentType: 'text/plain',
          timestamp: DateTime.now(),
          responseTime: responseTime,
        );
    }
  }
}