import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/config/config.dart';
import 'package:open_client_http/domain/models/current_request.dart';

class CurrentRequestNotifier extends StateNotifier<CurrentRequest> {
  CurrentRequestNotifier() : super(_getInitialRequest());

  // Default headers for all requests
  static Map<String, String> get _defaultHeaders => {
    'User-Agent': 'OpenClientRuntime/${Enviroment.version}',
    'Accept': '*/*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Connection': 'keep-alive',
  };

  // Get initial request with default headers
  static CurrentRequest _getInitialRequest() {
    return CurrentRequest(headers: _defaultHeaders);
  }

  // Update HTTP method
  void updateMethod(String method) {
    state = state.copyWith(method: method);
  }

  // Update URL with automatic query parameter parsing
  void updateUrlWithParsing(String fullUrl) {
    final trimmedUrl = fullUrl.trim();

    // Handle empty URL
    if (trimmedUrl.isEmpty) {
      state = state.copyWith(url: '', queryParams: {});
      return;
    }

    try {
      final uri = Uri.parse(trimmedUrl);

      // Extract base URL (without query parameters)
      var baseUrl = uri.replace(queryParameters: {}).toString();

      // Remove trailing "?" if it exists
      if (baseUrl.endsWith('?')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }

      // Extract query parameters
      final queryParams = Map<String, String>.from(uri.queryParameters);

      // Update state with parsed values
      state = state.copyWith(url: baseUrl, queryParams: queryParams);
    } catch (e) {
      // If parsing fails, clean up any trailing "?" and use as base URL
      var cleanUrl = trimmedUrl;
      if (cleanUrl.endsWith('?')) {
        cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
      }
      state = state.copyWith(url: cleanUrl, queryParams: {});
    }
  }

  // Update URL (legacy method - kept for compatibility)
  void updateUrl(String url) {
    state = state.copyWith(url: url);
  }

  // Update query parameters
  void updateQueryParams(Map<String, String> queryParams) {
    state = state.copyWith(queryParams: queryParams);
  }

  // Add single query parameter
  void addQueryParam(String key, String value) {
    final newParams = Map<String, String>.from(state.queryParams);
    newParams[key] = value;
    state = state.copyWith(queryParams: newParams);
  }

  // Remove query parameter
  void removeQueryParam(String key) {
    final newParams = Map<String, String>.from(state.queryParams);
    newParams.remove(key);
    state = state.copyWith(queryParams: newParams);
  }

  // Update headers
  void updateHeaders(Map<String, String> headers) {
    state = state.copyWith(headers: headers);
  }

  // Add single header
  void addHeader(String key, String value) {
    final newHeaders = Map<String, String>.from(state.headers);
    newHeaders[key] = value;
    state = state.copyWith(headers: newHeaders);
  }

  // Remove header
  void removeHeader(String key) {
    final newHeaders = Map<String, String>.from(state.headers);
    newHeaders.remove(key);
    state = state.copyWith(headers: newHeaders);
  }

  // Restore default headers
  void restoreDefaultHeaders() {
    final currentHeaders = Map<String, String>.from(state.headers);
    // Add default headers, but don't override existing ones
    for (final entry in _defaultHeaders.entries) {
      if (!currentHeaders.containsKey(entry.key)) {
        currentHeaders[entry.key] = entry.value;
      }
    }
    state = state.copyWith(headers: currentHeaders);
  }

  // Get default headers (for UI reference)
  Map<String, String> getDefaultHeaders() {
    return Map<String, String>.from(_defaultHeaders);
  }

  // Update authorization method
  void updateAuthMethod(AuthorizationMethod authMethod) {
    state = state.copyWith(authMethod: authMethod);
  }

  // Update auth token (for Bearer Token)
  void updateAuthToken(String? token) {
    state = state.copyWith(authToken: token);
  }

  // Update basic auth credentials
  void updateBasicAuth(String? username, String? password) {
    state = state.copyWith(authUsername: username, authPassword: password);
  }

  // Update raw body
  void updateRawBody(String rawBody) {
    state = state.copyWith(rawBody: rawBody);
  }

  // Reset all to defaults
  void reset() {
    state = _getInitialRequest();
  }

  // Clear specific sections
  void clearQueryParams() {
    state = state.copyWith(queryParams: {});
  }

  void clearHeaders() {
    state = state.copyWith(headers: _defaultHeaders);
  }

  void clearAuth() {
    state = state.copyWith(
      authMethod: AuthorizationMethod.none,
      authToken: null,
      authUsername: null,
      authPassword: null,
    );
  }

  void clearBody() {
    state = state.copyWith(rawBody: '');
  }
}

final resetStateProvider = StateProvider<void>((ref) {
  ref.read(currentRequestProvider.notifier).reset();
});

// Main provider
final currentRequestProvider =
    StateNotifierProvider<CurrentRequestNotifier, CurrentRequest>(
      (ref) => CurrentRequestNotifier(),
    );

// Computed providers for specific parts
final currentMethodProvider = Provider<String>((ref) {
  return ref.watch(currentRequestProvider).method;
});

final currentUrlProvider = Provider<String>((ref) {
  return ref.watch(currentRequestProvider).url;
});

final currentQueryParamsProvider = Provider<Map<String, String>>((ref) {
  return ref.watch(currentRequestProvider).queryParams;
});

final currentHeadersProvider = Provider<Map<String, String>>((ref) {
  return ref.watch(currentRequestProvider).headers;
});

final currentAuthMethodProvider = Provider<AuthorizationMethod>((ref) {
  return ref.watch(currentRequestProvider).authMethod;
});

final currentRawBodyProvider = Provider<String>((ref) {
  return ref.watch(currentRequestProvider).rawBody;
});

// Helper provider to check if request is ready to send
final isRequestReadyProvider = Provider<bool>((ref) {
  final request = ref.watch(currentRequestProvider);
  return request.url.trim().isNotEmpty;
});

// Provider that combines URL + query parameters for display in input
final displayUrlProvider = Provider<String>((ref) {
  final request = ref.watch(currentRequestProvider);

  if (request.url.isEmpty) {
    return '';
  }

  // If there are no query parameters, return just the URL
  if (request.queryParams.isEmpty) {
    return request.url;
  }

  // Build the full URL with query parameters only if there are actual parameters
  try {
    final uri = Uri.parse(request.url);
    final fullUri = uri.replace(queryParameters: request.queryParams);
    return fullUri.toString();
  } catch (e) {
    // If URL parsing fails, return the base URL
    return request.url;
  }
});
