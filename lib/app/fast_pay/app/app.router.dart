// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

import 'package:assaan_rishta/app/fast_pay/views/amount_view.dart' as _i2;
import 'package:assaan_rishta/app/fast_pay/views/webview_screen.dart' as _i3;
import 'package:assaan_rishta/app/views/splash/splash_view.dart' as _i6;
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i4;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i5;

class Routes {
  static const splashView = '/';
  static const amountView = '/amount_view';
  static const webViewScreen = '/web-view-screen';

  static const all = <String>{
    splashView,
    amountView,
    webViewScreen,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(Routes.splashView, page: _i6.SplashView),
    _i1.RouteDef(
      Routes.amountView,
      page: _i2.AmountView,
    ),
    _i1.RouteDef(
      Routes.webViewScreen,
      page: _i3.WebViewScreen,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i6.SplashView: (data) {
      return _i4.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.SplashView(),
        settings: data,
      );
    },
    _i2.AmountView: (data) {
      final args = data.getArgs<AccountScreenArguments>(nullOk: false);
      return _i4.MaterialPageRoute<dynamic>(
        builder: (context) => _i2.AmountView(
          key: args.key,
          amount: args.amount,
          packageId: args.packageId,
        ),
        settings: data,
      );
    },
    _i3.WebViewScreen: (data) {
      final args = data.getArgs<WebViewScreenArguments>(nullOk: false);
      return _i4.MaterialPageRoute<dynamic>(
        builder: (context) => _i3.WebViewScreen(
          key: args.key,
          token: args.token,
          basketId: args.basketId,
          amount: args.amount,
          merchant: args.merchant,
          packageId: args.packageId,
          userId: args.userId,
          email: args.email,
          phoneNumber: args.phoneNumber,
        ),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class WebViewScreenArguments {
  const WebViewScreenArguments({
    this.key,
    required this.token,
    required this.basketId,
    required this.amount,
    required this.merchant,
    required this.packageId,
    required this.userId,
    required this.email,
    required this.phoneNumber,
  });

  final _i4.Key? key;

  final String token;

  final String basketId;

  final double amount;

  final String merchant;

  final String packageId;

  final int userId;

  final String email;

  final String phoneNumber;

  @override
  String toString() {
    return '{"key": "$key", '
        '"token": "$token", '
        '"basketId": "$basketId",'
        ' "amount": "$amount",'
        ' "merchant": "$merchant",'
        ' "packageId": "$packageId",'
        ' "userId": "$userId"'
        ' "email": "$email"'
        ' "phoneNumber": "$phoneNumber"'
        '}';
  }

  @override
  bool operator ==(covariant WebViewScreenArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.token == token &&
        other.basketId == basketId &&
        other.amount == amount &&
        other.packageId == packageId &&
        other.userId == userId &&
        other.merchant == merchant;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        token.hashCode ^
        basketId.hashCode ^
        amount.hashCode ^
        packageId.hashCode ^
        userId.hashCode ^
        merchant.hashCode;
  }
}

class AccountScreenArguments {
  const AccountScreenArguments({
    this.key,
    required this.amount,
    required this.packageId,
  });

  final _i4.Key? key;

  final String amount;

  final String packageId;

  @override
  String toString() {
    return '{"key": "$key", "packageId": "$packageId", "amount": "$amount"}';
  }

  @override
  bool operator ==(covariant AccountScreenArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.packageId == packageId &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return key.hashCode ^ amount.hashCode ^ packageId.hashCode;
  }
}

extension NavigatorStateExtension on _i5.NavigationService {
  Future<dynamic> navigateToSplashView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(
      Routes.splashView,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToAmountView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.amountView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToWebViewScreen({
    _i4.Key? key,
    required String token,
    required String basketId,
    required double amount,
    required String merchant,
    required String packageId,
    required String email,
    required String phoneNumber,
    required int userId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.webViewScreen,
        arguments: WebViewScreenArguments(
          key: key,
          token: token,
          basketId: basketId,
          amount: amount,
          merchant: merchant,
          packageId: packageId,
          userId: userId,
          email: email,
          phoneNumber: phoneNumber,
        ),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAmountView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.amountView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

}
