import 'package:flutter/material.dart';

import '../../models/scene_type.dart';
import 'scene_type_presentation.dart';

class SceneTypeStrip extends StatelessWidget {
  final SceneType? selected;
  final ValueChanged<SceneType?>? onSelect;

  const SceneTypeStrip({
    super.key,
    this.selected,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: SceneType.values.map((type) {
            return _SceneTypeTab(
              type: type,
              selected: selected == type,
              onTap: () => onSelect?.call(type),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SceneTypeTab extends StatefulWidget {
  final SceneType type;
  final bool selected;
  final VoidCallback onTap;

  const _SceneTypeTab({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SceneTypeTab> createState() => _SceneTypeTabState();
}

class _SceneTypeTabState extends State<_SceneTypeTab> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = sceneTypeColor(widget.type);
    final selected = widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected
                ? color.withOpacity(0.08)
                : (_hovering
                    ? const Color(0xFFF8F8FB)
                    : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? color.withOpacity(0.22)
                  : const Color(0xFFE8E9F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                sceneTypeIcon(widget.type),
                size: 16,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                sceneTypeLabel(widget.type),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
