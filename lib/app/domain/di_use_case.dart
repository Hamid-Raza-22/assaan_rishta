import 'package:get/get.dart';
import '../viewmodels/chat_list_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';
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
  Get.lazyPut<ChatViewModel>(() => ChatViewModel(), fenix: true);
  Get.lazyPut<ChatListController>(() => ChatListController(), fenix: true);
}
