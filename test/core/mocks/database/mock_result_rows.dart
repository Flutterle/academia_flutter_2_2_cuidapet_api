import 'package:mocktail/mocktail.dart';
import 'package:mysql1/mysql1.dart';
import 'package:test/test.dart';

class MockResultRow extends Mock implements ResultRow {
  @override
  List<Object?>? values;

  @override
  Map<String, dynamic> fields;

  List<String>? blobFields;

  MockResultRow(this.fields, [this.blobFields]);

  @override
  dynamic operator [](dynamic? index) {
    if (index is int) {
      return values?[index];
    } else {
      if (fields.containsKey(index.toString())) {
        if (blobFields != null && blobFields!.contains(index.toString())) {
          return Blob.fromString(fields[index.toString()]);
        } else {
          return fields[index.toString()];
        }
      }else{
        fail('Field $index not found in fixture');
      }
    }
  }
}
