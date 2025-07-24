import 'package:get/get.dart';
import 'export.dart';

Future<void> initializeModelUseCasesDependencies() async {
  Get.lazyPut<UserManagementUseCase>(
    () => UserManagementUseCase(Get.find<UserManagementRepo>()),
    fenix: true,
  );
  Get.lazyPut<SystemConfigUseCase>(
    () => SystemConfigUseCase(Get.find<SystemConfigRepo>()),
    fenix: true,
  );
}
