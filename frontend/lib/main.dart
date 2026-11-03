import 'package:flutter/material.dart';
import 'package:keydui/core/theme/theme.dart';
import 'package:keydui/features/auth/view/pages/login_page.dart';
import 'package:keydui/features/auth/viewmodel/auth_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final authViewModel = AuthViewModel();

  runApp(KeydApp(authViewModel: authViewModel));
}

class KeydApp extends StatelessWidget {
  final AuthViewModel authViewModel;

  const KeydApp({
    super.key,
    required this.authViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'keydUI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkThemeMode,
      home: LoginPage(authViewModel: authViewModel),
    );
  }
}
