import 'package:get/get.dart';

import '../../data/providers/auth_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../viewmodels/signup_viewmodel.dart';
class SignupBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<AuthProvider>()));
    Get.lazyPut<SignupViewModel>(() => SignupViewModel(Get.find<AuthRepository>()));
  }
}