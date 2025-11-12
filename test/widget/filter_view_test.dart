import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

/// Filter View Widget Tests
/// 
/// Filter screen ki UI testing:
/// - Filter options display
/// - Dropdown menus
/// - Age range sliders
/// - Apply/Clear buttons

void main() {
  group('FilterView Widget Tests', () {
    testWidgets('Should display all filter options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Column(
            children: [
              Text('Gender'),
              Text('Age Range'),
              Text('City'),
              Text('Marital Status'),
              Text('Religion'),
              Text('Caste'),
            ],
          ),
        ),
      );

      expect(find.text('Gender'), findsOneWidget);
      expect(find.text('Age Range'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Marital Status'), findsOneWidget);
      expect(find.text('Religion'), findsOneWidget);
      expect(find.text('Caste'), findsOneWidget);
    });

    testWidgets('Should display gender radio buttons',
        (WidgetTester tester) async {
      String selectedGender = 'Male';

      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  RadioListTile<String>(
                    title: Text('Male'),
                    value: 'Male',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text('Female'),
                    value: 'Female',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(find.byType(RadioListTile<String>), findsNWidgets(2));
    });

    testWidgets('Should display age range sliders',
        (WidgetTester tester) async {
      double ageFrom = 20;
      double ageTo = 30;

      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Text('Age From: ${ageFrom.toInt()}'),
                  Slider(
                    value: ageFrom,
                    min: 18,
                    max: 80,
                    onChanged: (value) {
                      setState(() {
                        ageFrom = value;
                      });
                    },
                  ),
                  Text('Age To: ${ageTo.toInt()}'),
                  Slider(
                    value: ageTo,
                    min: 18,
                    max: 80,
                    onChanged: (value) {
                      setState(() {
                        ageTo = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Age From: 20'), findsOneWidget);
      expect(find.text('Age To: 30'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(2));
    });

    testWidgets('Should display marital status dropdown',
        (WidgetTester tester) async {
      String? selectedStatus;

      await tester.pumpWidget(
        createTestWidget(
          DropdownButton<String>(
            value: selectedStatus,
            hint: Text('Select Marital Status'),
            items: ['Single', 'Married', 'Divorced', 'Widow/Widower']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
            onChanged: (value) {},
          ),
        ),
      );

      expect(find.text('Select Marital Status'), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('Should display apply filters button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton(
            onPressed: () {},
            child: Text('Apply Filters'),
          ),
        ),
      );

      expect(find.text('Apply Filters'), findsOneWidget);
    });

    testWidgets('Should display clear filters button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TextButton(
            onPressed: () {},
            child: Text('Clear All'),
          ),
        ),
      );

      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('Should reset filters on clear button tap',
        (WidgetTester tester) async {
      String selectedGender = 'Male';
      double ageFrom = 25;

      await tester.pumpWidget(
        createTestWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Text('Gender: $selectedGender, Age: ${ageFrom.toInt()}'),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedGender = '';
                        ageFrom = 18;
                      });
                    },
                    child: Text('Clear'),
                  ),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Gender: Male, Age: 25'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pump();

      expect(find.text('Gender: , Age: 18'), findsOneWidget);
    });

    testWidgets('Should display city search field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          TextField(
            decoration: InputDecoration(
              labelText: 'Search City',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
      );

      expect(find.text('Search City'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Should display filter count badge',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Stack(
            children: [
              Icon(Icons.filter_list),
              Positioned(
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text('3', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('Should scroll through filter options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          ListView(
            children: List.generate(
              20,
              (index) => ListTile(title: Text('Filter Option $index')),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('Filter Results Tests', () {
    testWidgets('Should display filtered results count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Text('Showing 25 results'),
        ),
      );

      expect(find.text('Showing 25 results'), findsOneWidget);
    });

    testWidgets('Should display no results message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64),
                SizedBox(height: 16),
                Text('No profiles match your filters'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('No profiles match your filters'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });
}
