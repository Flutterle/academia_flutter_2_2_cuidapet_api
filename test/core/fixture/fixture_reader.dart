import 'dart:convert';
import 'dart:io';

class Fixture {

  Fixture._();

  static T getData<T>(String path) => jsonDecode(File('test/$path').readAsStringSync());
  static String getJsonData(String path) => File('test/$path').readAsStringSync();
}
