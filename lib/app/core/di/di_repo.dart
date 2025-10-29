import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/export.dart';
import '../services/network_services/export.dart';
import '../services/storage_services/export.dart';

class RepoDependencies {
  late NetworkHelper _networkHelper;
  late EndPoints _artistEndPoints;
  late SharedPreferences sharedPreferences;
  late StorageRepo _storageRepo;

  Future init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    _artistEndPoints = EndPoints();
    _networkHelper = NetworkHelperImpl(sharedPreferences);
    _storageRepo = StorageRepoImpl(sharedPreferences);
  }

  initializeRepoDependencies() {
    Get.lazyPut<UserManagementRepo>(
          () =>
          UserManagementRepoImpl(
            _storageRepo,
            _networkHelper,
            _artistEndPoints,
            sharedPreferences,
          ),
      fenix: true,
    );
    Get.lazyPut<SystemConfigRepo>(
          () =>
          SystemConfigRepoImpl(
            _storageRepo,
            _networkHelper,
            _artistEndPoints,
            sharedPreferences,
          ),
      fenix: true,
    );
  }
}