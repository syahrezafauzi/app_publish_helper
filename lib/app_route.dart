import 'package:app_updater_flutter/home/home_binding.dart';
import 'package:app_updater_flutter/home/home_page.dart';
import 'package:get/get.dart';

class AppRoute {
  static var home = "/home";
  static var pages = <GetPage>[
    GetPage(
      name: home,
      page: ()=> HomePage(),
      binding: HomeBinding(),
    )
  ];
}
