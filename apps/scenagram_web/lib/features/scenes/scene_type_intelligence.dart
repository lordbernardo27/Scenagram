import '../../models/scene_type.dart';

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
