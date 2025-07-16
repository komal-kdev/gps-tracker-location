import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gps_tracker/services/login_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';


class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  late String testPath;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return testPath;
  }
}


void main() {
  late Directory testDir;
  late File signupFile;

  setUpAll(() async {
    
    final fakePlatform = FakePathProviderPlatform();
    PathProviderPlatform.instance = fakePlatform;

    
    testDir = await Directory.systemTemp.createTemp('test_dir');
    fakePlatform.testPath = testDir.path;

    signupFile = File('${testDir.path}/signup_data.json');

    
    final users = [
      {
        "email": "bheema@gmail.com",
        "password": "bheema",
        "firstName": "bheema"
      },
      {
        "email": "test@example.com",
        "password": "1234"
      }
    ];

    await signupFile.writeAsString(jsonEncode(users));
  });

  tearDownAll(() async {
    
    if (await signupFile.exists()) {
      await signupFile.delete();
    }
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  test('Valid login returns user data', () async {
    final service = LoginService();
    final user = await service.login("bheema@gmail.com", "bheema");
    expect(user, isNotNull);
    expect(user?['firstName'], equals("bheema"));

  });

  test(' Wrong password returns null', () async {
    final service = LoginService();
    final user = await service.login("bheema@gmail.com", "wrongpass");
    expect(user, isNull);
  });

  test(' Unknown email returns null', () async {
    final service = LoginService();
    final user = await service.login("unknown@email.com", "any");
    expect(user, isNull);
  });

  test(' Missing file returns null', () async {
    if (await signupFile.exists()) {
      await signupFile.delete();
    }

    final service = LoginService();
    final user = await service.login("anything", "anything");
    expect(user, isNull);
  });
}
