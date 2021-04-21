import 'dart:convert';

import 'package:cuidapet_api/application/database/i_database_connection.dart';
import 'package:cuidapet_api/application/exceptions/database_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_exists_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/helpers/cripty_helper.dart';
import 'package:cuidapet_api/application/logger/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/user/data/user_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mysql1/mysql1.dart';
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
      final userFixture = Fixture.getJsonData(
          'modules/user/fixture/user_findbyid_database_response.json');
      final mockResults = MockResults(userFixture, [
        'ios_token',
        'android_token',
        'refresh_token',
        'img_avatar',
      ]);
      final userMap = jsonDecode(userFixture);
      final userExpect = User(
          id: userMap['id'],
          email: userMap['email'],
          registerType: userMap['tipo_cadastro'],
          iosToken: userMap['ios_token'],
          androidToken: userMap['android_token'],
          refreshToken: userMap['refresh_token'],
          imageAvatar: userMap['img_avatar'],
          supplierId: userMap['fornecedor_id']);

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

  group('Should test method createUser ', () {
    test('should create user with success', () async {
      final mockResults = MockResults();
      final mockDatabase = (database as MockDatabaseConnection);
      when(() => mockResults.insertId).thenReturn(1);
      mockDatabase.mockQuery(mockResults);

      final user = await repository.createUser(User());
      expect(user.id, 1);
    });

    test('should throw UserExistisException on create user', () async {
      final mockDatabase = (database as MockDatabaseConnection);
      final mysqlConnection = mockDatabase.mySqlConnection;
      final MySqlException exception = MockMySqlException();
      when(() => exception.message).thenReturn('usuario.email_UNIQUE');
      when(() => mysqlConnection.query(any(), any())).thenThrow(exception);

      final call = repository.createUser;
      expect(() => call(User()), throwsA(isA<UserExistsException>()));
    });

    test('should throw DatabaseException on create user', () async {
      final mysqlConnection =
          (database as MockDatabaseConnection).mySqlConnection;
      final MySqlException exception = MockMySqlException();
      when(() => exception.message).thenReturn('Erro');
      when(() => mysqlConnection.query(any(), any())).thenThrow(exception);

      final call = repository.createUser;
      expect(() => call(User()), throwsA(isA<DatabaseException>()));
    });
  });

  group('Should test method loginWithEmailPassword', () {
    test('Should login with email and password with success', () async {
      final userFixture = Fixture.getJsonData(
          'modules/user/fixture/user_login_with_email_password.json');
      final mockResults = MockResults(userFixture, [
        'ios_token',
        'android_token',
        'refresh_token',
        'img_avatar',
      ]);
      final userMap = jsonDecode(userFixture);
      final userExpect = User(
          id: userMap['id'],
          email: userMap['email'],
          registerType: userMap['tipo_cadastro'],
          iosToken: userMap['ios_token'],
          androidToken: userMap['android_token'],
          refreshToken: userMap['refresh_token'],
          imageAvatar: userMap['img_avatar'],
          supplierId: userMap['fornecedor_id']);
      final email = 'useremail';
      final password = 'userpassword';
      (database as MockDatabaseConnection).mockQuery(mockResults, [
        email,
        CriptyHelper.generateSha256Hash(password),
      ]);

      var user =
          await repository.loginWithEmailPassword(email, password, false);
      expect(user, userExpect);
    });

    test('Should login with email and password and return user not found',
        () async {
      final mockResults = MockResults('[]');
      final email = 'useremail';
      final password = 'userpassword';
      (database as MockDatabaseConnection).mockQuery(mockResults, [
        email,
        CriptyHelper.generateSha256Hash(password),
      ]);

      final call = repository.loginWithEmailPassword;
      expect(() => call(email, password, false),
          throwsA(isA<UserNotfoundException>()));
    });

    test('Should login with email and password and return DatabaseException',
        () async {
      final email = 'useremail';
      final password = 'userpassword';
      final mockConnection = (database as MockDatabaseConnection);
      mockConnection.mockQueryException();
      final call = repository.loginWithEmailPassword;
      expect(() => call(email, password, false),
          throwsA(isA<DatabaseException>()));
    });
  });

  group('Should test method loginByEmailSocialKey', () {
    test('Should login with email and social key with success and no update', () async {
      final userFixture = Fixture.getJsonData(
          'modules/user/fixture/user_login_with_email_social_key.json');
      final mockResults = MockResults(userFixture, [
        'ios_token',
        'android_token',
        'refresh_token',
        'img_avatar',
      ]);
      final userMap = jsonDecode(userFixture);
      final userExpect = User(
          id: userMap['id'],
          email: userMap['email'],
          registerType: userMap['tipo_cadastro'],
          iosToken: userMap['ios_token'],
          androidToken: userMap['android_token'],
          refreshToken: userMap['refresh_token'],
          imageAvatar: userMap['img_avatar'],
          supplierId: userMap['fornecedor_id']);
      final email = 'useremail';
      final socialKey = '123';
      final mysqlDatabaseConnection = (database as MockDatabaseConnection);
      mysqlDatabaseConnection.mockQuery(mockResults, [email]);

      var user =
          await repository.loginByEmailSocialKey(email, socialKey, 'FACEBOOK');
      verify(() => mysqlDatabaseConnection.mySqlConnection.query(any(), [email])).called(1);
      expect(user, userExpect);
    });

    test('Should login with email and social key with success and update social key', () async {
      final userFixture = Fixture.getJsonData(
          'modules/user/fixture/user_login_with_email_social_key.json');
      final mockResults = MockResults(userFixture, [
        'ios_token',
        'android_token',
        'refresh_token',
        'img_avatar',
      ]);
      final userMap = jsonDecode(userFixture);
      final userExpect = User(
          id: userMap['id'],
          email: userMap['email'],
          registerType: userMap['tipo_cadastro'],
          iosToken: userMap['ios_token'],
          androidToken: userMap['android_token'],
          refreshToken: userMap['refresh_token'],
          imageAvatar: userMap['img_avatar'],
          supplierId: userMap['fornecedor_id']);
      final email = 'useremail';
      final socialKey = '456';
      final socialType = 'FACEBOOK';
      final mysqlDatabaseConnection = (database as MockDatabaseConnection);
      mysqlDatabaseConnection.mockQuery(mockResults, [email]);
      mysqlDatabaseConnection.mockQuery(mockResults, [socialKey, socialType, userMap['id']]);

      var user =
          await repository.loginByEmailSocialKey(email, socialKey, socialType);
      verify(() => mysqlDatabaseConnection.mySqlConnection.query(any(), [email])).called(1);
      verify(() => mysqlDatabaseConnection.mySqlConnection.query(any(), [socialKey, socialType, userMap['id']])).called(1);
      expect(user, userExpect);
    });

    test('Should login with email and social key and return user not found',
        () async {
      final mockResults = MockResults('[]');
      final email = 'useremail';
      final socialKey = 'userpassword';
      final socialType = 'facebook';
      (database as MockDatabaseConnection).mockQuery(mockResults, [
        email,
      ]);

      final call = repository.loginByEmailSocialKey;
      expect(() => call(email, socialKey, socialType),
          throwsA(isA<UserNotfoundException>()));
    });

    test('Should login with email social key and return DatabaseException',
        () async {
      final email = 'useremail';
      final socialKey = '123';
      final socialType = 'FACEBOOK';
      final mockConnection = (database as MockDatabaseConnection);
      mockConnection.mockQueryException();
      final call = repository.loginByEmailSocialKey;
      expect(() => call(email, socialKey, socialType),
          throwsA(isA<DatabaseException>()));
    });
  });
}
