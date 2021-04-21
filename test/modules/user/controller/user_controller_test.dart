
import 'package:cuidapet_api/application/logger/i_logger.dart';
import 'package:cuidapet_api/modules/user/controller/user_controller.dart';
import 'package:cuidapet_api/modules/user/service/i_user_service.dart';
import 'package:cuidapet_api/modules/user/view_models/user_update_token_device_input_model.dart';
import 'package:dotenv/dotenv.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../../../core/fixture/fixture_reader.dart';
import '../../../core/mocks/logger/mock_logger.dart';
import '../../../core/mocks/shelf/mock_request.dart';

class MockUserService extends Mock implements IUserService {}

void main() { late IUserService userService;
  late ILogger log;
  late Request request;

  setUp(() {
    userService = MockUserService();
    log = MockLogger();
    request = MockShelfRequest();
    load();
  });

  test('Should update device', () async {
    //Arrange
    final userController = UserController(userService: userService, log: log);
    final jsonRequest = Fixture.getJsonData('modules/user/fixture/user_controller_update_device_token.json');
    final updateDeviceToken = UserUpdateTokenDeviceInputModel(userId: 123, dataRequest: jsonRequest);
    registerFallbackValue(updateDeviceToken);
    when(() => request.headers).thenReturn({'user': '123'});
    when(() => userService.updateDeviceToken(any())).thenAnswer((_) async => _);
    when(() => request.readAsString()).thenAnswer((_) async => jsonRequest);

    //Act
    final response = await userController.updateDeviceToken(request);
    
    //Assert
    expect(response.statusCode, 200);
    verify(() => request.readAsString()).called(1);
    verify(() => request.headers['user']).called(1);
    verify(() => userService.updateDeviceToken(any())).called(1);
  });

}