import 'package:flutter/material.dart';

import '../../models/scene.dart';
import '../scenes/scene_type_presentation.dart';

String? badgeForHeat(int heat) {
  if (heat >= 5) return 'HOT';
  if (heat >= 3) return 'RISING';
  return null;
}

class TrendingSceneCard extends StatefulWidget {
  final int rank;
  final Scene scene;
  final VoidCallback? onTap;

  const TrendingSceneCard({
    super.key,
    required this.rank,
    required this.scene,
    this.onTap,
  });

  @override
  State<TrendingSceneCard> createState() => _TrendingSceneCardState();
}

class _TrendingSceneCardState extends State<TrendingSceneCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final badge = badgeForHeat(widget.scene.heat);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.identity()..translate(0.0, _hovering ? -2.0 : 0.0),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEAEAF0)),
                boxShadow: [
                  BoxShadow(
                    color: _hovering
                        ? const Color(0x14000000)
                        : const Color(0x08000000),
                    blurRadius: _hovering ? 16 : 10,
                    offset: Offset(0, _hovering ? 8 : 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '#${widget.rank}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              sceneTypeIcon(widget.scene.type),
                              size: 18,
                              color: sceneTypeColor(widget.scene.type),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              sceneTypeLabel(widget.scene.type),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: sceneTypeColor(widget.scene.type),
                              ),
                            ),
                            const Spacer(),
                            if (badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: badge == 'HOT'
                                      ? const Color(0xFFFDE2E2)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  badge,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.scene.caption,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Heat Score: ${widget.scene.heat}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

