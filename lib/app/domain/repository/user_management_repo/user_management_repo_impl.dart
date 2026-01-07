import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/export.dart';
import '../../../core/services/network_services/export.dart';
import '../../../core/services/storage_services/export.dart';
import 'export.dart';

class UserManagementRepoImpl implements UserManagementRepo {
  final StorageRepo _storageRepo;
  final NetworkHelper _networkHelper;
  final EndPoints _endPoints;
  final SharedPreferences sharedPreferences;

  UserManagementRepoImpl(
      this._storageRepo,
      this._networkHelper,
      this._endPoints,
      this.sharedPreferences,
      );

  @override
  bool getUserLoggedInStatus() {
    return _storageRepo.getBool(StorageKeys.isUserLoggedIn) ?? false;
  }

  @override
  int? getUserId() {
    return _storageRepo.getInt(StorageKeys.userId);
  }

  @override
  Future<int> getUserRoleId() async {
    return _storageRepo.getInt(StorageKeys.userRoleId) ?? 0;
  }

  @override
  String getUserName() {
    return '${_storageRepo.getString(StorageKeys.userName)}';
  }

  @override
  String getUserEmail() {
    return '${_storageRepo.getString(StorageKeys.userEmail)}';
  }

  @override
  String getUserPic() {
    return '${_storageRepo.getString(StorageKeys.userPic)}';
  }

  @override
  String getUserPassword() {
    return '${_storageRepo.getString(StorageKeys.userPassword)}';
  }

  @override
  Future<Either<AppError, LoginModel>> login(
      {required Map<String, dynamic> body}) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.loginUrl(),
        body: body,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        isEncode: false,
      );
      LoginModel model = LoginModel();
      LoginError errorModel = LoginError();
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        model = LoginModel.fromJson(jsonDecode(response.body));
        _storageRepo.setString(StorageKeys.token, model.accessToken!);
        _storageRepo.setBool(StorageKeys.isUserLoggedIn, true);
        return Right(model);
      }
      errorModel = LoginError.fromJson(jsonDecode(response.body));
      return Left(
        AppError(
          title: response.statusCode.toString(),
          description: errorModel.error.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> signUp({
    required SignUpModel signUpModel,
  }) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.signUpUrl(),
        isEncode: true,
        body: signUpModel.toJson(),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        // Parse the response body to check for specific messages
        final responseBody = response.body.toString();

        // Check if the response indicates a duplicate user
        if (responseBody.toLowerCase().contains("exists") ||
            responseBody.toLowerCase().contains("duplicate")) {
          return Left(
            AppError(
              title: "User Already Exists",
              description: "An account with this email or phone number already exists",
            ),
          );
        }

        return Right(responseBody);
      }

      // Handle 409 Conflict (commonly used for duplicates)
      if (response.statusCode == 409) {
        return Left(
          AppError(
            title: "Duplicate Account",
            description: "This email or phone number is already registered",
          ),
        );
      }

      return Left(
        AppError(
          title: "Error ${response.statusCode}",
          description: "Registration failed",
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: "Network Error",
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, DonorClaims>> getDonorClaims() async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getDonorClaimsUrl(),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer ${sharedPreferences.get(StorageKeys.token)}",
        },
      );
      DonorClaims model = DonorClaims();
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        model = DonorClaims.fromJson(jsonDecode(response.body));
        _storageRepo.setInt(StorageKeys.userId, model.userId!);
        _storageRepo.setString(
            StorageKeys.userName, '${model.firstName} ${model.lastName}');
        _storageRepo.setString(StorageKeys.userEmail, '${model.email}');
        _storageRepo.setString(StorageKeys.userPic, '${model.userImage}');
        // Save user role ID for admin dashboard
        if (model.roleId != null) {
          _storageRepo.setInt(StorageKeys.userRoleId, model.roleId!);
        }
        return Right(model);
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, dynamic>> getProfileCompletionCount() async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getProfileCompletionCountUrl(
          uid: _storageRepo.getInt(StorageKeys.userId),
        ),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body);
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, dynamic>> deleteUserProfile() async {
    try {
      final response = await _networkHelper.get(
        _endPoints.deleteUserProfile(
          uid: _storageRepo.getInt(StorageKeys.userId),
        ),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body);
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, dynamic>> deactivateUserProfile({ required int userId,}) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.deactivateUserProfile(
          uid: userId,
          // uid: _storageRepo.getInt(StorageKeys.userId),
          byWho: 'by user',
        ),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body);
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, CurrentUserProfile>> getCurrentUserProfile() async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getCurrentUserProfileUrl(
            uid: _storageRepo.getInt(StorageKeys.userId)),
      );
      CurrentUserProfile model = CurrentUserProfile();
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final jsonData = jsonDecode(response.body);
        debugPrint('📋 getCurrentUserProfile API response - is_blur: ${jsonData['is_blur']}');
        model = CurrentUserProfile.fromJson(jsonData);
        return Right(model);
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, CurrentUserProfile>> getUserProfileById({
    required int userId,
  }) async {
    try {
      debugPrint('📋 getUserProfileById - Fetching profile for userId: $userId');
      final response = await _networkHelper.get(
        _endPoints.getCurrentUserProfileUrl(uid: userId),
      );
      CurrentUserProfile model = CurrentUserProfile();
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final jsonData = jsonDecode(response.body);
        debugPrint('📋 getUserProfileById API response received for userId: $userId');
        model = CurrentUserProfile.fromJson(jsonData);
        return Right(model);
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> updateProfilePic({
    required String picData,
  }) async {
    try {
      final response = await _networkHelper.postMultipartData(
        _endPoints.updateProfileUrl(),
        fields: {
          'picData': picData,
          'userId': _storageRepo.getInt(StorageKeys.userId).toString(),
          'role_id': '2',
        },
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> updateProfileInfo({
    required String endPoint,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.updateProfileInfoUrl(endPoint),
        isEncode: true,
        body: payload,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, PartnerPreferenceData>> getPartnerPreference() async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getGetPartnerPreferenceDataUrl(
          uid: _storageRepo.getInt(StorageKeys.userId),
        ),
      );
      PartnerPreferenceData model = PartnerPreferenceData();
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        model = PartnerPreferenceData.fromJson(jsonDecode(response.body));
        return Right(model);
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, PartnerPreferenceData>> getPartnerPreferenceById({
    required int userId,
  }) async {
    try {
      debugPrint('📋 getPartnerPreferenceById - Fetching for userId: $userId');
      final response = await _networkHelper.get(
        _endPoints.getGetPartnerPreferenceDataUrl(uid: userId),
      );
      PartnerPreferenceData model = PartnerPreferenceData();
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        model = PartnerPreferenceData.fromJson(jsonDecode(response.body));
        debugPrint('📋 getPartnerPreferenceById - Data received for userId: $userId');
        return Right(model);
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> updatePartnerPreference({
    required Map<String, String> payload,
  }) async {
    try {
      final response = await _networkHelper.postMultipartData(
        _endPoints.updatePartnerPreferenceUrl(),
        fields: payload,
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> updatePassword({
    required String password,
  }) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.updatePasswordUrl(),
        body: {
          "password": password,
          "user_id": _storageRepo.getInt(StorageKeys.userId),
          "user_type": "user",
        },
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }
  @override
  Future<Either<AppError, String>> resetPassword({
    required String password,required String email,
  }) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.resetPasswordUrl(),
        body: {
          "password": password,
          "email": email,
          "user_type": "user",
        },
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AllProfileList>> getAllProfiles({
    required int pageNo,
    required String pageLimit,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getAllProfilesUrl(
          uid: _storageRepo.getInt(StorageKeys.userId),
          pageNo: pageNo,
          pageLimit: pageLimit,
        ),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(AllProfileList.fromJson(jsonDecode(response.body)));
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AllProfileList>> getAllFeaturedProfiles({
    required int pageNo,
    required String pageLimit,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getAllFeaturedProfilesUrl(
          uid: _storageRepo.getInt(StorageKeys.userId),
          pageNo: pageNo,
          pageLimit: pageLimit,
        ),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(AllProfileList.fromJson(jsonDecode(response.body)));
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AllProfileList>> getAllProfilesByFilter({
    required ProfileFilter profileFilter,
  }) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.profilesByFilterUrl(),
        body: profileFilter.toJson(),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(AllProfileList.fromJson(jsonDecode(response.body)));
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AllProfileList>> getAllProfilesByFilterForFeature({
    required ProfileFilter profileFilter,
  }) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.profilesByFilterForFeatureUrl(),
        body: profileFilter.toJson(),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(AllProfileList.fromJson(jsonDecode(response.body)));
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, ProfileDetails>> getProfilesDetails(
      {required int uid}) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getProfilesDetailsUrl(uid: uid),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(ProfileDetails.fromJson(jsonDecode(response.body)));
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AllVendorsList>> getAllVendors({
    required int catId,
    required String pageNo,
    required int cityId,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getAllVendorsUrl(
          catId: catId,
          pageNo: pageNo,
          cityId: cityId,
        ),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(AllVendorsList.fromJson(jsonDecode(response.body)));
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<VendorServices>>> getVendorServices({
    required vendorId,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getVendorServicesUrl(vendorId: vendorId),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Right(VendorServices.fromJsonList(jsonResponse));
        }
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<VendorQuestions>>> getVendorQuestions({
    required vendorId,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getVendorQuestionsUrl(vendorId: vendorId),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Right(VendorQuestions.fromJsonList(jsonResponse));
        }
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<VendorAlbums>>> getVendorAlbums({
    required vendorId,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getVendorAlbumsUrl(vendorId: vendorId),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Right(VendorAlbums.fromJsonList(jsonResponse));
        }
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<VendorVideos>>> getVendorVideo({
    required vendorId,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getVendorVideoUrl(vendorId: vendorId),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Right(VendorVideos.fromJsonList(jsonResponse));
        }
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<VendorPackages>>> getVendorPackage({
    required vendorId,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getVendorPackageUrl(vendorId: vendorId),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Right(VendorPackages.fromJsonList(jsonResponse));
        }
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> addToFavorites({
    required int favUid,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.addToFavoritesUrl(
          uid: _storageRepo.getInt(StorageKeys.userId),
          favUid: favUid,
        ),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, List<FavoritesProfiles>>> getAllFavorites() async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getFavoritesUrl(
          uid: _storageRepo.getInt(StorageKeys.userId),
        ),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        List<dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          return Right(FavoritesProfiles.fromJsonList(jsonResponse));
        }
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> updateBlurProfileImage({required bool blur}) async {
    try {
      final response = await _networkHelper.post(
        _endPoints.updateBlurProfileImageUrl(),
        body: {
          'user_id': _storageRepo.getInt(StorageKeys.userId),  // int value
          'is_blur': blur,  // bool value (not string)
        },
        headers: {"Content-Type": "application/json"},
        isEncode: true,  // JSON encoding enabled
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        return Right(response.body.toString());
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
          description: response.body,
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          title: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, AllProfileList>> getMatrimonialProfiles({
    required int adminId,
    // required int pageNo,
    // required int pageLimit,
  }) async {
    try {
      final response = await _networkHelper.get(
        _endPoints.getMatrimonialProfilesUrl(
          adminId: adminId,
          // pageNo: pageNo,
          // pageLimit: pageLimit,
        ),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final decodedBody = jsonDecode(response.body);

        // Check if response is a list (direct array) or an object
        if (decodedBody is List) {
          // API returns direct list of profiles
          final profilesList = decodedBody.map((item) => ProfilesList.fromJson(item)).toList();
          return Right(AllProfileList(
            profilesList: profilesList,
            totalRecords: profilesList.length,
          ));
        } else {
          // API returns object with profilesList and totalRecords
          return Right(AllProfileList.fromJson(decodedBody));
        }
      }
      return Left(
        AppError(
          title: response.statusCode.toString(),
        ),
      );
    } catch (e) {
      return Left(
        AppError(
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, dynamic>> deleteUserProfileById({
    required int userId,
  }) async {
    try {
      debugPrint('🗑️ deleteUserProfileById - Deleting userId: $userId');
      final response = await _networkHelper.delete(
        _endPoints.deleteUserProfile(uid: userId),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        debugPrint('✅ deleteUserProfileById - Success');
        return Right(response.body);
      }
      return Left(
        AppError(
          title: "Delete Failed",
          description: "Failed to delete profile. Status: ${response.statusCode}",
        ),
      );
    } catch (e) {
      debugPrint('❌ deleteUserProfileById - Error: $e');
      return Left(
        AppError(
          title: "Error",
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, dynamic>> removeMatrimonialUser({
    required int userId,
  }) async {
    try {
      debugPrint('🗑️ removeMatrimonialUser - Removing userId: $userId');
      // Try GET method instead of DELETE (405 error suggests DELETE is not allowed)
      final response = await _networkHelper.get(
        _endPoints.removeMatrimonialUser(uid: userId),
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        debugPrint('✅ removeMatrimonialUser - Success');
        return Right(response.body);
      }
      return Left(
        AppError(
          title: "Remove Failed",
          description: "Failed to remove matrimonial user. Status: ${response.statusCode}",
        ),
      );
    } catch (e) {
      debugPrint('❌ removeMatrimonialUser - Error: $e');
      return Left(
        AppError(
          title: "Error",
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, VendorOwnProfile>> getVendorOwnProfile() async {
    try {
      final userId = getUserId();
      if (userId == null) {
        return Left(AppError(title: "Error", description: "User not logged in"));
      }
      
      debugPrint('📱 getVendorOwnProfile - Fetching vendor profile for userId: $userId');
      final response = await _networkHelper.get(
        _endPoints.getVendorOwnProfileUrl(userId: userId),
      );
      
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final data = jsonDecode(response.body);
        debugPrint('✅ getVendorOwnProfile - Success');
        return Right(VendorOwnProfile.fromJson(data));
      }
      
      return Left(
        AppError(
          title: "Error",
          description: "Failed to fetch vendor profile. Status: ${response.statusCode}",
        ),
      );
    } catch (e) {
      debugPrint('❌ getVendorOwnProfile - Error: $e');
      return Left(
        AppError(
          title: "Error",
          description: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<AppError, String>> updateVendorProfile({
    required Map<String, dynamic> payload,
  }) async {
    try {
      debugPrint('📝 updateVendorProfile - Updating vendor profile');
      final response = await _networkHelper.post(
        _endPoints.updateVendorProfileUrl(),
        body: payload,
      );
      
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        debugPrint('✅ updateVendorProfile - Success');
        return Right(response.body);
      }
      
      return Left(
        AppError(
          title: "Update Failed",
          description: "Failed to update vendor profile. Status: ${response.statusCode}",
        ),
      );
    } catch (e) {
      debugPrint('❌ updateVendorProfile - Error: $e');
      return Left(
        AppError(
          title: "Error",
          description: e.toString(),
        ),
      );
    }
  }
}