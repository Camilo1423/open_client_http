class UrlParameter {
  String key;
  String value;
  bool isKeyVariable;
  bool isValueVariable;

  UrlParameter({
    required this.key,
    required this.value,
    this.isKeyVariable = false,
    this.isValueVariable = false,
  });

  factory UrlParameter.fromString(String paramString) {
    final parts = paramString.split('=');
    final key = parts[0];
    final value = parts.length > 1 ? parts.sublist(1).join('=') : '';

    final isKeyVar = key.startsWith('{{') && key.endsWith('}}');
    final isValueVar = value.startsWith('{{') && value.endsWith('}}');

    return UrlParameter(
      key: key,
      value: value,
      isKeyVariable: isKeyVar,
      isValueVariable: isValueVar,
    );
  }

  @override
  String toString() {
    return 'UrlParameter(key: $key, value: $value, isKeyVariable: $isKeyVariable, isValueVariable: $isValueVariable)';
  }
}