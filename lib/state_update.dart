import 'package:flutter/material.dart';
import 'global.dart';

class ChangeReservations with ChangeNotifier {
  final bool _date = true;

  bool get get => _date;

  void change() {
    notifyListeners();
  }
}

class ChangeBasket with ChangeNotifier {
  int _count = globalBasket.count();
  //String _price = globalBasket.stringPrice(globalProducts);

  int get getCount => _count;
  //String get getPrice => _price;

  void change() {
    _count = globalBasket.count();
    //_price = globalBasket.stringPrice(globalProducts);
    notifyListeners();
  }
}

class ChangeTheme with ChangeNotifier {
  String _theme = appSettings['theme']!;

  String get getTheme => _theme;

  void change(String theme) {
    _theme = theme;
    notifyListeners();
  }
}

class ChangeNavigation with ChangeNotifier {
  int _index = 0;

  int get getIndex => _index;

  void change(int index) {
    _index = index;
    notifyListeners();
  }
}
