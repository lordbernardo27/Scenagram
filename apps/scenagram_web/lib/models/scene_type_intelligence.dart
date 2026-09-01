import 'package:flutter/material.dart';

import 'scene_type.dart';

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

class SceneTypePrediction {
  final SceneType type;
  final double confidence;

  const SceneTypePrediction({
    required this.type,
    required this.confidence,
  });
}

SceneTypePrediction detectSceneTypeWithConfidence(String text) {
  final type = detectSceneType(text);
  final t = text.toLowerCase();

  double confidence = 0.62;

  if (type == SceneType.confession &&
      (t.contains('confess') ||
       t.contains('secret') ||
       t.contains('ashamed'))) {
    confidence = 0.90;
  }

  if (type == SceneType.dilemma &&
      (t.contains('should i') ||
       t.contains('what should i do') ||
       t.contains('help me decide'))) {
    confidence = 0.91;
  }

  if (type == SceneType.drama &&
      (t.contains('fight') ||
       t.contains('argument') ||
       t.contains('betrayed') ||
       t.contains('cheated'))) {
    confidence = 0.88;
  }

  if (type == SceneType.celebration &&
      (t.contains('birthday') ||
       t.contains('graduated') ||
       t.contains('wedding') ||
       t.contains('won'))) {
    confidence = 0.89;
  }

  if (type == SceneType.hotTake &&
      (t.contains('hot take') ||
       t.contains('unpopular opinion') ||
       t.contains('controversial'))) {
    confidence = 0.90;
  }

  if (type == SceneType.event &&
      (t.contains('event') ||
       t.contains('concert') ||
       t.contains('festival') ||
       t.contains('match'))) {
    confidence = 0.87;
  }

  if (type == SceneType.media) {
    confidence = 0.72;
  }

  return SceneTypePrediction(
    type: type,
    confidence: confidence,
  );
}

SceneType detectSceneType(String text) {
  final t = text.toLowerCase().trim();

  if (t.isEmpty) return SceneType.media;

  bool hasAny(List<String> words) => words.any((w) => t.contains(w));

  if (hasAny([
    'confess',
    'secret',
    'i have never told',
    'i feel guilty',
    'ashamed',
  ])) {
    return SceneType.confession;
  }

  if (hasAny([
    'should i',
    'what should i do',
    'help me decide',
    'decision',
    'choice',
    'dilemma',
  ])) {
    return SceneType.dilemma;
  }

  if (hasAny([
    'fight',
    'argument',
    'betrayed',
    'cheated',
    'disrespect',
    'drama',
    'conflict',
  ])) {
    return SceneType.drama;
  }

  if (hasAny([
    'birthday',
    'graduated',
    'wedding',
    'promotion',
    'celebrate',
    'won',
    'achievement',
  ])) {
    return SceneType.celebration;
  }

  if (hasAny([
    'hot take',
    'unpopular opinion',
    'controversial',
    'everyone is wrong',
    'my opinion',
  ])) {
    return SceneType.hotTake;
  }

  if (hasAny([
    'event',
    'concert',
    'festival',
    'conference',
    'match',
    'tournament',
    'live at',
  ])) {
    return SceneType.event;
  }

  return SceneType.media;
}

bool isSceneTypeMismatch({
  required SceneType selectedType,
  required String text,
}) {
  return detectSceneType(text) != selectedType;
}

String sceneTypePurpose(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return 'Vulnerability, honesty, secrets, and emotional release.';
    case SceneType.dilemma:
      return 'Decision-making, moral conflict, and choice-based discussion.';
    case SceneType.drama:
      return 'Conflict, tension, chaos, controversy, and public reactions.';
    case SceneType.media:
      return 'Captured moments, visual witnessing, videos, clips, and images.';
    case SceneType.celebration:
      return 'Joy, milestones, achievements, wins, and positive moments.';
    case SceneType.hotTake:
      return 'Strong opinions, controversial claims, and bold viewpoints.';
    case SceneType.event:
      return 'Shared real-world experiences, gatherings, and live moments.';
  }
}

String sceneTypeUiStyle(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return 'Soft, intimate, emotionally safe UI.';
    case SceneType.dilemma:
      return 'Split-decision, interactive, judgment-oriented UI.';
    case SceneType.drama:
      return 'High-energy, intense, active UI.';
    case SceneType.media:
      return 'Immersive, visual-first, cinematic UI.';
    case SceneType.celebration:
      return 'Uplifting, vibrant, rewarding UI.';
    case SceneType.hotTake:
      return 'Bold, sharp, opinion-focused UI.';
    case SceneType.event:
      return 'Live, dynamic, community-driven UI.';
  }
}

List<String> sceneTypePriorityLanes(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return ['Advice', 'Reaction', 'Analysis', 'Comedy', 'Debate'];
    case SceneType.dilemma:
      return ['Debate', 'Advice', 'Analysis', 'Reaction', 'Comedy'];
    case SceneType.drama:
      return ['Reaction', 'Debate', 'Comedy', 'Analysis', 'Advice'];
    case SceneType.media:
      return ['Reaction', 'Analysis', 'Comedy', 'Debate', 'Advice'];
    case SceneType.celebration:
      return ['Reaction', 'Comedy', 'Advice', 'Analysis', 'Debate'];
    case SceneType.hotTake:
      return ['Debate', 'Reaction', 'Analysis', 'Comedy', 'Advice'];
    case SceneType.event:
      return ['Reaction', 'Analysis', 'Comedy', 'Debate', 'Advice'];
  }
}

List<String> lanesForType(SceneType t) {
  return sceneTypePriorityLanes(t);
}
