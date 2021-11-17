import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static navigateTo(Widget routeName) {
    return navigatorKey.currentState!
        .push(MaterialPageRoute(builder: (_) => routeName));
  }

  static replaceTo(Widget routeName) {
    return navigatorKey.currentState!
        .pushReplacement(MaterialPageRoute(builder: (_) => routeName));
  }
}
