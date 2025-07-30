import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class CustomRoute {
  static RouteAndRemoveUntilTo(BuildContext context, Widget nextpage) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => nextpage),
      (route) => false,
    );
  }

  static RouteTo(BuildContext context, Widget nextpage) {
    Navigator.push(
      context,

      PageTransition(
        child: nextpage,
        type: PageTransitionType.fade,
        // fullscreenDialog: true,
      ),
    );
  }

  static RouteReplacementTo(BuildContext context, Widget nextpage) {
    Navigator.pushReplacement(
      context,
      PageTransition(child: nextpage, type: PageTransitionType.fade),
    );
  }

  static RoutePop(BuildContext context) {
    Navigator.pop(context);
  }
}
