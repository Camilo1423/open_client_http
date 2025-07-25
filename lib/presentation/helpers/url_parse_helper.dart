import 'package:open_client_http/domain/models/url_parameter.dart';

class UrlHelper {
  // Constructor privado para evitar instanciación, ya que es una clase de utilidad estática.
  UrlHelper._();

  /// **Método 1: Parsear la URL Cruda a un Path y Lista de Parámetros**
  ///
  /// Recibe la cadena de URL tal como el usuario la escribe
  /// y la descompone en su path y una lista de UrlParameter.
  /// No realiza ninguna codificación de URL en este punto.
  static Map<String, dynamic> parseRawUrl(String rawUrlInput) {
    final uriParts = rawUrlInput.split('?');
    final path = uriParts[0];
    final List<UrlParameter> queryParams = [];

    if (uriParts.length > 1 && uriParts[1].isNotEmpty) {
      final queryString = uriParts[1];
      queryString.split('&').forEach((paramString) {
        queryParams.add(UrlParameter.fromString(paramString));
      });
    }

    return {'path': path, 'queryParams': queryParams};
  }

  /// **Método 2: Reconstruir la URL Cruda desde un Path y Lista de Parámetros**
  ///
  /// Recibe un path y una lista de UrlParameter
  /// y los une para formar la cadena de URL que se mostrará al usuario.
  /// Mantiene las variables `{{}}` intactas.
  static String rebuildRawUrl(String path, List<UrlParameter> queryParams) {
    String newUrl = path;

    if (queryParams.isNotEmpty) {
      newUrl += '?';
      final queryParts = queryParams
          .map((param) {
            // Mantenemos las variables {{VARIABLE}} intactas en la representación cruda
            return '${param.key}=${param.value}';
          })
          .join('&');
      newUrl += queryParts;
    }
    return newUrl;
  }

  /// **Método 3: Obtener la URL Final Procesada para la Petición HTTP**
  ///
  /// Recibe el path, la lista de UrlParameter y las variables de entorno.
  /// Reemplaza las variables `{{}}` por sus valores reales y codifica los componentes.
  /// Esta es la URL que debes usar para tu cliente HTTP.
  static String getProcessedUrl(
    String path,
    List<UrlParameter> queryParams,
    Map<String, String> environmentVariables,
  ) {
    String finalUrl = path;

    // Reemplaza variables en el path si las hay (ej. {{BASE_URL}}/users)
    finalUrl = _replaceVariables(finalUrl, environmentVariables);

    if (queryParams.isNotEmpty) {
      finalUrl += '?';
      final processedQueryParts = queryParams
          .map((param) {
            // Reemplaza variables en la clave y el valor del parámetro
            final processedKey = _replaceVariables(
              param.key,
              environmentVariables,
            );
            final processedValue = _replaceVariables(
              param.value,
              environmentVariables,
            );

            // Codifica tanto la clave como el valor antes de unirlos
            return '${Uri.encodeComponent(processedKey)}=${Uri.encodeComponent(processedValue)}';
          })
          .join('&');
      finalUrl += processedQueryParts;
    }

    // Utiliza Uri.encodeFull para la URL completa, o Uri.parse().toString() para un parseo más robusto.
    // Uri.encodeFull es generalmente suficiente si las partes ya han sido codificadas por Component.
    return Uri.encodeFull(finalUrl);
  }

  /// Método auxiliar para reemplazar variables en una cadena.
  static String _replaceVariables(String input, Map<String, String> envVars) {
    final regex = RegExp(
      r'\{\{([A-Z_][A-Z0-9_]*)\}\}',
    ); // Busca {{VARIABLE_NAME}}
    return input.replaceAllMapped(regex, (match) {
      final varName = match.group(1)!;
      return envVars[varName] ??
          ''; // Retorna el valor o una cadena vacía si no existe
    });
  }

  static String replaceBaseUrlVariables(
    String baseUrl,
    Map<String, String> envVars,
  ) {
    final urlFormatted = _replaceVariables(baseUrl, envVars);
    return urlFormatted;
  }

  static Map<String, String> replaceQueryParamsVariables(
    List<UrlParameter> queryParams,
    Map<String, String> envVars,
  ) {
    final queryParamsFormatted = <String, String>{};
    for (final param in queryParams) {
      final processedKey = Uri.encodeComponent(_replaceVariables(param.key, envVars));
      final processedValue = Uri.encodeComponent(_replaceVariables(param.value, envVars));
      queryParamsFormatted[processedKey] = processedValue;
    }
    return queryParamsFormatted;
  }

  static Map<String, String> replaceHeadersVariables(
    Map<String, String> headers,
    Map<String, String> envVars,
  ) {
    final headersFormatted = <String, String>{};
    headers.forEach((key, value) {
      final processedKey = _replaceVariables(key, envVars);
      final processedValue = _replaceVariables(value, envVars);
      headersFormatted[processedKey] = processedValue;
    });
    return headersFormatted;
  }

  static String replaceRawBodyVariables(
    String rawBody,
    Map<String, String> envVars,
  ) {
    final rawBodyFormatted = _replaceVariables(rawBody, envVars);
    return rawBodyFormatted;
  }

  static String replaceAuthTokenVariables(
    String authToken,
    Map<String, String> envVars,
  ) {
    final authTokenFormatted = _replaceVariables(authToken, envVars);
    return authTokenFormatted;
  }

  static Map<String, String> replaceAuthCredentialsVariables(
    String authUsername,
    String authPassword,
    Map<String, String> envVars,
  ) {
    final authUsernameFormatted = _replaceVariables(authUsername, envVars);
    final authPasswordFormatted = _replaceVariables(authPassword, envVars);
    return {
      "username": authUsernameFormatted,
      "password": authPasswordFormatted,
    };
  }
}
