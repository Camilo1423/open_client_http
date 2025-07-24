import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/data/data.dart';
import 'package:open_client_http/domain/domain.dart';
import 'package:open_client_http/presentation/provider/settings/timeout_settings_provider.dart';
import 'package:open_client_http/presentation/provider/response/response_provider.dart';

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
      final response = await _executeHttpRequestUseCase(request);
      
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