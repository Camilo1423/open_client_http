class HttpResponse {
  final int statusCode;
  final String reasonPhrase;
  final Map<String, String> headers;
  final Map<String, String> cookies;
  final String body;
  final String contentType;
  final DateTime timestamp;
  final Duration responseTime;

  const HttpResponse({
    required this.statusCode,
    required this.reasonPhrase,
    this.headers = const {},
    this.cookies = const {},
    required this.body,
    required this.contentType,
    required this.timestamp,
    required this.responseTime,
  });

  bool get isJson {
    return contentType.toLowerCase().contains('application/json') ||
           _tryParseJson();
  }

  bool _tryParseJson() {
    if (body.trim().isEmpty) return false;
    try {
      final trimmed = body.trim();
      return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
             (trimmed.startsWith('[') && trimmed.endsWith(']'));
    } catch (e) {
      return false;
    }
  }

  int get responseSizeInBytes {
    return body.length;
  }

  String get formattedSize {
    final bytes = responseSizeInBytes;
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String get formattedResponseTime {
    final ms = responseTime.inMilliseconds;
    if (ms < 1000) {
      return '${ms}ms';
    } else {
      return '${(ms / 1000).toStringAsFixed(2)}s';
    }
  }

  HttpResponse copyWith({
    int? statusCode,
    String? reasonPhrase,
    Map<String, String>? headers,
    Map<String, String>? cookies,
    String? body,
    String? contentType,
    DateTime? timestamp,
    Duration? responseTime,
  }) {
    return HttpResponse(
      statusCode: statusCode ?? this.statusCode,
      reasonPhrase: reasonPhrase ?? this.reasonPhrase,
      headers: headers ?? this.headers,
      cookies: cookies ?? this.cookies,
      body: body ?? this.body,
      contentType: contentType ?? this.contentType,
      timestamp: timestamp ?? this.timestamp,
      responseTime: responseTime ?? this.responseTime,
    );
  }

  @override
  String toString() {
    return 'HttpResponse(statusCode: $statusCode, reasonPhrase: $reasonPhrase, contentType: $contentType, body: ${body.length} chars, responseTime: ${formattedResponseTime})';
  }
} 