import 'package:flutter/material.dart';
import 'package:keydui/core/theme/app_palette.dart';
import 'package:keydui/features/home/model/keyboard_layout.dart';
import 'package:keydui/features/home/view/widgets/keycap_widget.dart';
import 'package:keydui/features/home/viewmodel/home_viewmodel.dart';

class KeyboardCanvas extends StatelessWidget {
  final HomeViewModel viewModel;

  const KeyboardCanvas({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Palette.surfaceDim,
          borderRadius: BorderRadius.circular(Palette.radiusXLarge),
          border: Border.all(color: Palette.borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: KeyboardLayout.standardAnsi.map((row) {
            return SizedBox(
              height: 68.0,
              child: Row(
                children: row.map((keyDef) {
                  final remapped = viewModel.config?.getMapping(
                    viewModel.activeLayer,
                    keyDef.id,
                  );
                  final isSelected = viewModel.selectedKeyId == keyDef.id;

                  return Expanded(
                    flex: (keyDef.flex * 100).toInt(),
                    child: KeycapWidget(
                      keyDef: keyDef,
                      remappedAction: remapped,
                      isSelected: isSelected,
                      onTap: () {
                        if (isSelected) {
                          viewModel.selectKey(null);
                        } else {
                          viewModel.selectKey(keyDef.id);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
