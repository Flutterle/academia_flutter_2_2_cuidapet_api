import 'dart:convert';

import 'package:cuidapet_api/application/logger/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/controller/auth_controller.dart';
import 'package:cuidapet_api/modules/user/service/i_user_service.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../../../core/fixture/fixture_reader.dart';
import '../../../core/mocks/logger/mock_logger.dart';
import '../../../core/mocks/shelf/mock_shelf.dart';

class MockUserService extends Mock implements IUserService {}

void main() {
  late IUserService userService;
  late ILogger log;
  late Request request;

  setUp(() {
    userService = MockUserService();
    log = MockLogger();
    request = MockShelfRequest();
    load();
  });

  group('Group test login with email and password', () {
    test('Should login with success', () async {
      //Arrange
      final controller = AuthController(userService: userService, log: log);
      when(() =>
          request
              .readAsString()).thenAnswer((_) async => Fixture.getJsonData(
          'modules/user/fixture/user_auth_controller_login_with_email_password.json'));
      when(() => userService.loginWithEmailPassword(any(), any(), any()))
          .thenAnswer((_) async => User(
                id: 1,
              ));

      //Act
      final response = await controller.login(request);

      //Assert
      final responseData = jsonDecode(await response.readAsString());
      expect(response.statusCode, 200);
      expect(responseData['access_token'], isNotEmpty);
      verify(() => userService.loginWithEmailPassword(any(), any(), any()))
          .called(1);
      verifyNever(
          () => userService.loginWithSocial(any(), any(), any(), any()));
    });

    test('Should return RequestException on login with email and password',
        () async {
      //Arrange
      final controller = AuthController(userService: userService, log: log);
      when(() => request.readAsString()).thenAnswer((_) async => '{"login": "", "social_login": false, "supplier_user": false}');

      //Act
      final response = await controller.login(request);

      //Assert
      final responseData = jsonDecode(await response.readAsString());
      expect(response.statusCode, 400);
      expect(responseData['errors'], isNotEmpty);
    });
  });

  group('Group test login social', () {
    test('Should login with success', () async {
      //Arrange
      final controller = AuthController(userService: userService, log: log);
      when(() =>
          request
              .readAsString()).thenAnswer((_) async => Fixture.getJsonData(
          'modules/user/fixture/user_auth_controller_login_social.json'));
      when(() => userService.loginWithSocial(any(), any(), any(), any()))
          .thenAnswer((_) async => User(
                id: 1,
              ));

      //Act
      final response = await controller.login(request);

      //Assert
      final responseData = jsonDecode(await response.readAsString());
      expect(response.statusCode, 200);
      expect(responseData['access_token'], isNotEmpty);
      verify(() => userService.loginWithSocial(any(), any(), any(), any()))
          .called(1);
      verifyNever(
          () => userService.loginWithEmailPassword(any(), any(), any()));
    });

    test('Should return RequestException on login social',
        () async {
      //Arrange
      final controller = AuthController(userService: userService, log: log);
      when(() => request.readAsString()).thenAnswer((_) async => '{"login": "", "social_login": true, "supplier_user": false}');

      //Act
      final response = await controller.login(request);

      //Assert
      final responseData = jsonDecode(await response.readAsString());
      expect(response.statusCode, 400);
      expect(responseData['errors'], isNotEmpty);
    });
  });
}
