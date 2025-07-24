import 'package:open_client_http/data/datasources/http_datasource.dart';
import 'package:open_client_http/domain/models/current_request.dart';
import 'package:open_client_http/domain/models/http_response.dart';
import 'package:open_client_http/domain/repositories/http_repository.dart';
import 'package:open_client_http/presentation/provider/settings/timeout_settings_provider.dart';

class HttpRepositoryImpl implements HttpRepository {
  final HttpDatasource _datasource;
  final TimeoutSettings _timeoutSettings;

  HttpRepositoryImpl({
    required HttpDatasource datasource,
    required TimeoutSettings timeoutSettings,
  }) : _datasource = datasource, _timeoutSettings = timeoutSettings;

  @override
  Future<HttpResponse> executeRequest(CurrentRequest request) async {
    return await _datasource.executeRequest(
      request,
      _timeoutSettings.connectionTimeout,
      _timeoutSettings.readTimeout,
      _timeoutSettings.writeTimeout,
    );
  }
} 