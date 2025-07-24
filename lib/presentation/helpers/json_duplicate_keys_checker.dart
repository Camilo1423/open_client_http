class JsonDuplicateKeyChecker {
  final String _jsonText;
  final int _length;
  int _index = 0;
  bool _hasDuplicate =
      false;

  JsonDuplicateKeyChecker(this._jsonText) : _length = _jsonText.length;

  bool hasDuplicateKeys() {
    _skipWhitespace();
    _parseValue();
    return _hasDuplicate;
  }

  bool _skipWhitespace() {
    while (_index < _length && _jsonText[_index].trim().isEmpty) {
      _index++;
    }
    return _index < _length;
  }

  bool _consumeChar(String char) {
    if (_skipWhitespace() && _jsonText[_index] == char) {
      _index++;
      return true;
    }
    return false;
  }

  String? _parseString() {
    if (!_consumeChar('"')) return null;

    final buffer = StringBuffer();
    while (_index < _length) {
      if (_jsonText[_index] == '\\') {
        // Manejo de caracteres de escape
        _index++;
        if (_index < _length) {
          buffer.write(_jsonText[_index]);
          _index++;
        }
      } else if (_jsonText[_index] == '"') {
        // Fin de la cadena
        _index++;
        return buffer.toString();
      } else {
        buffer.write(_jsonText[_index]);
        _index++;
      }
    }
    return null;
  }

  bool _parseValue() {
    if (!_skipWhitespace()) return false;

    final char = _jsonText[_index];
    if (char == '"') {
      _parseString();
      return true;
    } else if (char == '{') {
      return _parseObject();
    } else if (char == '[') {
      return _parseArray();
    } else {
      while (_index < _length &&
          RegExp(r'[^\s,\}\]]').hasMatch(_jsonText[_index])) {
        _index++;
      }
      return true;
    }
  }

  bool _parseArray() {
    if (!_consumeChar('[')) return false;
    while (_skipWhitespace() && _jsonText[_index] != ']') {

      _skipWhitespace();
      if (_jsonText[_index] == ',') {
        _index++;
      } else {
        break;
      }
    }
    return _consumeChar(']');
  }

  bool _parseObject() {
    if (!_consumeChar('{')) return false;

    final seenKeys =
        <
          String
        >{};

    while (_skipWhitespace() && _jsonText[_index] != '}') {
      final key = _parseString();
      if (key == null) return false;

      if (seenKeys.contains(key)) {
        _hasDuplicate = true;
      }
      seenKeys.add(key);

      if (!_consumeChar(':'))
        return false;
      if (!_parseValue()) return false;

      _skipWhitespace();
      if (_jsonText[_index] == ',') {
        _index++;
      } else {
        break;
      }
    }

    return _consumeChar('}');
  }
}
