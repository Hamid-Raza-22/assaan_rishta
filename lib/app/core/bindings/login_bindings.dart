import 'package:get/get.dart';

import '../../data/providers/auth_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../viewmodels/login_viewmodel.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<AuthProvider>()));
    Get.lazyPut<LoginViewModel>(() => LoginViewModel());
  }
}
