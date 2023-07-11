import 'dart:io';
import 'package:dima_app/screens/edit_profile/components/change_image.dart';
import 'package:dima_app/screens/edit_profile/edit_profile.dart';
import 'package:dima_app/services/firebase_notification.dart';
import 'package:dima_app/services/firebase_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../mocks/mock_firebase_notification.dart';
import '../../mocks/mock_firebase_user.dart';

class CustomBindings extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get overrideHttpClient => false;
}

void main() async {
  CustomBindings();

  group('Edit profile screen test', () {
    testWidgets('ChangeImage component renders correctly (camera)',
        (tester) async {
      bool _initialRemoved = false;
      File? _photo;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
                create: (context) => MockFirebaseUser()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: ChangeImage(
                  photo: _photo,
                  changeInitialRemoved: (bool value) {
                    _initialRemoved = value;
                  },
                  changePhoto: (File? newPhoto) {
                    _photo = newPhoto;
                  },
                  initialRemoved: _initialRemoved,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is CircleAvatar),
        findsOneWidget,
      );
      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.photo_camera));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Camera"));
      await tester.pumpAndSettle();
    });

    testWidgets('ChangeImage component renders correctly (gallery)',
        (tester) async {
      bool _initialRemoved = false;
      File? _photo;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
                create: (context) => MockFirebaseUser()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SafeArea(
                child: ChangeImage(
                  photo: _photo,
                  changeInitialRemoved: (bool value) {
                    _initialRemoved = value;
                  },
                  changePhoto: (File? newPhoto) {
                    _photo = newPhoto;
                  },
                  initialRemoved: _initialRemoved,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is CircleAvatar),
        findsOneWidget,
      );
      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.photo_camera));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Gallery"));
      await tester.pumpAndSettle();
    });

    testWidgets('EditProfileScreen renders correctly', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FirebaseUser>(
                create: (context) => MockFirebaseUser()),
            ChangeNotifierProvider<CupertinoTabController>(
              create: (context) => CupertinoTabController(),
            ),
            ChangeNotifierProvider<FirebaseNotification>(
              create: (context) => MockFirebaseNotification(),
            ),
          ],
          child: MaterialApp(
            home: EditProfileScreen(
              userData: MockFirebaseUser.testUserModel,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is ChangeImage),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate((widget) => widget is TextFormField),
        findsNWidgets(3),
      );
    });
  });
}
