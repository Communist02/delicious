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

  void change() {
    _theme = appSettings['theme']!;
    notifyListeners();
  }
}

class ChangeNavigation with ChangeNotifier {
  int _index = 0;
  bool _switch = false;

  bool get getSwitch => _switch;

  int get getIndex {
    _switch = false;
    return _index;
  }

  void change(int index) {
    _index = index;
    _switch = true;
    notifyListeners();
  }
}
