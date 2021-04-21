import 'dart:convert';

import 'package:cuidapet_api/application/exceptions/service_exception.dart';
import 'package:cuidapet_api/application/exceptions/user_notfound_exception.dart';
import 'package:cuidapet_api/application/helpers/jwt_helper.dart';
import 'package:cuidapet_api/application/logger/i_logger.dart';
import 'package:cuidapet_api/entities/user.dart';
import 'package:cuidapet_api/modules/user/data/i_user_repository.dart';
import 'package:cuidapet_api/modules/user/service/user_service.dart';
import 'package:cuidapet_api/modules/user/view_models/refresh_token_view_model.dart';
import 'package:cuidapet_api/modules/user/view_models/user_refresh_token_input_model.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../../../core/mocks/logger/mock_logger.dart';

class MockUserRepository extends Mock implements IUserRepository {}

void main() {
  late IUserRepository userRepository;
  late ILogger log;

  setUp(() {
    userRepository = MockUserRepository();
    log = MockLogger();
    registerFallbackValue<User>(User());
    load();
  });

  group('Group loginWithEmailPassword', () {
    test('Should login with email and password', () async {
      when(() => userRepository.loginWithEmailPassword(any(), any(), any()))
          .thenAnswer((_) async => User());
      final userService = UserService(userRepository: userRepository, log: log);

      final user =
          await userService.loginWithEmailPassword('email', 'password', false);
      expect(user, isNotNull);
      verify(() =>
          userRepository.loginWithEmailPassword('email', 'password', false));
    });
  });

  group('Group loginWithSocial', () {
    test('Should login social with success ', () async {
      when(() => userRepository.loginByEmailSocialKey(any(), any(), any()))
          .thenAnswer((_) async => User());
      final userService = UserService(userRepository: userRepository, log: log);

      final user = await userService.loginWithSocial(
          'email', 'avatar', 'socialType', 'socialKey');
      verify(() => userRepository.loginByEmailSocialKey(any(), any(), any()))
          .called(1);
      expect(user, isNotNull);
    });

    test('Should login social with user not found and create a new user ',
        () async {
      final email = 'rodrigorahman@academiadoflutter.com.br';
      final avatar = 'avatar';
      final socialType = 'FACEBOOK';
      final socialkey = '123123';
      final createdUser = User(
          id: 1,
          email: email,
          imageAvatar: avatar,
          registerType: socialType,
          socialKey: socialkey,
          password: '123123');

      when(() => userRepository.loginByEmailSocialKey(
              email, socialkey, socialType))
          .thenThrow(UserNotfoundException(message: 'message'));
      when(() => userRepository.createUser(any<User>()))
          .thenAnswer((_) async => createdUser);

      final userService = UserService(userRepository: userRepository, log: log);

      final user = await userService.loginWithSocial(
          email, avatar, socialType, socialkey);

      verify(() => userRepository.loginByEmailSocialKey(
          email, socialkey, socialType)).called(1);
      verify(() => userRepository.createUser(any<User>())).called(1);
      expect(user, createdUser);
    });
  });

  group('Group of refresh token', () {
    test('Should try refresh token JWT but return validate error (Bearer)',
        () async {
      //Arrange
      final model = UserRefreshTokenInputModel(
        user: 0,
        accessToken: '123',
        dataRequest: jsonEncode({'refresh_token': '123'}),
      );
      final userService = UserService(userRepository: userRepository, log: log);

      //Act
      final call = userService.refreshToken;

      //Assert
      expect(call(model), throwsA(isA<ServiceException>()));
    });

    test(
        'Should try refresh token JWT but return validate error (JwtException)',
        () async {
      //Arrange
      final accessToken = JwtHelper.generateJWT(1, null);
      final refreshToken = JwtHelper.refreshToken('123');

      final model = UserRefreshTokenInputModel(
        user: 0,
        accessToken: accessToken,
        dataRequest: jsonEncode({'refresh_token': refreshToken}),
      );
      final userService = UserService(userRepository: userRepository, log: log);

      //Act
      final call = userService.refreshToken;

      //Assert
      expect(call(model), throwsA(isA<ServiceException>()));
    });

    test('Should refresh token with success', () async {
      //Arrange
      env['refresh_token_not_before_days'] = '0';
      final userId = 1;
      final accessToken = JwtHelper.generateJWT(userId, null);
      final refreshToken = JwtHelper.refreshToken(accessToken);
      final model = UserRefreshTokenInputModel(
        user: userId,
        accessToken: accessToken,
        dataRequest: jsonEncode({'refresh_token': refreshToken}),
      );
      final userService = UserService(userRepository: userRepository, log: log);
      // Mock void methods
      when(() => userRepository.updateRefreshToken(any())).thenAnswer((_) async => _);

      //Act
      final tokens = await userService.refreshToken(model);

      //Assert
      expect(tokens, isA<RefreshTokenViewModel>());
      expect(tokens.accessToken, isNotEmpty);
      expect(tokens.refreshToken, isNotEmpty);
      verify(() => userRepository.updateRefreshToken(any())).called(1);
    });
  });

}
