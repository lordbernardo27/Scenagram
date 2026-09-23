import 'package:flutter/material.dart';

import '../../models/scene_type.dart';
import 'scene_type_intelligence.dart';

String sceneTypeLabel(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return 'Confess';
    case SceneType.dilemma:
      return 'Dilemma';
    case SceneType.drama:
      return 'Drama';
    case SceneType.media:
      return 'Media';
    case SceneType.celebration:
      return 'Celebration';
    case SceneType.hotTake:
      return 'Hot Take';
    case SceneType.event:
      return 'Event';
  }
}

IconData sceneTypeIcon(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return Icons.favorite_rounded;
    case SceneType.dilemma:
      return Icons.help_center_rounded;
    case SceneType.drama:
      return Icons.local_fire_department_rounded;
    case SceneType.media:
      return Icons.play_circle_fill_rounded;
    case SceneType.celebration:
      return Icons.celebration_rounded;
    case SceneType.hotTake:
      return Icons.bolt_rounded;
    case SceneType.event:
      return Icons.event_available_rounded;
  }
}

Color sceneTypeColor(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return const Color(0xFF8B5CF6); // Confess ? purple
    case SceneType.dilemma:
      return const Color(0xFFF59E0B); // Dilemma ? amber
    case SceneType.drama:
      return const Color(0xFFE11D48); // Drama ? red
    case SceneType.media:
      return const Color(0xFF2563EB); // Media ? blue
    case SceneType.celebration:
      return const Color(0xFF16A34A); // Celebration ? green
    case SceneType.hotTake:
      return const Color(0xFFEA580C); // Hot Take ? orange
    case SceneType.event:
      return const Color(0xFF0D9488); // Event ? teal
  }
}

class SceneTypeMeta {
  final String label;
  final IconData icon;
  final Color color;
  final String purpose;
  final String uiStyle;
  final List<String> priorityLanes;

  const SceneTypeMeta({
    required this.label,
    required this.icon,
    required this.color,
    required this.purpose,
    required this.uiStyle,
    required this.priorityLanes,
  });
}

SceneTypeMeta sceneTypeMeta(SceneType t) {
  return SceneTypeMeta(
    label: sceneTypeLabel(t),
    icon: sceneTypeIcon(t),
    color: sceneTypeColor(t),
    purpose: sceneTypePurpose(t),
    uiStyle: sceneTypeUiStyle(t),
    priorityLanes: sceneTypePriorityLanes(t),
  );
}
