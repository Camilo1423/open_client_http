import 'package:open_client_http/domain/models/request_history.dart';

abstract class RequestHistoryRepository {
  /// Insert a new request history record
  Future<int> insertRequestHistory(RequestHistory request);

  /// Get all request history with optional pagination
  Future<List<RequestHistory>> getAllRequestHistory({int? limit, int? offset});

  /// Get request history by ID
  Future<RequestHistory?> getRequestHistoryById(int id);

  /// Get request history filtered by HTTP method
  Future<List<RequestHistory>> getRequestHistoryByMethod(String method);

  /// Search request history by query string (searches URL, method, and response body)
  Future<List<RequestHistory>> searchRequestHistory(String query);

  /// Delete a request history record by ID
  Future<int> deleteRequestHistory(int id);

  /// Delete old request history records before the specified date
  Future<int> deleteOldRequestHistory(DateTime before);

  /// Clear all request history
  Future<int> clearAllRequestHistory();

  /// Get total count of request history records
  Future<int> getRequestHistoryCount();

  /// Get the most recent requests
  Future<List<RequestHistory>> getRecentRequests(int count);
} 