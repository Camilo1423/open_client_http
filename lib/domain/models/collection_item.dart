enum CollectionItemType { folder, file }

class CollectionItem {
  final int? id;
  final String path;
  final String name;
  final CollectionItemType type;
  final String? parentPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CollectionItem({
    this.id,
    required this.path,
    required this.name,
    required this.type,
    this.parentPath,
    required this.createdAt,
    required this.updatedAt,
  });

  CollectionItem copyWith({
    int? id,
    String? path,
    String? name,
    CollectionItemType? type,
    String? parentPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollectionItem(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      type: type ?? this.type,
      parentPath: parentPath ?? this.parentPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CollectionItem(id: $id, path: $path, name: $name, type: $type, parentPath: $parentPath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CollectionItem &&
        other.id == id &&
        other.path == path &&
        other.name == name &&
        other.type == type &&
        other.parentPath == parentPath;
  }

  @override
  int get hashCode {
    return Object.hash(id, path, name, type, parentPath);
  }

  /// Check if this item is a folder
  bool get isFolder => type == CollectionItemType.folder;

  /// Check if this item is a file
  bool get isFile => type == CollectionItemType.file;

  /// Get the directory path (parent path)
  String get directoryPath {
    if (path == '/') return '/';
    final parts = path.split('/');
    parts.removeLast();
    return parts.isEmpty ? '/' : parts.join('/');
  }

  /// Get the file extension (for files only)
  String? get fileExtension {
    if (isFolder) return null;
    final parts = name.split('.');
    return parts.length > 1 ? parts.last : null;
  }

  /// Get the file name without extension
  String get fileNameWithoutExtension {
    if (isFolder) return name;
    final parts = name.split('.');
    return parts.length > 1 ? parts.sublist(0, parts.length - 1).join('.') : name;
  }
} 