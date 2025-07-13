import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/core/routes/app_pages.dart';
import 'app/core/routes/app_routes.dart';
import 'app/core/services/dependency_injection.dart';


void main() {
  DependencyInjection.init();
  runApp(const AsanRishtaApp());
}

class AsanRishtaApp extends StatelessWidget {
  const AsanRishtaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Asan Rishta',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.ACCOUNT_TYPE,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
