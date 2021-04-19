export 'mock_database_connection.dart';
export 'mock_mysql_connection.dart';
export 'mock_result_rows.dart';
export 'mock_results.dart';

import 'package:mocktail/mocktail.dart';
import 'package:mysql1/mysql1.dart';

class MockMySqlException extends Mock implements MySqlException {}