import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/services.dart';
import 'dart:convert';

class JsonServices {
  static Future<dynamic> loadJsonData(String path) async {
    var jsonText = await rootBundle.loadString(path);
    return json.decode(jsonText);
  }
}
