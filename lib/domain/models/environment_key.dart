class EnvironmentKey {
  final int? id;
  final int environmentId;
  final String key;
  final String value;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EnvironmentKey({
    this.id,
    required this.environmentId,
    required this.key,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from database row
  factory EnvironmentKey.fromMap(Map<String, dynamic> map) {
    return EnvironmentKey(
      id: map['id'] as int?,
      environmentId: map['environment_id'] as int,
      key: map['key'] as String,
      value: map['value'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'environment_id': environmentId,
      'key': key,
      'value': value,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Copy with method
  EnvironmentKey copyWith({
    int? id,
    int? environmentId,
    String? key,
    String? value,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnvironmentKey(
      id: id ?? this.id,
      environmentId: environmentId ?? this.environmentId,
      key: key ?? this.key,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'EnvironmentKey(id: $id, environmentId: $environmentId, key: $key, value: $value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnvironmentKey &&
        other.id == id &&
        other.environmentId == environmentId &&
        other.key == key;
  }

  @override
  int get hashCode => Object.hash(id, environmentId, key);
} 