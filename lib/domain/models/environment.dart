class Environment {
  final int? id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Environment({
    this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from database row
  factory Environment.fromMap(Map<String, dynamic> map) {
    return Environment(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Copy with method
  Environment copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Environment(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Environment(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Environment &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
} 