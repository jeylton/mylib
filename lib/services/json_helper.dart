import 'dart:convert';

class JsonHelper {
  static dynamic decode(String jsonString) {
    return jsonDecode(jsonString);
  }

  static String encode(dynamic data) {
    return jsonEncode(data);
  }
}
