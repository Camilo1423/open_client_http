import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_client_http/domain/models/http_response.dart';

class ResponseNotifier extends StateNotifier<HttpResponse?> {
  ResponseNotifier() : super(null);

  void setResponse(HttpResponse response) {
    state = response;
  }

  void clearResponse() {
    state = null;
  }
}

final responseProvider = StateNotifierProvider<ResponseNotifier, HttpResponse?>(
  (ref) => ResponseNotifier(),
);

final hasResponseProvider = Provider<bool>((ref) {
  return ref.watch(responseProvider) != null;
});

final responseStatusProvider = Provider<String?>((ref) {
  final response = ref.watch(responseProvider);
  if (response == null) return null;
  return '${response.statusCode} ${response.reasonPhrase}';
});

final responseIsJsonProvider = Provider<bool>((ref) {
  final response = ref.watch(responseProvider);
  return response?.isJson ?? false;
}); 