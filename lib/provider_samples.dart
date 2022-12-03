import 'package:flutter/material.dart';

class Something extends StatelessWidget {
  final String stringa = "ciaoodsadsao";
  const Something({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MockAPI {
  final String city = "Portland";

  Future<String> get fetchAddress {
    final address = Future.delayed(const Duration(seconds: 2), () {
      return '1234 North Commercial Ave.';
    });

    return address;
  }
}

class SecondClass {
  final String value;
  SecondClass({required this.value});
}

class CounterProviderSample extends ChangeNotifier {
  int _counter = 0;

  // getter
  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }
}
