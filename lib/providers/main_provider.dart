import 'package:flutter/material.dart';

class MainProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isPDFView = false;

  bool get isLoading => _isLoading;
  bool get isPDFView => _isPDFView;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set isPDFView(bool value) {
    _isPDFView = value;
    notifyListeners();
  }
}
