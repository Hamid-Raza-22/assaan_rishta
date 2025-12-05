

import 'package:dartz/dartz.dart';

import '../../../core/export.dart';
import '../../../core/services/network_services/result_type.dart';


mixin UserManagementRepo {
  ///Is User Logged In
  bool getUserLoggedInStatus();

  int? getUserId();

  String getUserName();

  String getUserEmail();

  String getUserPic();

  String getUserPassword();

  Future<Either<AppError, LoginModel>> login({
    required Map<String, dynamic> body,
  });

  Future<Either<AppError, String>> signUp({
    required SignUpModel signUpModel,
  });

  Future<Either<AppError, DonorClaims>> getDonorClaims();

  Future<Either<AppError, dynamic>> getProfileCompletionCount();

  Future<Either<AppError, dynamic>> deleteUserProfile();

  Future<Either<AppError, dynamic>> deactivateUserProfile();

  Future<Either<AppError, CurrentUserProfile>> getCurrentUserProfile();

  Future<Either<AppError, String>> updateProfilePic({required String picData});

  Future<Either<AppError, String>> updateProfileInfo({
    required String endPoint,
    required Map<String, dynamic> payload,
  });

  Future<Either<AppError, PartnerPreferenceData>> getPartnerPreference();


  Future<Either<AppError, String>> updatePartnerPreference({
    required Map<String, String> payload,
  });

  Future<Either<AppError, String>> updatePassword({
    required String password,
  });

 Future<Either<AppError, String>> resetPassword({
    required String password,required String email,
  });

  Future<Either<AppError, AllProfileList>> getAllProfiles({
    required int pageNo,
    required String pageLimit,
  });

  Future<Either<AppError, AllProfileList>> getAllFeaturedProfiles({
    required int pageNo,
    required String pageLimit,
  });

  Future<Either<AppError, AllProfileList>> getAllProfilesByFilter({
    required ProfileFilter profileFilter,
  });

  Future<Either<AppError, AllProfileList>> getAllProfilesByFilterForFeature({
    required ProfileFilter profileFilter,
  });

  Future<Either<AppError, ProfileDetails>> getProfilesDetails({
    required int uid,
  });

  ///vendors
  Future<Either<AppError, AllVendorsList>> getAllVendors({
    required int catId,
    required String pageNo,
    required int cityId,
  });

  Future<Either<AppError, List<VendorServices>>> getVendorServices(
      {required vendorId});

  Future<Either<AppError, List<VendorQuestions>>> getVendorQuestions(
      {required vendorId});

  Future<Either<AppError, List<VendorAlbums>>> getVendorAlbums(
      {required vendorId});

  Future<Either<AppError, List<VendorVideos>>> getVendorVideo(
      {required vendorId});

  Future<Either<AppError, List<VendorPackages>>> getVendorPackage(
      {required vendorId});

  ///favorites
  Future<Either<AppError, String>> addToFavorites({
    required int favUid,
  });

  Future<Either<AppError, List<FavoritesProfiles>>> getAllFavorites();

  Future<Either<AppError, String>> updateBlurProfileImage({required bool blur});
}
