import 'package:daumgrito_app/src/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders auth flow', (tester) async {
    await tester.pumpWidget(const DaumgritoApp());

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Cadastro'), findsOneWidget);
  });
}
