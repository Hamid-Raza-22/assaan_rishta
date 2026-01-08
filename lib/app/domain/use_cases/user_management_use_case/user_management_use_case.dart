import 'package:dartz/dartz.dart';

import '../../../core/export.dart';
import '../../../core/models/export.dart';

import '../../../core/services/network_services/export.dart';
import '../../export.dart';

class UserManagementUseCase {
  UserManagementRepo userManagementRepo;

  UserManagementUseCase(this.userManagementRepo);

  bool getUserLoggedInStatus() {
    return userManagementRepo.getUserLoggedInStatus();
  }

  int? getUserId() {
    return userManagementRepo.getUserId();
  }

  Future<int> getUserRoleId() {
    return userManagementRepo.getUserRoleId();
  }

  String getUserName() {
    return userManagementRepo.getUserName();
  }

  String getUserEmail() {
    return userManagementRepo.getUserEmail();
  }



  String getUserPic() {
    return userManagementRepo.getUserPic();
  }

  String getUserPassword() {
    return userManagementRepo.getUserPassword();
  }

  Future<Either<AppError, LoginModel>> login({
    required Map<String, dynamic> body,
  }) async {
    final response = await userManagementRepo.login(body: body);

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> signUp({
    required SignUpModel signUpModel,
  }) async {
    final response = await userManagementRepo.signUp(signUpModel: signUpModel);

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, DonorClaims>> getDonorClaims() async {
    final response = await userManagementRepo.getDonorClaims();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, dynamic>> getProfileCompletionCount() async {
    final response = await userManagementRepo.getProfileCompletionCount();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, dynamic>> deleteUserProfile() async {
    final response = await userManagementRepo.deleteUserProfile();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, dynamic>> deactivateUserProfile(  {required int userId,}) async {
    final response = await userManagementRepo.deactivateUserProfile(userId:userId);
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, CurrentUserProfile>> getCurrentUserProfile() async {
    final response = await userManagementRepo.getCurrentUserProfile();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  /// Get user profile by specific userId (for admin managing other users)
  Future<Either<AppError, CurrentUserProfile>> getUserProfileById({
    required int userId,
  }) async {
    final response = await userManagementRepo.getUserProfileById(userId: userId);
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> updateProfilePic({
    required String picData,
  }) async {
    final response =
    await userManagementRepo.updateProfilePic(picData: picData);

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  /// Update profile pic for a specific user (for admin managing other users)
  Future<Either<AppError, String>> updateUserProfilePic({
    required String picData,
    required int userId,
  }) async {
    final response = await userManagementRepo.updateUserProfilePic(
      picData: picData,
      userId: userId,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> updateProfileInfoPic({
    required String endPoint,
    required Map<String, dynamic> payload,
  }) async {
    final response = await userManagementRepo.updateProfileInfo(
      endPoint: endPoint,
      payload: payload,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, PartnerPreferenceData>> getPartnerPreference() async {
    final response = await userManagementRepo.getPartnerPreference();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  /// Get partner preference by specific userId (for admin managing other users)
  Future<Either<AppError, PartnerPreferenceData>> getPartnerPreferenceById({
    required int userId,
  }) async {
    final response = await userManagementRepo.getPartnerPreferenceById(userId: userId);
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> updatePartnerPreference({
    required Map<String, String> payload,
  }) async {
    final response = await userManagementRepo.updatePartnerPreference(
      payload: payload,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> updatePassword({
    required String password,
  }) async {
    final response = await userManagementRepo.updatePassword(
      password: password,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }
  Future<Either<AppError, String>> resetPassword({
    required String password,required String email,
  }) async {
    final response = await userManagementRepo.resetPassword(
      password: password,
      email: email,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, AllProfileList>> getAllProfiles({
    required int pageNo,
    required String pageLimit,
  }) async {
    final response = await userManagementRepo.getAllProfiles(
      pageNo: pageNo,
      pageLimit: pageLimit,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, AllProfileList>> getAllFeaturedProfiles({
    required int pageNo,
    required String pageLimit,
  }) async {
    final response = await userManagementRepo.getAllFeaturedProfiles(
      pageNo: pageNo,
      pageLimit: pageLimit,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, AllProfileList>> getAllProfilesByFilter({
    required ProfileFilter profileFilter,
  }) async {
    final response = await userManagementRepo.getAllProfilesByFilter(
      profileFilter: profileFilter,
    );
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, AllProfileList>> getAllProfilesByFilterForFeature({
    required ProfileFilter profileFilter,
  }) async {
    final response = await userManagementRepo.getAllProfilesByFilterForFeature(
      profileFilter: profileFilter,
    );
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, ProfileDetails>> getProfileDetails({
    required int uid,
  }) async {
    final response = await userManagementRepo.getProfilesDetails(uid: uid);

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, AllVendorsList>> getAllVendors({
    required int catId,
    required String pageNo,
    required int cityId,
  }) async {
    final response = await userManagementRepo.getAllVendors(
      catId: catId,
      pageNo: pageNo,
      cityId: cityId,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, List<VendorServices>>> getVendorServices({
    required vendorId,
  }) async {
    final response = await userManagementRepo.getVendorServices(
      vendorId: vendorId,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, List<VendorQuestions>>> getVendorQuestions({
    required vendorId,
  }) async {
    final response = await userManagementRepo.getVendorQuestions(
      vendorId: vendorId,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, List<VendorAlbums>>> getVendorAlbums({
    required vendorId,
  }) async {
    final response = await userManagementRepo.getVendorAlbums(
      vendorId: vendorId,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, List<VendorVideos>>> getVendorVideo({
    required vendorId,
  }) async {
    final response = await userManagementRepo.getVendorVideo(
      vendorId: vendorId,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, List<VendorPackages>>> getVendorPackage({
    required vendorId,
  }) async {
    final response = await userManagementRepo.getVendorPackage(
      vendorId: vendorId,
    );

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> addToFavorites({
    required int favUid,
  }) async {
    final response = await userManagementRepo.addToFavorites(favUid: favUid);

    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, List<FavoritesProfiles>>> getAllFavorites() async {
    final response = await userManagementRepo.getAllFavorites();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, String>> updateBlurProfileImage(bool blur) async {
    final response = await userManagementRepo.updateBlurProfileImage(blur: blur);
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  Future<Either<AppError, AllProfileList>> getMatrimonialProfiles({
    required int adminId,
    // required int pageNo,
    // required int pageLimit,
  }) async {
    final response = await userManagementRepo.getMatrimonialProfiles(
      adminId: adminId,
      // pageNo: pageNo,
      // pageLimit: pageLimit,
    );
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  /// Delete user profile by userId (Admin functionality)
  Future<Either<AppError, dynamic>> deleteUserProfileById({
    required int userId,
  }) async {
    final response = await userManagementRepo.deleteUserProfileById(userId: userId);
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  /// Remove matrimonial user by userId (Admin functionality)
  Future<Either<AppError, dynamic>> removeMatrimonialUser({
    required int userId,
  }) async {
    final response = await userManagementRepo.removeMatrimonialUser(userId: userId);
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  /// Get Vendor Own Profile for Matrimonial users
  Future<Either<AppError, VendorOwnProfile>> getVendorOwnProfile() async {
    final response = await userManagementRepo.getVendorOwnProfile();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }

  /// Update Vendor Profile for Matrimonial users
  Future<Either<AppError, String>> updateVendorProfile({
    required Map<String, dynamic> payload,
  }) async {
    final response = await userManagementRepo.updateVendorProfile(payload: payload);
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        return Right(success);
      },
    );
  }
}