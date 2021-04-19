import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mysql1/mysql1.dart';

import 'database_mock.dart';
import 'mock_mysql_connection.dart';
import 'mock_results.dart';

class MockDatabaseConnection extends Mock implements IDatabaseConnection {
  final mySqlConnection = MockMysqlConnection();

  @override
  Future<MySqlConnection> openConnection() async => mySqlConnection;

  void mockQuery(MockResults mockResult, [List<Object>? params]) {
    when(() => mySqlConnection.query(any(), params ?? any()))
        .thenAnswer((_) async => mockResult);
  }

  void mockQueryException([MockMySqlException? mockException, List<Object>? params]) {
    var exception = mockException;
    if(exception == null){
      exception = MockMySqlException();
      when(() => exception!.message).thenReturn('');
    }
      when(() => mySqlConnection.query(any(), params ?? any())).thenThrow(exception);
  }
}
