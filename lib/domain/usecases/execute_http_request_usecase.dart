import 'package:open_client_http/domain/models/current_request.dart';
import 'package:open_client_http/domain/models/http_response.dart';
import 'package:open_client_http/domain/repositories/http_repository.dart';

class ExecuteHttpRequestUseCase {
  final HttpRepository _repository;

  ExecuteHttpRequestUseCase({required HttpRepository repository})
      : _repository = repository;

  Future<HttpResponse> call(CurrentRequest request) async {
    // Validate request
    if (request.url.trim().isEmpty) {
      throw ArgumentError('URL cannot be empty');
    }

    // Execute request
    return await _repository.executeRequest(request);
  }
} 