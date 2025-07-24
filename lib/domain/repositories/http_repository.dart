import 'package:open_client_http/domain/models/current_request.dart';
import 'package:open_client_http/domain/models/http_response.dart';

abstract class HttpRepository {
  Future<HttpResponse> executeRequest(CurrentRequest request);
} 