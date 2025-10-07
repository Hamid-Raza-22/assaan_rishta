// 1. Updated app_routes.dart - Add helper method for dynamic routes
abstract class AppRoutes {
  static const String ACCOUNT_TYPE = '/account-type';
  static const String SIGNUP = '/signup';
  static const String BASIC_INFO = '/basic-info';
  static const String OTHER_INFO = '/other-info';
  static const String LOGIN = '/login';
  static const String SPLASH = '/splash';
  static const String HOME = '/home';
  static const String BOTTOM_NAV = '/bottom-nav';
  static const String BOTTOM_NAV2 = '/bottom-nav';
  static const String FORGOT_PASSWORD_VIEW = '/forgot-password-view';
  static const String ENTER_PASSWORD_VIEW = '/enter-password-view';

  static const String PROFILE = '/profile';
  static const String PROFILE_DETAIL_VIEW = '/profile-detail-view';
  static const String PROFILE_EDIT_VIEW = '/profile-edit-view';
  static const String PARTNER_PREFERENCE_VIEW = '/partner_preference-view';
  static const String FAVORITES_VIEW = '/favorites_view';
  // static const String USER_DETAILS_VIEW = '/rishta';
  static const String USER_DETAILS_VIEW = '/rishta';

  static const String CHATTING_VIEW = '/chatting-view';
  static const String FILTETR_VIEW = '/filter-view';
  static const String VENDER_VIEW = '/vendor-view';
  static const String VENDER_LISTING_VIEW = '/vendor-listing-view';
  static const String VENDER_DETAILS_VIEW = '/vendors';//vendor-details-view
  static const String BUY_CONNECTS_VIEW = '/buy-connects-view';
  static const String TRANSACTION_HISTORY_VIEW = '/transaction-history-view';
  static const String CHANGE_PASSWORD_VIEW = '/change_password-view';
  static const String CONTACT_US_VIEW = '/contact-us-view';
  static const String ABOUT_US_VIEW = '/about-us-view';
  static const String USER_GUIDE_VIEW = '/user-guide-view';
  static const String IN_APP_WEB_VIEW_SITE = '/in_app_web_view_site';
  static const String IN_APP_WEB_VIEW_SITE_TERMS_AND_CONDITIONS = '/in_app_web_view_site_terms_and_conditions';

  // Helper method for dynamic chat route with user ID
  static String chattingViewWithUser(String userId) => '/chatting_view/$userId';
}