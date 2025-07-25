import 'package:open_client_http/domain/models/url_parameter.dart';

class CurrentRequest {
  final String? id;
  final String method;
  final String baseUrl;
  final String url;
  final List<UrlParameter> queryParams;
  final Map<String, String> finalQueryParams;
  final Map<String, String> headers;
  final AuthorizationMethod authMethod;
  final String? authToken;
  final String? authUsername;
  final String? authPassword;
  final String rawBody;

  const CurrentRequest({
    this.id,
    this.method = 'GET',
    this.baseUrl = '',
    this.url = '',
    this.queryParams = const [],
    this.finalQueryParams = const {},
    this.headers = const {},
    this.authMethod = AuthorizationMethod.none,
    this.authToken,
    this.authUsername,
    this.authPassword,
    this.rawBody = '',
  });

  CurrentRequest copyWith({
    String? id,
    String? method,
    String? baseUrl,
    String? url,
    List<UrlParameter>? queryParams,
    Map<String, String>? finalQueryParams,
    Map<String, String>? headers,
    AuthorizationMethod? authMethod,
    String? authToken,
    String? authUsername,
    String? authPassword,
    String? rawBody,
  }) {
    return CurrentRequest(
      id: id ?? this.id,
      method: method ?? this.method,
      baseUrl: baseUrl ?? this.baseUrl,
      url: url ?? this.url,
      queryParams: queryParams ?? this.queryParams,
      finalQueryParams: finalQueryParams ?? this.finalQueryParams,
      headers: headers ?? this.headers,
      authMethod: authMethod ?? this.authMethod,
      authToken: authToken ?? this.authToken,
      authUsername: authUsername ?? this.authUsername,
      authPassword: authPassword ?? this.authPassword,
      rawBody: rawBody ?? this.rawBody,
    );
  }

  /// Check if this request is saved (has an ID)
  bool get isSaved => id != null && id!.isNotEmpty;

  @override
  String toString() {
    return 'CurrentRequest(id: $id, method: $method, baseUrl: $baseUrl, url: $url, queryParams: $queryParams, finalQueryParams: $finalQueryParams, headers: $headers, authMethod: $authMethod, rawBody: $rawBody)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrentRequest &&
        other.id == id &&
        other.method == method &&
        other.baseUrl == baseUrl &&
        other.url == url &&
        other.queryParams.toString() == queryParams.toString() &&
        other.finalQueryParams.toString() == finalQueryParams.toString() &&
        other.headers.toString() == headers.toString() &&
        other.authMethod == authMethod &&
        other.authToken == authToken &&
        other.authUsername == authUsername &&
        other.authPassword == authPassword &&
        other.rawBody == rawBody;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      method,
      baseUrl,
      url,
      queryParams,
      headers,
      authMethod,
      authToken,
      authUsername,
      authPassword,
      rawBody,
    );
  }
}

enum AuthorizationMethod { none, bearerToken, basicAuth, apiKey }

extension AuthorizationMethodExtension on AuthorizationMethod {
  String get displayName {
    switch (this) {
      case AuthorizationMethod.none:
        return 'No Auth';
      case AuthorizationMethod.bearerToken:
        return 'Bearer Token';
      case AuthorizationMethod.basicAuth:
        return 'Basic Auth';
      case AuthorizationMethod.apiKey:
        return 'API Key';
    }
  }
}
