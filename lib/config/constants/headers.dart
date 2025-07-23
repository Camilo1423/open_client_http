const List<String> headers = [
  'Authorization',
  'Accept',
  'Accept-Charset',
  'Accept-Encoding',
  'Accept-Language',
  'Content-Type',
  'From',
  'Content-Length',
  'User-Agent',
  'X-api-key',
];

const List<String> accept = [
  'text/html',
  'text/plain',
  'image/*',
  'application/json',
  'application/xml',
  'application/x-www-form-urlencoded',
  'application/octet-stream',
  'application/pdf',
  'application/zip',
  'application/x-tar',
  'application/x-gzip',
];

const List<String> acceptCharset = [
  'utf-8',
  'iso-8859-1',
  'iso-8859-2',
  'iso-8859-3',
  'iso-8859-4',
  'iso-8859-5',
  'iso-8859-6',
];

const List<String> acceptEncoding = [
  'gzip',
  'deflate',
  'br',
  'identity',
  'compress',
  '*',
];

const List<String> acceptLanguage = [
  'en',
  'es',
  'fr',
  'de',
  'it',
  'pt',
  'zh',
  'ja',
  'en-US',
  'en-GB',
  'es-ES',
  'fr-FR',
  'de-DE',
  'it-IT',
  'pt-BR',
  'zh-CN',
  'ja-JP',
  'ru-RU',
  '*',
];

const List<String> contentType = [
  'application/json',
  'application/xml',
  'application/x-www-form-urlencoded',
  'multipart/form-data',
  'text/plain',
  'text/html',
  'text/css',
  'text/csv',
  'text/javascript',
  'application/javascript',
  'application/octet-stream',
  'application/pdf',
  'application/zip',
  'image/png',
  'image/jpeg',
  'image/gif',
  'image/webp',
  'audio/mpeg',
  'audio/wav',
  'video/mp4',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
];

const List<String> generics = ['client'];

const Map<String, List<String>> genericsHeaders = {
  'From': generics,
  'Accept': accept,
  'Accept-Charset': acceptCharset,
  'Accept-Encoding': acceptEncoding,
  'Accept-Language': acceptLanguage,
  'Content-Type': contentType,
};
