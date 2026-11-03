class AuthSession {
  final String username;
  final String sudoPassword;
  final DateTime authenticatedAt;

  const AuthSession({
    required this.username,
    required this.sudoPassword,
    required this.authenticatedAt,
  });

  bool get isAuthenticated => sudoPassword.isNotEmpty;
}

