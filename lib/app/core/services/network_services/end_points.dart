import '../env_config_service.dart';

class EndPoints {
  static String get baseUrl => EnvConfig.baseUrl;
  static String get authBaseUrl => EnvConfig.authBaseUrl;

  String loginUrl() {
    return '${authBaseUrl}token';
  }

  String signUpUrl() {
    return '${baseUrl}Users/registerUser';
  }

  String getDonorClaimsUrl() {
    return '${baseUrl}GetDonorClaims';
  }

  String getProfileCompletionCountUrl({required uid}) {
    return '${baseUrl}User/GetUserProfileCount/$uid';
  }

  String deleteUserProfile({required uid}) {
    return '${baseUrl}Users/DeleteUser/$uid';
  }

  String removeMatrimonialUser({required uid}) {
    return '${baseUrl}vender/remove_mat_user/$uid';
  }

  String deactivateUserProfile({required uid, required String byWho}) {
    return '${baseUrl}Users/DeActivateUser/$uid/$byWho';
  }

  String getCurrentUserProfileUrl({required uid}) {
    return '${baseUrl}User/GetUserProfile/$uid';
  }

  String updateProfileUrl() {
    return '${baseUrl}Users/UserProfilePic';
  }

  String updateProfileInfoUrl(endPoint) {
    return '${baseUrl}user/$endPoint';
  }

  String getGetPartnerPreferenceDataUrl({required uid}) {
    return '${baseUrl}user/GetPartnerPreferenceData/$uid';
  }

  String updatePartnerPreferenceUrl() {
    return '${baseUrl}user/updatepartner_prefrence';
  }

  String updatePasswordUrl() {
    return '${baseUrl}user/update_pasword';
  }

  String resetPasswordUrl() {
    return '${baseUrl}user/reset_password';
  }

  String getAllCastsUrl() {
    return '${baseUrl}Users/getcast';
  }

  String getAllOccupationsUrl() {
    return '${baseUrl}Users/getoccupations';
  }

  String getAllDegreesUrl() {
    return '${baseUrl}Users/getDegrees';
  }

  String getAllCountriesUrl() {
    return '${baseUrl}Users/GetAllCountries';
  }

  String getStatesByCountryIdUrl({countryId}) {
    return '${baseUrl}Users/GetAllStatesByCountry/$countryId';
  }

  String getCityByStateIdUrl({stateId}) {
    return '${baseUrl}Users/GetAllCitiesByStateId/$stateId';
  }

  getAllProfilesUrl({pageNo, pageLimit, uid}) {
    // Use user ID when logged in, 0 when guest mode
    final userId = (uid != null && uid != 0) ? uid : 0;
    return '${baseUrl}Users/GetAllProfiles/$pageNo/$pageLimit/$userId';
  }

  getAllFeaturedProfilesUrl({pageNo, pageLimit, uid}) {
    // Use user ID when logged in, 0 when guest mode (not null)
    final userId = (uid != null && uid != 0) ? uid : 0;
    return '${baseUrl}Users/GetAllFeaturedProfiles/$pageNo/$pageLimit/$userId';
  }

  getProfilesDetailsUrl({uid}) {
    return '${baseUrl}User/GetConectionDetail/$uid';
    return '${baseUrl}User/GetConectionDetail/$uid';
  }

  getAllVendorsUrl({catId, pageNo, cityId}) {
    return '${baseUrl}vender/getallvendors/$catId/$pageNo/100/$cityId';
  }

  getVendorServicesUrl({required vendorId}) {
    return '${baseUrl}vender/getservice/$vendorId';
  }

  getVendorQuestionsUrl({required vendorId}) {
    return '${baseUrl}vender/getquestions/$vendorId';
  }

  getVendorAlbumsUrl({required vendorId}) {
    return '${baseUrl}vender/getimage/$vendorId';
  }

  getVendorVideoUrl({required vendorId}) {
    return '${baseUrl}vender/getVideo/$vendorId';
  }

  getVendorPackageUrl({required vendorId}) {
    return '${baseUrl}vender/getPackage/$vendorId';
  }

  addToFavoritesUrl({required uid, required favUid}) {
    return '${baseUrl}Users/add_to_fav/$uid/$favUid';
  }

  getFavoritesUrl({required uid}) {
    return '${baseUrl}Users/getfavrot/$uid/1/100';
  }

  getConnectsUrl({uid}) {
    return '${baseUrl}User/getConnectionCount/$uid';
  }

  buyConnectsUrl() {
    return '${baseUrl}User/updateConnects';
  }

  deductConnectsUrl({uid, userForId}) {
    return '${baseUrl}user/deductConnects/$uid/$userForId';
  }

  createTransactionUrl() {
    return '${baseUrl}Users/createtransaction';
  }

  createGoogleTransactionUrl() {
    // api/transaction/PostTransaction
    return '${baseUrl}transaction/PostTransaction';
  }

  transactionHistoryUrl(uid) {
    return '${baseUrl}transaction/GetTransactionsByUserId/$uid';
  }

  connectsHistoryUrl(uid) {
    return '${baseUrl}User/getConnectionHistory/$uid';
  }

  profilesByFilterUrl() {
    return '${baseUrl}Users/GetAllProfilesByFilter';
  }

  profilesByFilterForFeatureUrl() {
    return '${baseUrl}Users/GetAllProfilesByFilterForFeature';
  }

  contactUsUrl() {
    return '${baseUrl}user/contactus';
  }

  getUserNumberUrl({required String email}) {
    return '${baseUrl}User/getUserNumber/%7Bemail%7D?email=$email';
  }
  // https://thsolutionz.com/api/User/getUserNumber/%7Bemail%7D?email=$email
  ///pay fast
  getPaymentTokenUrl({basketId, amount}) {
    return '${baseUrl}PayFastController/GetToken/$basketId/$amount/PKR';
  }

  String updateBlurProfileImageUrl() {
    return '${baseUrl}Users/update_blur_profile_image';
  }

  String getMatrimonialProfilesUrl(
      {
        required int adminId,
        // required int pageNo,
        // required int pageLimit
      }) {
    return '${baseUrl}Users/GetAll_mat_Profiles/$adminId';
    // return '${baseUrl}Users/GetAll_mat_Profiles/$adminId/$pageNo/$pageLimit';
  }

  /// Get Vendor Own Profile for Matrimonial users
  String getVendorOwnProfileUrl({required int userId}) {
    return '${baseUrl}Users/GetVendorOwnProfile/$userId';
  }

  /// Update Vendor Profile for Matrimonial users
  String updateVendorProfileUrl() {
    return '${baseUrl}Users/UpdateVendorProfile';
  }
}