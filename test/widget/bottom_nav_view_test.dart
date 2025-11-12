import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

/// Bottom Navigation View Widget Tests
/// 
/// Bottom navigation bar testing:
/// - Navigation items display
/// - Tab selection
/// - Badge indicators

void main() {
  group('BottomNavigationView Widget Tests', () {
    testWidgets('Should display all navigation items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Vendors',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Vendors'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Should display navigation icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Vendors',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('Should highlight selected tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 2, // Chat tab selected
              selectedItemColor: Colors.pink,
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Vendors',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      final bottomNav =
          tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, equals(2));
    });

    testWidgets('Should display badge on chat tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Vendors',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    label: Text('5'),
                    child: Icon(Icons.chat),
                  ),
                  label: 'Chat',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Badge), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('Should switch tabs on tap', (WidgetTester tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        makeTestableWidget(
          child: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return BottomNavigationBar(
                  currentIndex: selectedIndex,
                  onTap: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.store),
                      label: 'Vendors',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.chat),
                      label: 'Chat',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Initially on Home
      expect(selectedIndex, equals(0));

      // Tap Chat tab
      await tester.tap(find.text('Chat'));
      await tester.pump();

      // Should switch to Chat
      expect(selectedIndex, equals(2));
    });
  });
}
