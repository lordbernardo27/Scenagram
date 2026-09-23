bool shouldFlagSceneForModeration(String text) {
  final t = text.toLowerCase().trim();

  if (t.isEmpty) return false;

  final riskyWords = [
    'spam',
    'scam',
    'kill',
    'threat',
    'attack',
    'idiot',
    'stupid',
    'shut up',
  ];

  final hasRiskyWord =
      riskyWords.any((w) => t.contains(w));

  final hasManyLinks =
      RegExp(r'https?://').allMatches(t).length >= 2;

  final isAllCapsLong =
      text.length > 30 &&
      text == text.toUpperCase();

  return hasRiskyWord ||
         hasManyLinks ||
         isAllCapsLong;
}

String sceneModerationReason(String text) {
  final t = text.toLowerCase().trim();

  if (RegExp(r'https?://').allMatches(t).length >= 2) {
    return 'Possible spam links';
  }

  if (text.length > 30 &&
      text == text.toUpperCase()) {
    return 'Possible shouting or aggressive formatting';
  }

  if (t.contains('spam') || t.contains('scam')) {
    return 'Possible spam content';
  }

  if (t.contains('idiot') ||
      t.contains('stupid') ||
      t.contains('shut up')) {
    return 'Possible abusive language';
  }

  if (t.contains('kill') ||
      t.contains('threat') ||
      t.contains('attack')) {
    return 'Possible threatening language';
  }

  return 'Needs moderation review';
}

bool shouldFlagPerspectiveForModeration(String text) {
  final t = text.toLowerCase().trim();

  if (t.isEmpty) return false;

  final riskyWords = [
    'spam',
    'scam',
    'idiot',
    'stupid',
    'shut up',
    'kill',
    'threat',
  ];

  final hasRiskyWord = riskyWords.any((w) => t.contains(w));
  final hasManyLinks = RegExp(r'https?://').allMatches(t).length >= 2;
  final isAllCapsLong = text.length > 20 && text == text.toUpperCase();

  return hasRiskyWord || hasManyLinks || isAllCapsLong;
}


String perspectiveModerationReason(String text) {
  final t = text.toLowerCase().trim();

  if (RegExp(r'https?://').allMatches(t).length >= 2) {
    return 'Possible spam links';
  }

  if (text.length > 20 && text == text.toUpperCase()) {
    return 'Possible shouting or aggressive formatting';
  }

  if (t.contains('scam') || t.contains('spam')) {
    return 'Possible spam or scam language';
  }

  if (t.contains('idiot') || t.contains('stupid') || t.contains('shut up')) {
    return 'Possible abusive language';
  }

  if (t.contains('kill') || t.contains('threat')) {
    return 'Possible threatening language';
  }

  return 'Needs review';
}
