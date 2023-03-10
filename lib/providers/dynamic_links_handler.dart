import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

class DynamicLinksHandler extends ChangeNotifier {
  PendingDynamicLinkData? _dynamicLink;
  bool pushed = true;

  // getter
  PendingDynamicLinkData? get dynamicLink => _dynamicLink;

  void setLink(PendingDynamicLinkData? newLink) {
    _dynamicLink = newLink;
    pushed = false;
    notifyListeners();
  }
}
