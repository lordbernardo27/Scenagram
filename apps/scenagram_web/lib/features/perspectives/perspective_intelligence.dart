const List<String> kUniversalLanes = [
  'Comedy',
  'Analysis',
  'Debate',
  'Reaction',
  'Advice',
];

class PerspectiveLanePrediction {
  final String lane;
  final double confidence;

  const PerspectiveLanePrediction({
    required this.lane,
    required this.confidence,
  });
}

PerspectiveLanePrediction detectPerspectiveLaneWithConfidence(
  String text,
) {
  final lane = detectPerspectiveLane(text);

  double confidence = 0.60;

  final t = text.toLowerCase();

  if (lane == 'Advice' &&
      (t.contains('should') ||
       t.contains('recommend') ||
       t.contains('advice'))) {
    confidence = 0.90;
  }

  if (lane == 'Debate' &&
      (t.contains('agree') ||
       t.contains('disagree') ||
       t.contains('wrong'))) {
    confidence = 0.88;
  }

  if (lane == 'Analysis' &&
      (t.contains('because') ||
       t.contains('evidence') ||
       t.contains('reason'))) {
    confidence = 0.87;
  }

  if (lane == 'Comedy' &&
      (t.contains('lol') ||
       t.contains('haha'))) {
    confidence = 0.92;
  }

  if (lane == 'Reaction') {
    confidence = 0.75;
  }

  return PerspectiveLanePrediction(
    lane: lane,
    confidence: confidence,
  );
}

String detectPerspectiveLane(String text) {
  final t = text.toLowerCase().trim();

  if (t.isEmpty) return 'Reaction';

  final comedyWords = ['lol', 'haha', 'funny', 'joke', '??', '??', 'lmao'];
  final adviceWords = ['should', 'try', 'recommend', 'advice', 'suggest', 'you can', 'you should'];
  final debateWords = ['disagree', 'wrong', 'but', 'however', 'not true', 'i oppose'];
  final analysisWords = ['because', 'reason', 'evidence', 'data', 'study', 'means', 'therefore'];
  final reactionWords = ['wow', 'crazy', 'shocking', 'unbelievable', 'insane', 'wild'];

  bool hasAny(List<String> words) => words.any((w) => t.contains(w));

  if (hasAny(comedyWords)) return 'Comedy';
  if (hasAny(adviceWords)) return 'Advice';
  if (hasAny(debateWords)) return 'Debate';
  if (hasAny(analysisWords)) return 'Analysis';
  if (hasAny(reactionWords)) return 'Reaction';

  return 'Reaction';
}

bool isPerspectiveLaneMismatch({
  required String selectedLane,
  required String text,
}) {
  final suggested = detectPerspectiveLane(text);
  return suggested != selectedLane;
}

const bool kPerspectiveAutoRoutingEnabled = false;

class PerspectiveRoutingDecision {
  final String originalLane;
  final String suggestedLane;
  final double confidence;
  final bool autoRouteEligible;

  const PerspectiveRoutingDecision({
    required this.originalLane,
    required this.suggestedLane,
    required this.confidence,
    required this.autoRouteEligible,
  });
}

PerspectiveRoutingDecision buildPerspectiveRoutingDecision({
  required String selectedLane,
  required String text,
}) {
  final prediction =
      detectPerspectiveLaneWithConfidence(text);

  return PerspectiveRoutingDecision(
    originalLane: selectedLane,
    suggestedLane: prediction.lane,
    confidence: prediction.confidence,
    autoRouteEligible:
        prediction.confidence >= 0.90 &&
        prediction.lane != selectedLane,
  );
}
