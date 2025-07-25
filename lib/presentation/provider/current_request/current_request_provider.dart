import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/config/config.dart';
import 'package:open_client_http/domain/models/current_request.dart';
import 'package:open_client_http/domain/models/url_parameter.dart';
import 'package:open_client_http/presentation/helpers/url_parse_helper.dart';
import 'package:open_client_http/presentation/provider/environment/selected_environment_provider.dart';

class CurrentRequestNotifier extends StateNotifier<CurrentRequest> {
  CurrentRequestNotifier() : super(_getInitialRequest());

  // Default headers for all requests
  static Map<String, String> get _defaultHeaders => {
    'User-Agent': 'OpenClientRuntime/${Enviroment.version}',
    'Accept': '*/*',
    'Accept-Encoding': '*',
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
      state = state.copyWith(
        url: '', 
        baseUrl: '', 
        queryParams: []
      );
      return;
    }

    final urlFormatted = UrlHelper.parseRawUrl(fullUrl);
    final String path = urlFormatted['path'];
    final List<UrlParameter> queryParams = urlFormatted['queryParams'];

    state = state.copyWith(
      url: fullUrl,
      queryParams: queryParams,
      baseUrl: path,
    );
  }
  
  // Add single query parameter
  void addQueryParam(String key, String value) {
    final uriBase = state.baseUrl;
    final newParams = List<UrlParameter>.from(state.queryParams);
    newParams.add(UrlParameter(key: key, value: value));
    final newUrl = UrlHelper.rebuildRawUrl(uriBase, newParams);
    state = state.copyWith(queryParams: newParams, url: newUrl);
  }

  // Remove query parameter
  void removeQueryParam(String key) {
    final uriBase = state.baseUrl;
    final newParams = List<UrlParameter>.from(state.queryParams);
    newParams.removeWhere((param) => param.key == key);
    final newUrl = UrlHelper.rebuildRawUrl(uriBase, newParams);
    state = state.copyWith(queryParams: newParams, url: newUrl);
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

  // Set ID for saved request
  void setRequestId(String id) {
    state = state.copyWith(id: id);
  }

  // Clear ID (for new request)
  void clearRequestId() {
    state = state.copyWith(id: null);
  }

  // Reset all to defaults
  void reset() {
    state = _getInitialRequest();
  }

  // Clear specific sections
  void clearQueryParams() {
    // state = state.copyWith(queryParams: {});
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
  return {"hola": "hola"};
  // return ref.watch(currentRequestProvider).queryParams.map((param) => {param.key: param.value}).toMap();
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

// Check if current request is saved
final isRequestSavedProvider = Provider<bool>((ref) {
  return ref.watch(currentRequestProvider).isSaved;
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

  return request.url;
});

// Helper function to interpolate variables in text
String interpolateVariables(String text, Map<String, String> variables) {
  if (text.isEmpty || variables.isEmpty) return text;

  String result = text;

  // Regular expression to find variables in format {{VARIABLE_NAME}}
  final variableRegex = RegExp(r'\{\{([A-Z_][A-Z0-9_]*)\}\}');

  result = result.replaceAllMapped(variableRegex, (match) {
    final variableName = match.group(1)!;
    return variables[variableName] ??
        match.group(0)!; // Return original if not found
  });

  return result;
}

// Provider that shows the URL with interpolated variables (for preview)
final interpolatedUrlProvider = Provider<String>((ref) {
  final request = ref.watch(currentRequestProvider);
  final environmentKeysMap = ref.watch(selectedEnvironmentKeysMapProvider);

  if (request.url.isEmpty) {
    return '';
  }

  // First interpolate the base URL
  String interpolatedUrl = UrlHelper.getProcessedUrl(
    request.baseUrl,
    request.queryParams,
    environmentKeysMap,
  );

  return interpolatedUrl;
});

// Provider to detect if URL contains variables
final urlContainsVariablesProvider = Provider<bool>((ref) {
  final request = ref.watch(currentRequestProvider);
  final variableRegex = RegExp(r'\{\{([A-Z_][A-Z0-9_]*)\}\}');

  // validate if the url base contains variables
  final urlBase = request.baseUrl;
  final urlBaseMatches = variableRegex.allMatches(urlBase);
  if (urlBaseMatches.isNotEmpty) {
    return true;
  }

  // validate if the url query params contains variables
  final queryParams = request.queryParams;
  final queryParamsMatches = queryParams.any(
    (param) =>
        variableRegex.hasMatch(param.key) ||
        variableRegex.hasMatch(param.value),
  );
  if (queryParamsMatches) {
    return true;
  }

  return false;
});

// Provider to get list of detected variables in the URL
final detectedVariablesProvider = Provider<List<String>>((ref) {
  final request = ref.watch(currentRequestProvider);
  final variableRegex = RegExp(r'\{\{([A-Z_][A-Z0-9_]*)\}\}');
  final Set<String> variables = {};

  final completeUrl = UrlHelper.rebuildRawUrl(
    request.baseUrl,
    request.queryParams,
  );

  // Check URL for variables
  final urlMatches = variableRegex.allMatches(completeUrl);
  for (final match in urlMatches) {
    variables.add(match.group(1)!);
  }
  return variables.toList();
});

final isAvailableRequestProvider = Provider<String>((ref) {
  final request = ref.watch(currentRequestProvider);
  final environmentKeysMap = ref.watch(selectedEnvironmentKeysMapProvider);
  final variableRegex = RegExp(r'\{\{([A-Z_][A-Z0-9_]*)\}\}');

  // Helper to extract variables from a string
  Set<String> extractVariables(String? input) {
    if (input == null) return {};
    return variableRegex
        .allMatches(input)
        .map((match) => match.group(1)!)
        .toSet();
  }

  // Helper to extract variables from query params
  Set<String> extractVariablesFromQueryParams(List<dynamic> queryParams) {
    final Set<String> vars = {};
    for (final param in queryParams) {
      vars.addAll(extractVariables(param.key));
      vars.addAll(extractVariables(param.value));
    }
    return vars;
  }

  // 1. Gather all variables from all relevant fields
  final Set<String> allVariables = {};
  allVariables.addAll(extractVariables(request.baseUrl));
  allVariables.addAll(extractVariablesFromQueryParams(request.queryParams));

  // 2. Check if all variables are present in environmentKeysMap
  final missingVariables = allVariables
      .where((v) => !environmentKeysMap.containsKey(v))
      .toList();

  // 3. If there are missing variables, allow request (assume will be filled later)
  if (missingVariables.isNotEmpty) {
    // If there are variables but not all are resolved, allow request (no error)
    return 'Please enter a valid URL or fill the missing variables';
  }

  // 4. If no variables or all variables are resolved, validate the interpolated URL (baseUrl + queryParams)
  // Interpolate variables in baseUrl and queryParams
  String interpolate(String input) {
    return input.replaceAllMapped(variableRegex, (match) {
      final key = match.group(1)!;
      return environmentKeysMap[key] ?? match.group(0)!;
    });
  }

  final interpolatedBaseUrl = interpolate(request.baseUrl.trim());

  // Interpolate query params
  final interpolatedQueryParams = request.queryParams.map((param) {
    final key = interpolate(param.key);
    final value = interpolate(param.value);
    return {'key': key, 'value': value};
  }).toList();

  // Rebuild the full URL with interpolated values
  String buildUrl(String baseUrl, List<Map<String, String>> queryParams) {
    if (queryParams.isEmpty) return baseUrl;
    final queryString = queryParams
        .where((param) => param['key'] != null && param['key']!.isNotEmpty)
        .map((param) {
          final k = Uri.encodeQueryComponent(param['key']!);
          final v = param['value'] ?? '';
          return v.isNotEmpty ? '$k=${Uri.encodeQueryComponent(v)}' : k;
        })
        .join('&');
    return queryString.isNotEmpty ? '$baseUrl?$queryString' : baseUrl;
  }

  final interpolatedUrl = buildUrl(
    interpolatedBaseUrl,
    interpolatedQueryParams,
  );

  if (interpolatedUrl.isEmpty) {
    return 'Please enter a valid URL';
  }

  // Try to parse the interpolated URL to check if it's valid
  try {
    final uri = Uri.parse(interpolatedUrl);
    if (!uri.hasScheme || !uri.hasAuthority) {
      return 'Please enter a valid URL';
    }
  } catch (_) {
    return 'Please enter a valid URL';
  }

  // If everything is fine, return empty string (no error)
  return '';
});
