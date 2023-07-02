import 'package:dima_app/widgets/container_shadow.dart';
import 'package:dima_app/widgets/delay_widget.dart';
import 'package:dima_app/widgets/empty_list.dart';
import 'package:dima_app/widgets/horizontal_scroller.dart';
import 'package:dima_app/widgets/loading_logo.dart';
import 'package:dima_app/widgets/loading_overlay.dart';
import 'package:dima_app/widgets/logo.dart';
import 'package:dima_app/widgets/map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('widgets folder test', () {
    testWidgets('ContainerShadow has a text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: ContainerShadow(
                child: Text("Hello", textDirection: TextDirection.ltr),
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                width: 200,
                color: Colors.orange,
              ),
            ),
          ),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('DelayWidget has a text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: DelayWidget(
                child: Text("Hello"),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('EmptyList has a title and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: EmptyList(
                emptyMsg: "Hello",
                title: "This is a title",
                button: Text("This is another text",
                    textDirection: TextDirection.ltr),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('This is a title'), findsOneWidget);
      expect(find.text('This is another text'), findsOneWidget);
    });

    testWidgets('HorizontalScroller has 10 containers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: HorizontalScroller(
                children: [
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                  Container(height: 50, width: 50, color: Colors.orange),
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
          find.byWidgetPredicate(
              (widget) => widget is Container && widget.color == Colors.orange),
          findsNWidgets(10));
    });

    testWidgets('LoadingLogo has the logo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: LoadingLogo(),
            ),
          ),
        ),
      );
      expect(find.byWidgetPredicate((widget) => widget is EventyLogo),
          findsOneWidget);
    });

    testWidgets('LoadingOverlay shows loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Builder(builder: (context) {
                return Column(
                  children: [
                    ElevatedButton(
                      key: Key("test button1"),
                      child: Text("Show loading and hide"),
                      onPressed: () async {
                        LoadingOverlay.show(context);
                        await Future.delayed(Duration(seconds: 3));
                        LoadingOverlay.hide(context);
                      },
                    ),
                    ElevatedButton(
                      key: Key("test button2"),
                      child: Text("Show loading and not hide"),
                      onPressed: () {
                        LoadingOverlay.show(context);
                      },
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("test button1")));
      await tester.pump(Duration(seconds: 1));
      expect(
        find.byWidgetPredicate((widget) => widget is EventyLogo),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate((widget) => widget is EventyLogo),
        findsNothing,
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key("test button2")));
      await tester.pumpAndSettle(Duration(seconds: 5));
      expect(
        find.text("AN ERROR HAS OCCURRED"),
        findsOneWidget,
      );
    });

    testWidgets('Logo works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: EventyLogo(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byWidgetPredicate((widget) => widget is EventyLogo),
          findsOneWidget);
    });

    testWidgets('MapFromCoor has a marker', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: MapFromCoor(
                lat: 20,
                lon: 30,
                address: "address",
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
          find.byWidgetPredicate((widget) => widget is Marker), findsOneWidget);
      var mapFinder = find.byWidgetPredicate((widget) => widget is MapFromCoor);
      const offset = Offset(0, -550);
      await tester.fling(
        mapFinder,
        offset,
        1000,
        warnIfMissed: false,
      );
      expect(
          find.byWidgetPredicate((widget) => widget is Marker), findsNothing);
    });

    testWidgets('EmptyList has a title and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: EmptyList(
                emptyMsg: "Hello",
                title: "This is a title",
                button: Text("This is another text",
                    textDirection: TextDirection.ltr),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('This is a title'), findsOneWidget);
      expect(find.text('This is another text'), findsOneWidget);
    });
  });
}
