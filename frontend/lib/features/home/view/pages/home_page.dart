import 'package:flutter/material.dart';
import 'package:keydui/core/theme/app_palette.dart';
import 'package:keydui/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:keydui/features/home/view/widgets/keyboard_canvas.dart';
import 'package:keydui/features/home/view/widgets/remapping_drawer.dart';
import 'package:keydui/features/home/view/widgets/wooting_top_bar.dart';
import 'package:keydui/features/home/viewmodel/home_viewmodel.dart';

class HomePage extends StatefulWidget {
  final AuthViewModel authViewModel;

  const HomePage({
    super.key,
    required this.authViewModel,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();
    _homeViewModel = HomeViewModel();
    _homeViewModel.init();
  }

  @override
  void dispose() {
    _homeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.backgroundColor,
      body: ListenableBuilder(
        listenable: _homeViewModel,
        builder: (context, _) {
          if (_homeViewModel.isLoading) {
            return const _HomeLoadingView();
          }

          return Column(
            children: [
              // Wooting Header Bar with Layer Tabs, Sync, and Apply Action
              WootingTopBar(
                homeViewModel: _homeViewModel,
                authViewModel: widget.authViewModel,
              ),

              // Visual Keyboard Canvas Area
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: KeyboardCanvas(viewModel: _homeViewModel),
                    ),
                  ),
                ),
              ),

              // Bottom Remapping Configurator Drawer
              RemappingDrawer(viewModel: _homeViewModel),
            ],
          );
        },
      ),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation(Palette.accentPrimary),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Loading keyd configuration...',
            style: TextStyle(
              color: Palette.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
