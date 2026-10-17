import 'package:flutter/material.dart';

Color perspectiveLaneColor(String lane) {
  switch (lane) {
    case 'Comedy':
      return const Color(0xFFDC2626);
    case 'Analysis':
      return const Color(0xFF059669);
    case 'Debate':
      return const Color(0xFF2563EB);
    case 'Reaction':
      return const Color(0xFF7C3AED);
    case 'Advice':
      return const Color(0xFFD97706);
    default:
      return const Color(0xFF6B7280);
  }
}

IconData perspectiveLaneIcon(String lane) {
  switch (lane) {
    case 'Comedy':
      return Icons.sentiment_very_satisfied_rounded;
    case 'Analysis':
      return Icons.analytics_rounded;
    case 'Debate':
      return Icons.forum_rounded;
    case 'Reaction':
      return Icons.bolt_rounded;
    case 'Advice':
      return Icons.lightbulb_rounded;
    default:
      return Icons.chat_bubble_outline_rounded;
  }
}
