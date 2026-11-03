class KeyDefinition {
  final String id;
  final String label;
  final String? shiftLabel;
  final double flex;
  final bool isModifier;

  const KeyDefinition({
    required this.id,
    required this.label,
    this.shiftLabel,
    this.flex = 1.0,
    this.isModifier = false,
  });
}

