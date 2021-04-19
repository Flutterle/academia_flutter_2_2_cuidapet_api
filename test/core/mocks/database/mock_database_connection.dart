import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mysql1/mysql1.dart';

import 'mock_mysql_connection.dart';
import 'mock_results.dart';

class MockDatabaseConnection extends Mock implements IDatabaseConnection {
  final mySqlConnection = MockMysqlConnection();

  @override
  Future<MySqlConnection> openConnection() async => mySqlConnection;

  void mockQuery(MockResults mockResult, [List<Object>? params]) {
    when(() => mySqlConnection.query(any(), any()))
        .thenAnswer((_) async => mockResult);
  }
}
