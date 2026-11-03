import 'package:flutter/material.dart';
import 'package:keydui/core/theme/app_palette.dart';
import 'package:keydui/features/auth/view/pages/login_page.dart';
import 'package:keydui/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:keydui/features/home/viewmodel/home_viewmodel.dart';

class WootingTopBar extends StatelessWidget {
  final HomeViewModel homeViewModel;
  final AuthViewModel authViewModel;

  const WootingTopBar({
    super.key,
    required this.homeViewModel,
    required this.authViewModel,
  });

  void _showAddLayerDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Palette.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Palette.radiusMedium),
            side: const BorderSide(color: Palette.borderColor, width: 1.0),
          ),
          title: const Row(
            children: [
              Icon(Icons.layers_rounded, color: Palette.accentBright, size: 22),
              SizedBox(width: 10),
              Text(
                'Add New Layer',
                style: TextStyle(
                  color: Palette.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter layer identifier (e.g. nav, symbols, gaming):',
                style: TextStyle(color: Palette.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(
                  color: Palette.textPrimary,
                  fontSize: 15,
                  fontFamily: 'monospace',
                ),
                decoration: const InputDecoration(
                  hintText: 'layer_name',
                ),
                onSubmitted: (name) {
                  final trimmed = name.trim();
                  if (trimmed.isNotEmpty) {
                    homeViewModel.addLayer(trimmed);
                  }
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  homeViewModel.addLayer(name);
                }
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Create Layer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Palette.cardColor,
        border: Border(
          bottom: BorderSide(color: Palette.borderColor, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Modern App Brand Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Palette.accentPrimary.withValues(alpha: 0.18),
                  Palette.accentCyan.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(Palette.radiusMedium),
              border: Border.all(
                color: Palette.accentPrimary.withValues(alpha: 0.4),
                width: 1.0,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.keyboard_alt_rounded, color: Palette.accentBright, size: 20),
                SizedBox(width: 10),
                Text(
                  'keydUI',
                  style: TextStyle(
                    color: Palette.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Layer Switcher Tabs
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ListenableBuilder(
                listenable: homeViewModel,
                builder: (context, _) {
                  final layers = homeViewModel.layers;
                  final activeLayer = homeViewModel.activeLayer;

                  return Row(
                    children: [
                      const Text(
                        'LAYERS:',
                        style: TextStyle(
                          color: Palette.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ...layers.map((layer) {
                        final isSelected = layer == activeLayer;
                        return _LayerTab(
                          layerName: layer,
                          isSelected: isSelected,
                          canDelete: layer != 'main' && isSelected,
                          onTap: () => homeViewModel.selectLayer(layer),
                          onDelete: () => homeViewModel.deleteLayer(layer),
                        );
                      }),
                      // Add Layer Button
                      IconButton(
                        onPressed: () => _showAddLayerDialog(context),
                        tooltip: 'Add new layer',
                        constraints: const BoxConstraints(
                          minWidth: Palette.minTouchTarget,
                          minHeight: Palette.minTouchTarget,
                        ),
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: Palette.textSecondary,
                          size: 22,
                        ),
                      ),
                      // Refresh ground truth from disk
                      IconButton(
                        onPressed: () async {
                          await homeViewModel.refreshProfile();
                          if (context.mounted && homeViewModel.statusMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(homeViewModel.statusMessage!),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        tooltip: 'Sync ground-truth from /etc/keyd/default.conf',
                        constraints: const BoxConstraints(
                          minWidth: Palette.minTouchTarget,
                          minHeight: Palette.minTouchTarget,
                        ),
                        icon: const Icon(
                          Icons.sync_rounded,
                          color: Palette.textSecondary,
                          size: 21,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Action buttons: Discard & Save
          ListenableBuilder(
            listenable: homeViewModel,
            builder: (context, _) {
              final hasChanges = homeViewModel.hasUnsavedChanges;
              final isSaving = homeViewModel.isSaving;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasChanges) ...[
                    TextButton.icon(
                      onPressed: homeViewModel.discardChanges,
                      icon: const Icon(Icons.undo_rounded, size: 18),
                      label: const Text('Discard'),
                    ),
                    const SizedBox(width: 10),
                  ],
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final password = authViewModel.session?.sudoPassword ?? '';
                            final ok = await homeViewModel.saveAndReload(password);
                            if (context.mounted && homeViewModel.statusMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: ok
                                      ? const Color(0xFF10281E)
                                      : const Color(0xFF38121C),
                                  content: Row(
                                    children: [
                                      Icon(
                                        ok ? Icons.check_circle_rounded : Icons.error_rounded,
                                        color: ok ? Palette.accentEmerald : Palette.accentRose,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          homeViewModel.statusMessage!,
                                          style: const TextStyle(
                                            color: Palette.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasChanges ? Icons.save_rounded : Icons.check_circle_outline_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(hasChanges ? 'SAVE & RELOAD' : 'KEYD SYNCED'),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),

          // User Profile / Lock Screen Button
          IconButton(
            onPressed: () {
              authViewModel.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginPage(authViewModel: authViewModel),
                ),
              );
            },
            tooltip: 'Lock session',
            constraints: const BoxConstraints(
              minWidth: Palette.minTouchTarget,
              minHeight: Palette.minTouchTarget,
            ),
            icon: const Icon(
              Icons.lock_outline_rounded,
              color: Palette.textSecondary,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerTab extends StatelessWidget {
  final String layerName;
  final bool isSelected;
  final bool canDelete;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _LayerTab({
    required this.layerName,
    required this.isSelected,
    required this.canDelete,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Palette.radiusMedium),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? Palette.accentPrimary.withValues(alpha: 0.2)
                  : Palette.surfaceColor,
              borderRadius: BorderRadius.circular(Palette.radiusMedium),
              border: Border.all(
                color: isSelected ? Palette.accentBright : Palette.borderColor,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Palette.accentBright,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  layerName.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Palette.accentBright : Palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    letterSpacing: 0.6,
                  ),
                ),
                if (canDelete) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Palette.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
