class RequestHistory {
  final int? id;
  final String url;
  final String method;
  final Map<String, String>? headers;
  final String? body;
  final int? responseStatus;
  final String? responseBody;
  final Map<String, String>? responseHeaders;
  final DateTime createdAt;
  final int? executionTime; // in milliseconds

  const RequestHistory({
    this.id,
    required this.url,
    required this.method,
    this.headers,
    this.body,
    this.responseStatus,
    this.responseBody,
    this.responseHeaders,
    required this.createdAt,
    this.executionTime,
  });

  /// Create from database row
  factory RequestHistory.fromMap(Map<String, dynamic> map) {
    return RequestHistory(
      id: map['id'] as int?,
      url: map['url'] as String,
      method: map['method'] as String,
      headers: map['headers'] != null 
          ? Map<String, String>.from(_parseJson(map['headers'] as String))
          : null,
      body: map['body'] as String?,
      responseStatus: map['response_status'] as int?,
      responseBody: map['response_body'] as String?,
      responseHeaders: map['response_headers'] != null
          ? Map<String, String>.from(_parseJson(map['response_headers'] as String))
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      executionTime: map['execution_time'] as int?,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'method': method,
      'headers': headers != null ? _encodeJson(headers!) : null,
      'body': body,
      'response_status': responseStatus,
      'response_body': responseBody,
      'response_headers': responseHeaders != null ? _encodeJson(responseHeaders!) : null,
      'created_at': createdAt.millisecondsSinceEpoch,
      'execution_time': executionTime,
    };
  }

  /// Copy with method
  RequestHistory copyWith({
    int? id,
    String? url,
    String? method,
    Map<String, String>? headers,
    String? body,
    int? responseStatus,
    String? responseBody,
    Map<String, String>? responseHeaders,
    DateTime? createdAt,
    int? executionTime,
  }) {
    return RequestHistory(
      id: id ?? this.id,
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      responseStatus: responseStatus ?? this.responseStatus,
      responseBody: responseBody ?? this.responseBody,
      responseHeaders: responseHeaders ?? this.responseHeaders,
      createdAt: createdAt ?? this.createdAt,
      executionTime: executionTime ?? this.executionTime,
    );
  }

  @override
  String toString() {
    return 'RequestHistory(id: $id, method: $method, url: $url, status: $responseStatus, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RequestHistory &&
        other.id == id &&
        other.url == url &&
        other.method == method &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, url, method, createdAt);
}

// Helper functions for JSON encoding/decoding
dynamic _parseJson(String jsonString) {
  try {
    // Simple JSON parsing for headers
    if (jsonString.startsWith('{') && jsonString.endsWith('}')) {
      final content = jsonString.substring(1, jsonString.length - 1);
      final map = <String, String>{};
      
      if (content.isNotEmpty) {
        final pairs = content.split(',');
        for (final pair in pairs) {
          final keyValue = pair.split(':');
          if (keyValue.length == 2) {
            final key = keyValue[0].trim().replaceAll('"', '');
            final value = keyValue[1].trim().replaceAll('"', '');
            map[key] = value;
          }
        }
      }
      return map;
    }
    return <String, String>{};
  } catch (e) {
    return <String, String>{};
  }
}

String _encodeJson(Map<String, String> map) {
  if (map.isEmpty) return '{}';
  
  final entries = map.entries.map((entry) => '"${entry.key}":"${entry.value}"');
  return '{${entries.join(',')}}';
} 