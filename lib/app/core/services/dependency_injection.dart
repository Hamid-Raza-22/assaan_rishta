// lib/core/dependency_injection.dart
import 'package:get/get.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/repositories/auth_repository.dart';


class DependencyInjection {
  static void init() {
    Get.put<AuthProvider>(AuthProvider());
    Get.put<AuthRepository>(AuthRepository(Get.find<AuthProvider>()));
  }
}
