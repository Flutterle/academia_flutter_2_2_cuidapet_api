import 'dart:io';

import 'package:test/test.dart';

import 'fixture_reader.dart';

void main() {

  test('should return json', () async {
    final json = Fixture.getJsonData('core/fixture/fixture_test.json');

    expect(json, allOf([
      isNotNull,
      isNotEmpty
    ]));
  });

  test('should return Map<String,dynamic>', () async {
    final data = Fixture.getData('core/fixture/fixture_test.json');

    expect(data, allOf([
      isNotNull,
      isA<Map<String,dynamic>>(),
    ]));
    expect(data['id'], 1);
  });

  test('should return FileSystemException if is file not found', () async {
    final call = Fixture.getData;
    expect(() => call('erro.json'), throwsA(isA<FileSystemException>()));
  });

}