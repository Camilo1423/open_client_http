import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/data/data.dart';
import 'package:open_client_http/domain/domain.dart';
import 'package:open_client_http/presentation/helpers/url_parse_helper.dart';
import 'package:open_client_http/presentation/provider/settings/timeout_settings_provider.dart';
import 'package:open_client_http/presentation/provider/response/response_provider.dart';
import 'package:open_client_http/presentation/provider/environment/selected_environment_provider.dart';
import 'package:open_client_http/presentation/provider/current_request/current_request_provider.dart';

// Dependency injection providers
final httpDatasourceProvider = Provider<HttpDatasource>((ref) {
  return HttpDatasourceImpl();
});

final httpRepositoryProvider = Provider<HttpRepository>((ref) {
  final datasource = ref.watch(httpDatasourceProvider);
  final timeoutSettings = ref.watch(timeoutSettingsNotifierProvider).value ?? TimeoutSettings.defaultSettings;
  
  return HttpRepositoryImpl(
    datasource: datasource,
    timeoutSettings: timeoutSettings,
  );
});

final executeHttpRequestUseCaseProvider = Provider<ExecuteHttpRequestUseCase>((ref) {
  final repository = ref.watch(httpRepositoryProvider);
  return ExecuteHttpRequestUseCase(repository: repository);
});

// Request execution state
enum RequestState { idle, loading, success, error }

class RequestExecutionState {
  final RequestState state;
  final String? errorMessage;

  const RequestExecutionState({
    required this.state,
    this.errorMessage,
  });

  RequestExecutionState copyWith({
    RequestState? state,
    String? errorMessage,
  }) {
    return RequestExecutionState(
      state: state ?? this.state,
      errorMessage: errorMessage,
    );
  }
}

class RequestExecutionNotifier extends StateNotifier<RequestExecutionState> {
  final ExecuteHttpRequestUseCase _executeHttpRequestUseCase;
  final Ref _ref;

  RequestExecutionNotifier(this._executeHttpRequestUseCase, this._ref)
      : super(const RequestExecutionState(state: RequestState.idle));

  Future<void> executeRequest(CurrentRequest request) async {
    state = const RequestExecutionState(state: RequestState.loading);

    try {
      // Get environment variables for interpolation
      final environmentKeysMap = _ref.read(selectedEnvironmentKeysMapProvider);
      
      // Create a copy of the request with interpolated variables
      final interpolatedRequest = _interpolateRequestVariables(request, environmentKeysMap);
      
      final response = await _executeHttpRequestUseCase(interpolatedRequest);
      
      // Update response provider with the result
      _ref.read(responseProvider.notifier).setResponse(response);
      
      state = const RequestExecutionState(state: RequestState.success);
    } catch (e) {
      state = RequestExecutionState(
        state: RequestState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Helper method to interpolate variables in the request
  CurrentRequest _interpolateRequestVariables(CurrentRequest request, Map<String, String> environmentVars) {
    if (environmentVars.isEmpty) return request;

    // Interpolate URL
    final interpolatedUrl = UrlHelper.replaceBaseUrlVariables(request.baseUrl, environmentVars);
    
    // Interpolate query parameters
    final interpolatedQueryParams = UrlHelper.replaceQueryParamsVariables(request.queryParams, environmentVars);
    
    // Interpolate headers
    final interpolatedHeaders = UrlHelper.replaceHeadersVariables(request.headers, environmentVars);
    
    // Interpolate raw body
    final interpolatedRawBody = UrlHelper.replaceRawBodyVariables(request.rawBody, environmentVars);
    
    // Interpolate auth token if present
    String? interpolatedAuthToken;
    if (request.authToken != null) {
      interpolatedAuthToken = UrlHelper.replaceAuthTokenVariables(request.authToken!, environmentVars);
    }
    
    // Interpolate auth credentials if present
    Map<String, String>? interpolatedAuthCredentials;
    if (request.authUsername != null && request.authPassword != null) {
      interpolatedAuthCredentials = UrlHelper.replaceAuthCredentialsVariables(request.authUsername!, request.authPassword!, environmentVars);
    }
    
    return request.copyWith(
      baseUrl: interpolatedUrl,
      finalQueryParams: interpolatedQueryParams,
      headers: interpolatedHeaders,
      rawBody: interpolatedRawBody,
      authToken: interpolatedAuthToken,
      authUsername: interpolatedAuthCredentials?["username"],
      authPassword: interpolatedAuthCredentials?["password"],
    );
  }

  void reset() {
    state = const RequestExecutionState(state: RequestState.idle);
  }
}

final requestExecutionProvider = StateNotifierProvider<RequestExecutionNotifier, RequestExecutionState>((ref) {
  final useCase = ref.watch(executeHttpRequestUseCaseProvider);
  return RequestExecutionNotifier(useCase, ref);
});

// Computed providers for UI convenience
final isRequestLoadingProvider = Provider<bool>((ref) {
  return ref.watch(requestExecutionProvider).state == RequestState.loading;
});

final requestErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(requestExecutionProvider);
  return state.state == RequestState.error ? state.errorMessage : null;
}); 