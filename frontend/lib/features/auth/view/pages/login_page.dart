import 'package:flutter/material.dart';
import 'package:keydui/core/theme/app_palette.dart';
import 'package:keydui/features/auth/view/widgets/auth_field.dart';
import 'package:keydui/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:keydui/features/home/view/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  final AuthViewModel authViewModel;

  const LoginPage({
    super.key,
    required this.authViewModel,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) return;

    final success = await widget.authViewModel.login(password);
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(
            authViewModel: widget.authViewModel,
          ),
        ),
      );
    }
  }

  void _handleBypassForDemo() async {
    await widget.authViewModel.login('demo_preview');
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(
            authViewModel: widget.authViewModel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Palette.cardColor,
              borderRadius: BorderRadius.circular(Palette.radiusXLarge),
              border: Border.all(color: Palette.borderColor, width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _BrandHeader(),
                const SizedBox(height: 32),
                _UserIdentityCard(username: widget.authViewModel.username),
                const SizedBox(height: 28),
                const Text(
                  'Enter Laptop Password',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Palette.textPrimary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 10),
                AuthField(
                  controller: _passwordController,
                  hintText: 'sudo password',
                  isPassword: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  onSubmitted: (_) => _handleLogin(),
                ),
                ListenableBuilder(
                  listenable: widget.authViewModel,
                  builder: (context, _) {
                    final errorMessage = widget.authViewModel.errorMessage;
                    if (errorMessage == null) return const SizedBox.shrink();
                    return _ErrorMessageBanner(message: errorMessage);
                  },
                ),
                const SizedBox(height: 28),
                ListenableBuilder(
                  listenable: widget.authViewModel,
                  builder: (context, _) {
                    return _AuthorizeButton(
                      isLoading: widget.authViewModel.isLoading,
                      onPressed: _handleLogin,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _handleBypassForDemo,
                    child: const Text(
                      'Preview UI in Read-Only Mode',
                      style: TextStyle(
                        color: Palette.textSecondary,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Palette.accentPrimary.withValues(alpha: 0.25),
                Palette.accentCyan.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(Palette.radiusMedium),
            border: Border.all(
              color: Palette.accentPrimary.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.keyboard_alt_rounded,
            color: Palette.accentBright,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'keydUI',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: Palette.textPrimary,
                height: 1.2,
              ),
            ),
            Text(
              'LINUX KEYBOARD REMAPPER',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: Palette.accentBright.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UserIdentityCard extends StatelessWidget {
  final String username;

  const _UserIdentityCard({required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Palette.surfaceColor,
        borderRadius: BorderRadius.circular(Palette.radiusMedium),
        border: Border.all(color: Palette.borderColor, width: 1.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Palette.surfaceContainerHigh,
            child: const Icon(
              Icons.person_rounded,
              color: Palette.textPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    color: Palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Root privilege required for /etc/keyd',
                  style: TextStyle(
                    color: Palette.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Palette.accentPrimary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(Palette.radiusSmall),
              border: Border.all(
                color: Palette.accentBright.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: const Text(
              'SUDO',
              style: TextStyle(
                color: Palette.accentBright,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessageBanner extends StatelessWidget {
  final String message;

  const _ErrorMessageBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Palette.accentRose.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Palette.radiusSmall),
          border: Border.all(
            color: Palette.accentRose.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Palette.accentRose,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Palette.accentRose,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorizeButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _AuthorizeButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_open_rounded, size: 20),
                SizedBox(width: 10),
                Text('AUTHORIZE & ACCESS'),
              ],
            ),
    );
  }
}
