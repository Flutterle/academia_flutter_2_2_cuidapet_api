import 'dart:convert';

import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/logger/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/user/data/user_repository.dart';
import 'package:test/test.dart';

import '../../../core/fixture/fixture_reader.dart';
import '../../../core/mocks/database/database_mock.dart';
import '../../../core/mocks/logger/mock_logger.dart';

void main() {
  late IDatabaseConnection database;
  late ILogger logger;
  late IUserRepository repository;

  setUp(() {
    database = MockDatabaseConnection();
    logger = MockLogger();
    repository = UserRepository(connection: database, log: logger);
  });

  group('Should test method findById', () {
    test('Should return user by id', () async {
      final id = 1;
      final userFixture = Fixture.getJsonData('modules/user/fixture/user.json');
      final mockResults = MockResults(userFixture, ['ios_token']);
      final userMap = jsonDecode(userFixture);
      final userExpect =
          User(id: userMap['id'], iosToken: userMap['ios_token']);

      (database as MockDatabaseConnection).mockQuery(mockResults, [id]);

      var user = await repository.findById(id);
      expect(user, userExpect);
    });

    test('Should return exception UserNotfoundException', () async {
      final id = 1;
      final mockResults = MockResults();
      (database as MockDatabaseConnection).mockQuery(mockResults, [id]);
      var call = repository.findById;
      expect(() => call(id), throwsA(isA<UserNotfoundException>()));
    });
  });
}
