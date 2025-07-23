class CurrentRequest {
  final String method;
  final String url;
  final Map<String, String> queryParams;
  final Map<String, String> headers;
  final AuthorizationMethod authMethod;
  final String? authToken;
  final String? authUsername;
  final String? authPassword;
  final String rawBody;

  const CurrentRequest({
    this.method = 'GET',
    this.url = '',
    this.queryParams = const {},
    this.headers = const {},
    this.authMethod = AuthorizationMethod.none,
    this.authToken,
    this.authUsername,
    this.authPassword,
    this.rawBody = '',
  });

  CurrentRequest copyWith({
    String? method,
    String? url,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    AuthorizationMethod? authMethod,
    String? authToken,
    String? authUsername,
    String? authPassword,
    String? rawBody,
  }) {
    return CurrentRequest(
      method: method ?? this.method,
      url: url ?? this.url,
      queryParams: queryParams ?? this.queryParams,
      headers: headers ?? this.headers,
      authMethod: authMethod ?? this.authMethod,
      authToken: authToken ?? this.authToken,
      authUsername: authUsername ?? this.authUsername,
      authPassword: authPassword ?? this.authPassword,
      rawBody: rawBody ?? this.rawBody,
    );
  }

  @override
  String toString() {
    return 'CurrentRequest(method: $method, url: $url, queryParams: $queryParams, headers: $headers, authMethod: $authMethod, rawBody: $rawBody)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrentRequest &&
        other.method == method &&
        other.url == url &&
        other.queryParams.toString() == queryParams.toString() &&
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
      method,
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

enum AuthorizationMethod {
  none,
  bearerToken,
  basicAuth,
  apiKey,
}

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