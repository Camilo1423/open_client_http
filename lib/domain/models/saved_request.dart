import 'package:open_client_http/domain/models/current_request.dart';

class SavedRequest {
  final int? id;
  final String collectionPath;
  final String name;
  final CurrentRequest request;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedRequest({
    this.id,
    required this.collectionPath,
    required this.name,
    required this.request,
    required this.createdAt,
    required this.updatedAt,
  });

  SavedRequest copyWith({
    int? id,
    String? collectionPath,
    String? name,
    CurrentRequest? request,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedRequest(
      id: id ?? this.id,
      collectionPath: collectionPath ?? this.collectionPath,
      name: name ?? this.name,
      request: request ?? this.request,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SavedRequest(id: $id, collectionPath: $collectionPath, name: $name, request: $request)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavedRequest &&
        other.id == id &&
        other.collectionPath == collectionPath &&
        other.name == name &&
        other.request == request;
  }

  @override
  int get hashCode {
    return Object.hash(id, collectionPath, name, request);
  }

  /// Get the full path including the request name
  String get fullPath => '$collectionPath/$name';

  /// Get the file extension
  String? get fileExtension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.last : null;
  }

  /// Get the file name without extension
  String get fileNameWithoutExtension {
    final parts = name.split('.');
    return parts.length > 1 ? parts.sublist(0, parts.length - 1).join('.') : name;
  }

  /// Convert to CurrentRequest for editing
  CurrentRequest toCurrentRequest() {
    return request;
  }

  /// Create from CurrentRequest
  static SavedRequest fromCurrentRequest({
    required String collectionPath,
    required String name,
    required CurrentRequest request,
  }) {
    final now = DateTime.now();
    return SavedRequest(
      collectionPath: collectionPath,
      name: name,
      request: request,
      createdAt: now,
      updatedAt: now,
    );
  }
} 