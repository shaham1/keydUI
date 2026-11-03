import 'package:flutter/material.dart';
import 'package:keydui/core/theme/app_palette.dart';
import 'package:keydui/features/home/model/key_definition.dart';

class KeycapWidget extends StatefulWidget {
  final KeyDefinition keyDef;
  final String? remappedAction;
  final bool isSelected;
  final VoidCallback onTap;

  const KeycapWidget({
    super.key,
    required this.keyDef,
    required this.remappedAction,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<KeycapWidget> createState() => _KeycapWidgetState();
}

class _KeycapWidgetState extends State<KeycapWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isRemapped = widget.remappedAction != null && widget.remappedAction!.isNotEmpty;
    final bool isSelected = widget.isSelected;

    Color backgroundColor = Palette.keycapColor;
    if (isSelected) {
      backgroundColor = Palette.keycapSelectedColor;
    } else if (_isHovered) {
      backgroundColor = Palette.keycapHoverColor;
    }

    Color borderColor = Palette.borderColor;
    if (isSelected) {
      borderColor = Palette.accentBright;
    } else if (isRemapped) {
      borderColor = Palette.accentPrimary.withValues(alpha: 0.75);
    } else if (_isHovered) {
      borderColor = Palette.textSecondary;
    }

    final double labelSize = widget.keyDef.label.length > 3 ? 12.0 : 14.5;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(Palette.radiusSmall),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : (isRemapped ? 1.5 : 1.0),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Palette.accentPrimary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 1.5,
                    ),
                  ]
                : (isRemapped
                    ? [
                        BoxShadow(
                          color: Palette.accentPrimary.withValues(alpha: 0.18),
                          blurRadius: 6,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: Key labels (primary and shift)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.keyDef.label,
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Palette.accentBright
                          : (isRemapped ? Palette.textPrimary : Palette.textSecondary),
                    ),
                  ),
                  if (widget.keyDef.shiftLabel != null)
                    Text(
                      widget.keyDef.shiftLabel!,
                      style: const TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: Palette.textMuted,
                      ),
                    ),
                ],
              ),

              // Bottom row: Remapped target tag if remapped (with overflow protection)
              if (isRemapped)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Palette.keycapRemappedBadge,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Palette.accentPrimary.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      widget.remappedAction!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Palette.keycapRemappedText,
                        fontFamily: 'monospace',
                        height: 1.15,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
