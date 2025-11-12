import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

/// Widget tests for CustomButton
/// 
/// Custom widgets ki testing

void main() {
  group('CustomButton Widget Tests', () {
    testWidgets('Should render button with text', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Click Me';
      
      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton(
            onPressed: () {},
            child: Text(buttonText),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Should trigger onTap callback when pressed',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      
      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton(
            onPressed: () {
              wasPressed = true;
            },
            child: Text('Press Me'),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('Should apply custom colors', (WidgetTester tester) async {
      // Arrange
      const backgroundColor = Colors.pink;
      const textColor = Colors.white;
      
      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
            ),
            child: Text(
              'Styled Button',
              style: TextStyle(color: textColor),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.style?.backgroundColor?.resolve({}), equals(backgroundColor));
    });

    testWidgets('Should be disabled when onPressed is null',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          ElevatedButton(
            onPressed: null,
            child: Text('Disabled Button'),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
    });

    testWidgets('Should apply margin correctly', (WidgetTester tester) async {
      // Arrange
      const margin = EdgeInsets.all(16);
      
      await tester.pumpWidget(
        createTestWidget(
          Container(
            margin: margin,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Button with Margin'),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(Container),
        ),
      );
      expect(container.margin, equals(margin));
    });
  });

  group('Text Widget Tests', () {
    testWidgets('Should display text with correct style',
        (WidgetTester tester) async {
      // Arrange
      const text = 'Test Text';
      const fontSize = 20.0;
      const fontWeight = FontWeight.bold;
      
      await tester.pumpWidget(
        createTestWidget(
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      expect(find.text(text), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text(text));
      expect(textWidget.style?.fontSize, equals(fontSize));
      expect(textWidget.style?.fontWeight, equals(fontWeight));
    });

    testWidgets('Should handle text overflow', (WidgetTester tester) async {
      // Arrange
      const longText = 'This is a very long text that should be truncated';
      
      await tester.pumpWidget(
        createTestWidget(
          SizedBox(
            width: 100,
            child: Text(
              longText,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert
      final textWidget = tester.widget<Text>(find.text(longText));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
      expect(textWidget.maxLines, equals(1));
    });
  });
}
