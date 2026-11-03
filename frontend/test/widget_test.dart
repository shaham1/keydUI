import 'package:flutter_test/flutter_test.dart';
import 'package:keydui/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:keydui/main.dart';

void main() {
  testWidgets('KeydApp renders login page with sudo authorization prompt',
      (WidgetTester tester) async {
    final authViewModel = AuthViewModel();
    await tester.pumpWidget(KeydApp(authViewModel: authViewModel));

    expect(find.text('keydUI'), findsOneWidget);
    expect(find.text('Enter Laptop Password'), findsOneWidget);
    expect(find.text('AUTHORIZE & ACCESS'), findsOneWidget);
  });
}
