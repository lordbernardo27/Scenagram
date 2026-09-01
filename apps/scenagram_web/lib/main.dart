import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'core/theme/app_theme.dart';
import 'models/scene_type.dart';
import 'models/scene_type_intelligence.dart';
import 'models/scene.dart';
import 'controllers/feed_controller.dart';
import 'features/perspectives/perspective_item.dart';

void main() => runApp(const ScenagramApp());

class ScenagramApp extends StatelessWidget {
  const ScenagramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenagram',
      debugShowCheckedModeBanner: false,
      theme: SGTheme.light(),
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/trending': (context) => const TrendingPage(),
        '/create': (context) => const CreateScenePage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

/* ---------------------------
   HELPERS
---------------------------- */
String? badgeForHeat(int heat) {
  if (heat >= 5) return 'HOT';
  if (heat >= 3) return 'RISING';
  return null;
}

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

String sceneTypeFeedRoute(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return '/feed/confess';
    case SceneType.dilemma:
      return '/feed/dilemma';
    case SceneType.drama:
      return '/feed/drama';
    case SceneType.media:
      return '/feed/media';
    case SceneType.celebration:
      return '/feed/celebration';
    case SceneType.hotTake:
      return '/feed/hot-take';
    case SceneType.event:
      return '/feed/event';
  }
}

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

/* ---------------------------
   CORE MATRIX V1
---------------------------- */
const List<String> kUniversalLanes = [
  'Comedy',
  'Analysis',
  'Debate',
  'Reaction',
  'Advice',
];

/* ---------------------------
   SCENE MODEL
---------------------------- */
/* ---------------------------
   FEED CONTROLLER FOUNDATION
   Phase 2.1.1
---------------------------- */
/* ---------------------------
   LOCAL DATA
---------------------------- */
final List<Scene> homeScenes = [
  Scene(
    type: SceneType.media,
    caption:
        'A short educational clip explains why some traditional habits still work better than modern shortcuts.',
    heat: 3,
  ),
  Scene(
    type: SceneType.drama,
    caption:
        'Just now: A heated argument broke out at a public event after a well-known influencer allegedly disrespected a small business owner on stage. The crowd quickly took sides. Watch and share your thoughts.',
    heat: 4,
  ),
  Scene(
    type: SceneType.event,
    caption:
        'A rescue team helped trapped passengers after a highway crash caused a major traffic standstill.',
    heat: 2,
  ),
];

int totalPerspectivesPosted = 0;

/* ---------------------------
   APP FRAME
---------------------------- */
class ScenagramFrame extends StatefulWidget {
  final String currentRoute;
  final Widget centerContent;
  final Widget? rightSidebar;
  final SceneType? selectedSceneType;
  final ValueChanged<SceneType?>? onSelectSceneType;

  const ScenagramFrame({
    super.key,
    required this.currentRoute,
    required this.centerContent,
    this.rightSidebar,
    this.selectedSceneType,
    this.onSelectSceneType,
  });

  @override
  State<ScenagramFrame> createState() => _ScenagramFrameState();
}

class _ScenagramFrameState extends State<ScenagramFrame> {
  bool _leftHidden = false;
  bool _rightHidden = false;

  bool get _showSceneTabs => widget.currentRoute == '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFE),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE7E8EE)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                children: [
                  _TopBar(currentRoute: widget.currentRoute),
                  if (_showSceneTabs)
                    _SceneTypeStrip(
                      selected: widget.selectedSceneType,
                      onSelect: widget.onSelectSceneType,
                    ),
                  Expanded(
                    child: Row(
                      children: [
                        if (!_leftHidden)
                          SizedBox(
                            width: 250,
                            child: _LeftSidebar(
                              currentRoute: widget.currentRoute,
                              onHide: () {
                                setState(() {
                                  _leftHidden = true;
                                });
                              },
                            ),
                          ),
                        if (!_leftHidden)
                          Container(
                            width: 1,
                            color: const Color(0xFFEAEAF0),
                          ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  color: const Color(0xFFFDFDFE),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 840,
                                      ),
                                      child: widget.centerContent,
                                    ),
                                  ),
                                ),
                              ),
                              if (_leftHidden)
                                _SidebarRestoreButton(
                                  side: 'left',
                                  onTap: () {
                                    setState(() {
                                      _leftHidden = false;
                                    });
                                  },
                                ),
                              if (!_rightHidden)
                                Container(
                                  width: 1,
                                  color: const Color(0xFFEAEAF0),
                                ),
                              if (!_rightHidden)
                                SizedBox(
                                  width: 310,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Container(
                                          color: const Color(0xFFFDFDFE),
                                          child: widget.rightSidebar ??
                                              const SizedBox.shrink(),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 10,
                                        child: _SidebarHideButton(
                                          onTap: () {
                                            setState(() {
                                              _rightHidden = true;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (_rightHidden)
                                _SidebarRestoreButton(
                                  side: 'right',
                                  onTap: () {
                                    setState(() {
                                      _rightHidden = false;
                                    });
                                  },
                                ),
                            ],
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

class _TopBar extends StatelessWidget {
  final String currentRoute;

  const _TopBar({required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEEF3)),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFB83CFF),
                      Color(0xFFFF4F8B),
                      Color(0xFFFFA21A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Scenagram',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          const SizedBox(width: 72),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Container(
                  height: 43,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8FC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE7E8EF),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Color(0xFF5F6675),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search Scenagram web',
                          style: TextStyle(
                            color: Color(0xFF73798A),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),

          const _TopBadgeIcon(
            icon: Icons.favorite_border_rounded,
            count: '',
          ),
          const SizedBox(width: 24),

          const _TopBadgeIcon(
            icon: Icons.chat_bubble_outline_rounded,
            count: '3',
          ),
          const SizedBox(width: 24),

          const _TopBadgeIcon(
            icon: Icons.notifications_none_rounded,
            count: '6',
          ),
          const SizedBox(width: 26),

          InkWell(
            onTap: () {
              if (currentRoute != '/create') {
                Navigator.pushReplacementNamed(context, '/create');
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFB923E7),
                    Color(0xFFFF2D8A),
                    Color(0xFFFFA31A),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Post a Scene',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 22),

          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 21,
            color: Color(0xFF343A46),
          ),
        ],
      ),
    );
  }
}

class _WindowDot extends StatelessWidget {
  final Color color;
  const _WindowDot(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  const _TopIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: 24, color: const Color(0xFF111827));
  }
}

class _TopBadgeIcon extends StatelessWidget {
  final IconData icon;
  final String count;

  const _TopBadgeIcon({
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          icon,
          size: 25,
          color: const Color(0xFF272D3A),
        ),
        if (count.isNotEmpty)
          Positioned(
            top: -7,
            right: -8,
            child: Container(
              constraints: const BoxConstraints(minWidth: 18),
              height: 18,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFF1F79),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LeftSidebar extends StatelessWidget {
  final String currentRoute;
  final VoidCallback onHide;

  const _LeftSidebar({
    required this.currentRoute,
    required this.onHide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE7E8ED),
                    ),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 23,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
                        ),
                      ),

                      const SizedBox(width: 11),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nadia K.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF171C27),
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              '@nadiak',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF777D8A),
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: onHide,
                        splashRadius: 18,
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          size: 19,
                          color: Color(0xFF555C69),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const _SideLabel('ACCOUNT'),
                const SizedBox(height: 10),

                _SidebarNavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  selected: currentRoute == '/profile',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/profile',
                  ),
                ),

                const _SidebarNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  selected: false,
                ),

                const _SidebarNavItem(
                  icon: Icons.badge_outlined,
                  label: 'Account Details',
                  selected: false,
                ),

                const _SidebarNavItem(
                  icon: Icons.shield_outlined,
                  label: 'Privacy & Security',
                  selected: false,
                ),

                const SizedBox(height: 24),

                const _SideLabel('SCENAGRAM'),
                const SizedBox(height: 10),

                _SidebarNavItem(
                  icon: Icons.home_outlined,
                  label: 'Home Feed',
                  selected: currentRoute == '/',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/',
                  ),
                ),

                _SidebarNavItem(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Trending',
                  selected: currentRoute == '/trending',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/trending',
                  ),
                ),

                _SidebarNavItem(
                  icon: Icons.add_box_outlined,
                  label: 'Post a Scene',
                  selected: currentRoute == '/create',
                  onTap: () => Navigator.pushReplacementNamed(
                    context,
                    '/create',
                  ),
                ),

                const SizedBox(height: 24),

                const _SideLabel('RESOURCES'),
                const SizedBox(height: 10),

                const _SidebarNavItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About Scenagram',
                  selected: false,
                ),

                const _SidebarNavItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help Center',
                  selected: false,
                ),

                const _SidebarNavItem(
                  icon: Icons.campaign_outlined,
                  label: 'Advertise',
                  selected: false,
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '? 2026 Scenagram',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF858B98),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Terms  ?  Privacy  ?  Cookies',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF777D8A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _SidebarNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() =>
      _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFF4EAFE)
                  : (_hovering
                      ? const Color(0xFFF8F8FB)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 19,
                  color: selected
                      ? const Color(0xFF7B2DD0)
                      : const Color(0xFF555D6C),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selected
                          ? const Color(0xFF7230BB)
                          : const Color(0xFF343A46),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _SceneTypeStrip extends StatelessWidget {
  final SceneType? selected;
  final ValueChanged<SceneType?>? onSelect;

  const _SceneTypeStrip({
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

class _SideLabel extends StatelessWidget {
  final String text;

  const _SideLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0.9,
        ),
      ),
    );
  }
}

class _SidebarHideButton extends StatefulWidget {
  final VoidCallback onTap;

  const _SidebarHideButton({required this.onTap});

  @override
  State<_SidebarHideButton> createState() => _SidebarHideButtonState();
}

class _SidebarHideButtonState extends State<_SidebarHideButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _hovering
                ? const Color(0xFFEDEFF5)
                : const Color(0xFFF1F3F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Icon(
            Icons.chevron_left_rounded,
            size: 18,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

class _SidebarRestoreButton extends StatelessWidget {
  final String side;
  final VoidCallback onTap;

  const _SidebarRestoreButton({
    required this.side,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = side == 'left'
        ? Icons.chevron_right_rounded
        : Icons.chevron_left_rounded;

    return Container(
      width: 34,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Icon(
            icon,
            size: 18,
            color: const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

/* ---------------------------
   HOME PAGE
---------------------------- */
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final FeedController _feedController;

  @override
  void initState() {
    super.initState();

    _feedController = FeedController();
    _feedController.addListener(_onFeedChanged);
  }

  void _onFeedChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _feedController.removeListener(_onFeedChanged);
    _feedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scenes =
        _feedController.scenesForActiveFeed(homeScenes);

    return ScenagramFrame(
      currentRoute: '/',
      selectedSceneType: _feedController.activeFeed,
      onSelectSceneType: (value) {
        if (value != null) {
          _feedController.selectFeed(value);
        }
      },
      centerContent: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 34),
        children: [
          const _HomeFeedHeader(),
          const SizedBox(height: 20),

          if (scenes.isEmpty)
            _EmptyStateCard(
              title:
                  'No ${sceneTypeLabel(_feedController.activeFeed)} scenes yet',
              subtitle:
                  'Scenes classified into this feed will appear here.',
            )
          else
            ...scenes.map(
              (scene) => Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: ApprovedFeedCard(
                  scene: scene,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SceneDetailPage(scene: scene),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      rightSidebar: const ApprovedRightSidebar(),
    );
  }
}


class _HomeFeedHeader extends StatelessWidget {
  const _HomeFeedHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Home Feed',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Scenes people are reacting to right now.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Color(0xFF73798A),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE6E7ED),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Most Recent',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202633),
                ),
              ),
              SizedBox(width: 20),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 19,
                color: Color(0xFF343A46),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            child: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: Color(0xFF535A69),
            ),
          ),
        ),
      ],
    );
  }
}


class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEAF0)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 34,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------------------
   APPROVED CENTER CARD
---------------------------- */
class ApprovedFeedCard extends StatefulWidget {
  final Scene scene;
  final VoidCallback? onTap;

  const ApprovedFeedCard({
    super.key,
    required this.scene,
    this.onTap,
  });

  @override
  State<ApprovedFeedCard> createState() =>
      _ApprovedFeedCardState();
}

class _ApprovedFeedCardState extends State<ApprovedFeedCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 170),
        transform: Matrix4.identity()
          ..translate(
            0.0,
            _hovering ? -1.0 : 0.0,
          ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _hovering
                  ? const Color(0x10000000)
                  : const Color(0x07000000),
              blurRadius: _hovering ? 18 : 10,
              offset: Offset(
                0,
                _hovering ? 7 : 4,
              ),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                46,
                24,
                46,
                24,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFE7E8ED),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FeedHeaderRow(),

                  const SizedBox(height: 20),

                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 17,
                        height: 1.45,
                        color: Color(0xFF171C27),
                      ),
                      children: [
                        const TextSpan(
                          text: 'Just now: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: scene.caption.replaceFirst(
                            'Just now: ',
                            '',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9EBF2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          scene.images.isNotEmpty
                              ? Image.memory(
                                  scene.images.first,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&q=80',
                                  fit: BoxFit.cover,
                                ),

                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  Colors.black.withOpacity(0.16),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),

                          Center(
                            child: AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 170),
                              width: _hovering ? 70 : 66,
                              height: _hovering ? 70 : 66,
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withOpacity(0.52),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                          ),

                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withOpacity(0.76),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '0:58',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      const Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PerspectiveLinkPill(
                              label: 'Comedy',
                              icon: Icons
                                  .sentiment_very_satisfied_rounded,
                              color: Color(0xFFE43F7A),
                            ),
                            _PerspectiveLinkPill(
                              label: 'Analysis',
                              icon: Icons.star_rounded,
                              color: Color(0xFF0F9D7A),
                            ),
                            _PerspectiveLinkPill(
                              label: 'Debate',
                              icon: Icons
                                  .local_police_rounded,
                              color: Color(0xFF6D36D9),
                            ),
                            _PerspectiveLinkPill(
                              label: 'Reaction',
                              icon: Icons.circle,
                              color: Color(0xFFE83A78),
                            ),
                            _PerspectiveLinkPill(
                              label: 'Advice',
                              icon: Icons
                                  .thumb_up_alt_rounded,
                              color: Color(0xFFF59E0B),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Icon(
                        Icons.visibility_outlined,
                        size: 21,
                        color: Color(0xFF626979),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '18.7K views',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF626979),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Container(
                        width: 1,
                        height: 18,
                        color: const Color(0xFFD9DCE3),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        '??',
                        style: TextStyle(fontSize: 17),
                      ),

                      const SizedBox(width: 6),

                      const Text(
                        '1.2K',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF626979),
                        ),
                      ),
                    ],
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


class _FeedHeaderRow extends StatelessWidget {
  const _FeedHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CircleAvatar(
          radius: 27,
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
          ),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Nadia K.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.verified_rounded,
                    size: 17,
                    color: Color(0xFF7238D8),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                '12 min ago  ?  Witnessed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF73798A),
                ),
              ),
            ],
          ),
        ),

        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8B24C7),
            side: const BorderSide(
              color: Color(0xFFE2D7EA),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Follow',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(width: 12),

        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.more_vert_rounded,
            color: Color(0xFF555C6B),
            size: 21,
          ),
        ),
      ],
    );
  }
}


class _LanePill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _LanePill(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fg.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: fg,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _PerspectiveLinkPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _PerspectiveLinkPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}


class _CustomShareAction extends StatelessWidget {
  const _CustomShareAction();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(
          Icons.auto_awesome_outlined,
          size: 28,
          color: Color(0xFF4B5563),
        ),
        SizedBox(width: 8),
        Text(
          'Share',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

/* ---------------------------
   RIGHT SIDEBAR
---------------------------- */
class ApprovedRightSidebar extends StatelessWidget {
  const ApprovedRightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      children: const [
        _RightSidebarHeader(),

        SizedBox(height: 14),

        _SceneMapRadarCard(),

        SizedBox(height: 14),

        _RightStatsCard(),

        SizedBox(height: 14),

        _RightSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RightSectionTitle(
                title: 'Trending',
                actionText: 'See More',
              ),

              SizedBox(height: 8),

              _MiniTrendItem(
                title: 'Hot Take: Young repair culture. Is he right?',
                meta: 'Collin  ?  5 hours',
                icon: Icons.bolt_rounded,
                accent: Color(0xFFF97316),
              ),

              _MiniTrendItem(
                title: 'He caught his girlfriend cheating. Now what?',
                meta: 'Bryan Y.  ?  1 hour',
                icon: Icons.lightbulb_outline_rounded,
                accent: Color(0xFFF59E0B),
              ),

              _MiniTrendItem(
                title: 'I bailed on my friend?s wedding. Should I apologize?',
                meta: 'Bea  ?  38 min ago',
                icon: Icons.favorite_border_rounded,
                accent: Color(0xFFE84586),
                noBorder: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _RightSectionCard extends StatelessWidget {
  final Widget child;

  const _RightSectionCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE7E8ED),
        ),
      ),
      child: child,
    );
  }
}


class _RightSectionTitle extends StatelessWidget {
  final String title;
  final String actionText;

  const _RightSectionTitle({
    required this.title,
    this.actionText = 'See More',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF171C27),
            ),
          ),
        ),

        Text(
          actionText,
          style: const TextStyle(
            color: Color(0xFF7B2DD0),
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),

        const SizedBox(width: 2),

        const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF7B2DD0),
          size: 16,
        ),
      ],
    );
  }
}


class _MiniTrendItem extends StatefulWidget {
  final String title;
  final String meta;
  final bool noBorder;
  final IconData icon;
  final Color accent;

  const _MiniTrendItem({
    required this.title,
    required this.meta,
    required this.icon,
    required this.accent,
    this.noBorder = false,
  });

  @override
  State<_MiniTrendItem> createState() =>
      _MiniTrendItemState();
}

class _MiniTrendItemState extends State<_MiniTrendItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(
          vertical: 11,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: _hovering
              ? const Color(0xFFF9F9FC)
              : Colors.transparent,
          border: widget.noBorder
              ? null
              : const Border(
                  bottom: BorderSide(
                    color: Color(0xFFEDEEF3),
                  ),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: widget.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                size: 17,
                color: widget.accent,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.meta,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF858B98),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Color(0xFF252B37),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _RadarDot extends StatelessWidget {
  final Color color;
  final String label;

  const _RadarDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _MiniLegendDot(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFEAEAF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}


class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFE9EAF0),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF171C27),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7B8190),
            ),
          ),
        ],
      ),
    );
  }
}


/* ---------------------------
   TRENDING PAGE
---------------------------- */
class TrendingPage extends StatelessWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ranked = [...homeScenes]..sort((a, b) => b.heat.compareTo(a.heat));

    return ScenagramFrame(
      currentRoute: '/trending',
      centerContent: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF2D8A), Color(0xFFF59E0B)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Now',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Discover the hottest scenes people are reacting to right now.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          ...ranked.asMap().entries.map((entry) {
            final index = entry.key;
            final scene = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _TrendingSceneCard(
                rank: index + 1,
                scene: scene,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SceneDetailPage(scene: scene),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      rightSidebar: const ApprovedRightSidebar(),
    );
  }
}


class _TrendingSceneCard extends StatefulWidget {
  final int rank;
  final Scene scene;
  final VoidCallback? onTap;

  const _TrendingSceneCard({
    required this.rank,
    required this.scene,
    this.onTap,
  });

  @override
  State<_TrendingSceneCard> createState() => _TrendingSceneCardState();
}

class _TrendingSceneCardState extends State<_TrendingSceneCard> {
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
                              widget.scene.typeLabel,
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

/* ---------------------------
   CREATE PAGE
---------------------------- */
class CreateScenePage extends StatefulWidget {
  const CreateScenePage({super.key});

  @override
  State<CreateScenePage> createState() => _CreateScenePageState();
}

class _CreateScenePageState extends State<CreateScenePage> {
  final TextEditingController _captionCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _tagsCtrl = TextEditingController();
  final List<Uint8List> _pickedImages = [];
  Uint8List? _pickedVideo;
  String? _pickedVideoName;
  Scene? _preview;
  String? _errorText;
  bool _isPublishing = false;

  @override
  void dispose() {
    _captionCtrl.dispose();
    _locationCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = 3 - _pickedImages.length;
    if (remaining <= 0) return;

    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (res == null) return;

    final newBytes = <Uint8List>[];
    for (final f in res.files) {
      if (f.bytes != null) {
        newBytes.add(f.bytes!);
      }
      if (newBytes.length >= remaining) break;
    }

    if (newBytes.isEmpty) return;

    setState(() {
      _pickedImages.addAll(newBytes);
      if (_pickedImages.length > 3) {
        _pickedImages.removeRange(3, _pickedImages.length);
      }
    });
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  Future<void> _pickVideo() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: true,
    );

    if (res == null || res.files.isEmpty) return;

    final file = res.files.first;
    if (file.bytes == null) return;

    setState(() {
      _pickedVideo = file.bytes;
      _pickedVideoName = file.name;
    });
  }

  void _removeVideo() {
    setState(() {
      _pickedVideo = null;
      _pickedVideoName = null;
    });
  }

  bool _validateCaption() {
    final cap = _captionCtrl.text.trim();
    if (cap.isEmpty) {
      setState(() {
        _errorText = 'Please write a scene caption before continuing.';
      });
      return false;
    }

    setState(() {
      _errorText = null;
    });
    return true;
  }

  void _makePreview() {
    if (!_validateCaption()) return;

    final cap = _captionCtrl.text.trim();

    setState(() {
      _preview = Scene(
        type: detectSceneType(_captionCtrl.text),
        caption: cap,
        images: List<Uint8List>.from(_pickedImages),
        heat: 0,
      );
    });
  }

  void _saveDraft() {
    final cap = _captionCtrl.text.trim();

    if (cap.isEmpty &&
        _pickedImages.isEmpty &&
        _pickedVideoName == null &&
        _locationCtrl.text.trim().isEmpty &&
        _tagsCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to save yet. Add scene details first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved locally for now.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _publish() async {
    if (!_validateCaption()) return;

    final cap = _captionCtrl.text.trim();

    setState(() {
      _isPublishing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    homeScenes.insert(
      0,
      Scene(
        type: detectSceneType(_captionCtrl.text),
        caption: cap,
        images: List<Uint8List>.from(_pickedImages),
        heat: 0,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scene published successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return ScenagramFrame(
      currentRoute: '/create',
      centerContent: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFEAEAF0)),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scene Composer',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create a scene, choose its type, attach media, and prepare it for Perspectives.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 18),
                const Text(
                  'Scene Caption',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _captionCtrl,
                  maxLines: 6,
                  onChanged: (_) {
                    setState(() {
                      if (_errorText != null) {
                        _errorText = null;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Write the scene...',
                    errorText: _errorText,
                    filled: true,
                    fillColor: const Color(0xFFF8F9FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFEAEAF0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFEAEAF0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _locationCtrl,
                  decoration: InputDecoration(
                    hintText: 'Add location',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFEAEAF0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFEAEAF0)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAEAF0)),
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.image_outlined),
                        label: Text(
                          _pickedImages.isEmpty
                              ? 'Photo'
                              : 'Photos (${_pickedImages.length})',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickVideo,
                        icon: const Icon(Icons.videocam_outlined),
                        label: Text(
                          _pickedVideoName == null ? 'Video' : 'Video added',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        icon: const Icon(Icons.location_on_outlined),
                        label: const Text('Location'),
                      ),
                    ],
                  ),
                ),
                if (_pickedImages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pickedImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(
                                _pickedImages[i],
                                width: 112,
                                height: 86,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: InkWell(
                                onTap: () => _removeImage(i),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
                if (_pickedVideoName != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.videocam_outlined,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _pickedVideoName!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _removeVideo,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Remove video',
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _saveDraft,
                      child: const Text('Save Draft'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: _makePreview,
                      child: const Text('Preview'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isPublishing ? null : _publish,
                      child: _isPublishing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Publish Scene'),
                    ),
                  ],
                ),
              ],
            ),
              ),
            ),
          ),
          if (_preview != null) ...[
            const SizedBox(height: 20),
            const Text(
              'Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            ApprovedFeedCard(scene: _preview!),
          ],
        ],
      ),
      rightSidebar: const ApprovedRightSidebar(),
    );
  }
}

class _RightSidebarHeader extends StatelessWidget {
  const _RightSidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE7E8ED),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Right Panel',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF171C27),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Trending scenes, hot updates, and discovery tools.',
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: Color(0xFF777D8A),
            ),
          ),
        ],
      ),
    );
  }
}


class _SceneMapRadarCard extends StatelessWidget {
  const _SceneMapRadarCard();

  @override
  Widget build(BuildContext context) {
    return _RightSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Scene Map',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF171C27),
                  ),
                ),
              ),
              Icon(
                Icons.public_rounded,
                size: 17,
                color: Color(0xFF7B2DD0),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'See where activity is heating up.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF777D8A),
            ),
          ),

          const SizedBox(height: 14),

          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE9EAF0),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 116,
                  height: 116,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE3E5EB),
                    ),
                  ),
                ),

                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE3E5EB),
                    ),
                  ),
                ),

                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE3E5EB),
                    ),
                  ),
                ),

                Container(
                  width: 116,
                  height: 1,
                  color: const Color(0xFFE3E5EB),
                ),

                Container(
                  width: 1,
                  height: 116,
                  color: const Color(0xFFE3E5EB),
                ),

                const Positioned(
                  top: 30,
                  right: 50,
                  child: _RadarDot(
                    color: Color(0xFFE84586),
                    label: 'Drama',
                  ),
                ),

                const Positioned(
                  bottom: 28,
                  left: 52,
                  child: _RadarDot(
                    color: Color(0xFF2563EB),
                    label: 'Media',
                  ),
                ),

                const Positioned(
                  top: 68,
                  left: 30,
                  child: _RadarDot(
                    color: Color(0xFFF59E0B),
                    label: 'Event',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            children: [
              Expanded(
                child: _MiniLegendDot(
                  Color(0xFFE84586),
                  'Drama',
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _MiniLegendDot(
                  Color(0xFF2563EB),
                  'Media',
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _MiniLegendDot(
                  Color(0xFFF59E0B),
                  'Event',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: Icon(
                Icons.open_in_new_rounded,
                size: 15,
              ),
              label: Text(
                'Open Scene Map',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _RightStatsCard extends StatelessWidget {
  const _RightStatsCard();

  @override
  Widget build(BuildContext context) {
    return _RightSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Stats',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF171C27),
            ),
          ),

          const SizedBox(height: 12),

          const Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Hot',
                  value: '24',
                ),
              ),

              SizedBox(width: 8),

              Expanded(
                child: _MiniStat(
                  label: 'New',
                  value: '18',
                ),
              ),

              SizedBox(width: 8),

              Expanded(
                child: _MiniStat(
                  label: 'Saved',
                  value: '07',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


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

class _LaneSelectorChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LaneSelectorChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rawLane = label.split(' (').first;
    final laneColor = perspectiveLaneColor(rawLane);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? laneColor : const Color(0xFFF3F4F8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? laneColor : const Color(0xFFEAEAF0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              perspectiveLaneIcon(rawLane),
              size: 16,
              color: selected ? Colors.white : laneColor,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF111827),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerspectiveCard extends StatelessWidget {
  final String text;
  final int upvotes;
  final bool alreadyVoted;
  final VoidCallback? onUpvote;

  const _PerspectiveCard({
    required this.text,
    required this.upvotes,
    required this.alreadyVoted,
    required this.onUpvote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAF0)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'David L.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Upvotes: $upvotes',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onUpvote,
              child: Text(alreadyVoted ? 'Upvoted' : 'Upvote'),
            ),
          ],
        ),
      ),
    );
  }
}


/* ---------------------------
   PROFILE PAGE
---------------------------- */
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final totalScenes = homeScenes.length;
    final top = [...homeScenes]..sort((a, b) => b.heat.compareTo(a.heat));
    final topScene = top.isNotEmpty ? top.first : null;

    return ScenagramFrame(
      currentRoute: '/profile',
      centerContent: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              _ProfileStatCard('Total Scenes', '$totalScenes'),
              const SizedBox(width: 16),
              _ProfileStatCard(
                'Total Responses Posted',
                '$totalPerspectivesPosted',
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Top Scene',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (topScene != null) SimpleSceneCard(scene: topScene),
        ],
      ),
      rightSidebar: const ApprovedRightSidebar(),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;

  const _ProfileStatCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 92,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEAEAF0)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------
   SIMPLE SCENE CARD
---------------------------- */
class SimpleSceneCard extends StatelessWidget {
  final Scene scene;
  final VoidCallback? onTap;

  const SimpleSceneCard({
    super.key,
    required this.scene,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEAEAF0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scene.typeLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                scene.caption,
                style: const TextStyle(fontSize: 16, height: 1.45),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: scene.lanes
                    .map((e) => Chip(label: Text(e)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatefulWidget {
  final IconData icon;
  final String label;

  const _ActionPill({
    required this.icon,
    required this.label,
  });

  @override
  State<_ActionPill> createState() => _ActionPillState();
}

class _ActionPillState extends State<_ActionPill> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _hovering
              ? const Color(0xFFF1F3F7)
              : const Color(0xFFF8F9FC),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFEAEAF0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 18, color: const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------
   SCENE DETAIL PAGE
---------------------------- */
enum LaneSort { best, newest }

class SceneDetailPage extends StatefulWidget {
  final Scene scene;

  const SceneDetailPage({super.key, required this.scene});

  @override
  State<SceneDetailPage> createState() => _SceneDetailPageState();
}

class _SceneDetailPageState extends State<SceneDetailPage> {
  int selectedLaneIndex = 0;
  LaneSort _sort = LaneSort.best;
  final TextEditingController _perspectiveCtrl = TextEditingController();

  late List<String> lanes;
  late Map<String, List<PerspectiveItem>> perspectivesByLane;
  late Map<String, Set<int>> votedPerspectiveIndexesByLane;

  @override
  void initState() {
    super.initState();
    _perspectiveCtrl.addListener(() {
      if (mounted) setState(() {});
    });
    lanes = widget.scene.lanes;
    perspectivesByLane = {
      for (final lane in lanes)
        lane: [
          PerspectiveItem('First perspective in $lane.', upvotes: 2),
          PerspectiveItem('Another perspective in $lane.', upvotes: 1),
          PerspectiveItem('One more perspective in $lane.', upvotes: 0),
        ],
    };
    votedPerspectiveIndexesByLane = {
      for (final lane in lanes) lane: <int>{},
    };
  }

  int _countForLane(String lane) => (perspectivesByLane[lane] ?? const []).length;

  void _postPerspective() {
    final lane = lanes[selectedLaneIndex];
    final text = _perspectiveCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      perspectivesByLane[lane] = [
        PerspectiveItem(text, upvotes: 0),
        ...(perspectivesByLane[lane] ?? []),
      ];
      final old = votedPerspectiveIndexesByLane[lane] ?? <int>{};
      votedPerspectiveIndexesByLane[lane] = old.map((i) => i + 1).toSet();
      widget.scene.heat += 1;
      totalPerspectivesPosted += 1;
      _perspectiveCtrl.clear();
    });
  }

  void _upvotePerspective(int index) {
    final lane = lanes[selectedLaneIndex];
    final voted = votedPerspectiveIndexesByLane[lane] ?? <int>{};

    if (voted.contains(index)) return;

    setState(() {
      final list = perspectivesByLane[lane] ?? <PerspectiveItem>[];
      if (index >= 0 && index < list.length) {
        list[index].upvotes += 1;
        widget.scene.heat += 1;
        voted.add(index);
        votedPerspectiveIndexesByLane[lane] = voted;
      }
    });
  }

  @override
  void dispose() {
    _perspectiveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lane = lanes[selectedLaneIndex];
    final base = perspectivesByLane[lane] ?? const <PerspectiveItem>[];
    final perspectives = [...base];

    if (_sort == LaneSort.best) {
      perspectives.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    }

    final votedSet = votedPerspectiveIndexesByLane[lane] ?? <int>{};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Text(widget.scene.typeLabel),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFEAEAF0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FeedHeaderRow(),
                      const SizedBox(height: 18),
                      Text(
                        widget.scene.caption,
                        style: const TextStyle(
                          fontSize: 21,
                          height: 1.45,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        height: 360,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: const Color(0xFFE9EBF2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              widget.scene.images.isNotEmpty
                                  ? Image.memory(
                                      widget.scene.images.first,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1200&q=80',
                                      fit: BoxFit.cover,
                                    ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.center,
                                    colors: [
                                      Colors.black.withOpacity(0.20),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.72),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text(
                                    '0:58',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _LanePill(
                            'Reaction',
                            Color(0xFFF3E8FF),
                            Color(0xFF6D28D9),
                          ),
                          _LanePill(
                            'Comedy',
                            Color(0xFFFDE2E2),
                            Color(0xFFDC2626),
                          ),
                          _LanePill(
                            'Advice',
                            Color(0xFFFEF3C7),
                            Color(0xFF92400E),
                          ),
                          _LanePill(
                            'Analysis',
                            Color(0xFFE6F7F1),
                            Color(0xFF065F46),
                          ),
                          _LanePill(
                            'Debate',
                            Color(0xFFE7F0FF),
                            Color(0xFF1D4ED8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _ActionPill(
                            icon: Icons.thumb_up_alt_rounded,
                            label: '18.7k',
                          ),
                          _ActionPill(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: '2.4K Perspectives',
                          ),
                          _ActionPill(
                            icon: Icons.reply_rounded,
                            label: 'Share',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEAEAF0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Structured Lanes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: lanes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final laneName = lanes[i];
                          return _LaneSelectorChip(
                            label: '$laneName (${_countForLane(laneName)})',
                            selected: i == selectedLaneIndex,
                            onTap: () => setState(() => selectedLaneIndex = i),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Sort by',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('Best'),
                          selected: _sort == LaneSort.best,
                          onSelected: (_) => setState(() => _sort = LaneSort.best),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('New'),
                          selected: _sort == LaneSort.newest,
                          onSelected: (_) => setState(() => _sort = LaneSort.newest),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEAEAF0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a perspective in: $lane',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _perspectiveCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add your perspective...',
                        filled: true,
                        fillColor: const Color(0xFFF8F9FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFEAEAF0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFEAEAF0)),
                        ),
                      ),
                    ),
                    if (_perspectiveCtrl.text.trim().isNotEmpty &&
                        isPerspectiveLaneMismatch(
                          selectedLane: lane,
                          text: _perspectiveCtrl.text,
                        )) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.tips_and_updates_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Suggested: ${detectPerspectiveLaneWithConfidence(_perspectiveCtrl.text).lane} ? Confidence: ${(detectPerspectiveLaneWithConfidence(_perspectiveCtrl.text).confidence * 100).round()}% ? Current: $lane',
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                final suggested =
                                    detectPerspectiveLaneWithConfidence(_perspectiveCtrl.text).lane;
                                final idx = lanes.indexOf(suggested);
                                if (idx >= 0) {
                                  setState(() {
                                    selectedLaneIndex = idx;
                                  });
                                }
                              },
                              child: const Text('Move'),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {});
                              },
                              child: const Text('Keep'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _postPerspective,
                        child: const Text('Post Perspective'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Perspectives',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(perspectives.length, (i) {
                final r = perspectives[i];
                final originalIndex = base.indexOf(r);
                final alreadyVoted =
                    originalIndex >= 0 && votedSet.contains(originalIndex);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PerspectiveCard(
                    text: r.text,
                    upvotes: r.upvotes,
                    alreadyVoted: alreadyVoted,
                    onUpvote: alreadyVoted
                        ? null
                        : () => _upvotePerspective(originalIndex),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}