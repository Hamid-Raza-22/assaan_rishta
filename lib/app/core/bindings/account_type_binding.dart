import 'package:get/get.dart';

import '../../viewmodels/account_type_viewmodel.dart';

class AccountTypeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountTypeViewModel>(() => AccountTypeViewModel());
  }
}
