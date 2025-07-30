import 'package:flutter/widgets.dart';

class HomePageDeliveryController with ChangeNotifier {
  int currentTab = 0;

  void setTab(int index) {
    currentTab = index;
    notifyListeners();
  }
}
