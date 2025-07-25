abstract class AppRoutes {
  static const String ACCOUNT_TYPE = '/account-type';
  static const String SIGNUP = '/signup';
  static const String BASIC_INFO = '/basic-info';
  static const String OTHER_INFO = '/other-info';
  static const String LOGIN = '/login';
  static const String HOME = '/home';
  static const String BOTTOM_NAV = '/bottom-nav';

  static const String PROFILE = '/profile';
  static const String PROFILE_DETAIL_VIEW = '/profile-detail-view';
  static const String USER_DETAILS_VIEW = '/user-details-view';
  static const String CHATTING_VIEW = '/chatting-view';
  // Add dynamic route with user ID
  static String chattingViewWithUser(String userId) => '/chatting_view/$userId';
  static const String PROFILE_EDIT = '/profile-edit';
  static const String PROFILE_EDIT_BASIC = '/profile-edit-basic';
  static const String PROFILE_EDIT_OTHER = '/profile-edit-other';

}
