import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/design_tokens.dart';

void main() => runApp(const ScenagramApp());

class ScenagramApp extends StatelessWidget {
  const ScenagramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenagram',
      debugShowCheckedModeBanner: false,
      theme: SGTheme.light(),
      darkTheme: SGTheme.dark(),
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

String sceneTypeLabel(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return 'Confession';
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
      return Icons.balance_rounded;
    case SceneType.drama:
      return Icons.theater_comedy_rounded;
    case SceneType.media:
      return Icons.video_library_rounded;
    case SceneType.celebration:
      return Icons.celebration_rounded;
    case SceneType.hotTake:
      return Icons.local_fire_department_rounded;
    case SceneType.event:
      return Icons.event_note_rounded;
  }
}

Color sceneTypeColor(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return const Color(0xFFC026D3);
    case SceneType.dilemma:
      return const Color(0xFF4F46E5);
    case SceneType.drama:
      return const Color(0xFFE11D48);
    case SceneType.media:
      return const Color(0xFF111827);
    case SceneType.celebration:
      return const Color(0xFFF59E0B);
    case SceneType.hotTake:
      return const Color(0xFFEA580C);
    case SceneType.event:
      return const Color(0xFFEC4899);
  }
}

List<String> lanesForType(SceneType t) {
  return kUniversalLanes;
}

/* ---------------------------
   CORE MATRIX V1
---------------------------- */
enum SceneType {
  confession,
  dilemma,
  drama,
  media,
  celebration,
  hotTake,
  event,
}

const List<String> kUniversalLanes = [
  'Reactions',
  'Comedy',
  'Advice',
  'Analysis',
  'Debate',
];

/* ---------------------------
   SCENE MODEL
---------------------------- */
class Scene {
  final SceneType type;
  final String caption;
  final List<Uint8List> images;
  int heat;

  Scene({
    required this.type,
    required this.caption,
    this.images = const [],
    this.heat = 0,
  });

  List<String> get lanes => lanesForType(type);
  String get typeLabel => sceneTypeLabel(type);
}

/* ---------------------------
   LOCAL DATA
---------------------------- */
final List<Scene> homeScenes = [
  Scene(
    type: SceneType.drama,
    caption:
        'Just now: A heated argument broke out at a public event after a well-known influencer allegedly disrespected a small business owner on stage. The crowd quickly took sides. Watch and share your thoughts.',
    heat: 4,
  ),
  Scene(
    type: SceneType.media,
    caption:
        'A short educational clip explains why some traditional habits still work better than modern shortcuts.',
    heat: 3,
  ),
  Scene(
    type: SceneType.event,
    caption:
        'A rescue team helped trapped passengers after a highway crash caused a major traffic standstill.',
    heat: 2,
  ),
];

int totalReactionsPosted = 0;

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
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFDFDFE),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE7E8EE)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
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
                            width: 248,
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
                                        maxWidth: 780,
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
                                  width: 320,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFDFE),
        border: Border(
          bottom: BorderSide(color: Color(0xFFEAEAF0)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 52,
            child: Row(
              children: [
                _WindowDot(Color(0xFFFF5F57)),
                SizedBox(width: 6),
                _WindowDot(Color(0xFFFEBB2E)),
                SizedBox(width: 6),
                _WindowDot(Color(0xFF28C840)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF04D8A), Color(0xFFF59E0B)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Scenagram',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F9),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFEEF0F5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search Scenagram web',
                          style: TextStyle(
                            color: Color(0xFF8A8FA0),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const _TopIcon(icon: Icons.search_rounded),
          const SizedBox(width: 12),
          const _TopIcon(icon: Icons.chat_bubble_outline_rounded),
          const SizedBox(width: 12),
          const _TopBadgeIcon(
            icon: Icons.desktop_windows_outlined,
            count: '6',
          ),
          const SizedBox(width: 12),
          const _TopBadgeIcon(
            icon: Icons.notifications_none_rounded,
            count: '3',
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () {
              if (currentRoute != '/create') {
                Navigator.pushReplacementNamed(context, '/create');
              }
            },
            borderRadius: BorderRadius.circular(26),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF2D8A), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22F04D8A),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Text(
                    'Post a Scene',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF111827),
                size: 26,
              ),
            ),
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
        Icon(icon, size: 24, color: const Color(0xFF111827)),
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18),
            height: 18,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE84586),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
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
      width: 255,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F8FB),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEAEAF0)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nadia K.',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '@nadiak',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                _SidebarHideButton(onTap: onHide),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SideLabel('ACCOUNT'),
          const SizedBox(height: 8),
          _SidebarNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            selected: currentRoute == '/profile',
            onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
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
            icon: Icons.security_outlined,
            label: 'Privacy & Security',
            selected: false,
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFEAEAF0)),
          const SizedBox(height: 18),
          const _SideLabel('SCENAGRAM'),
          const SizedBox(height: 8),
          _SidebarNavItem(
            icon: Icons.home_outlined,
            label: 'Home Feed',
            selected: currentRoute == '/',
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          _SidebarNavItem(
            icon: Icons.local_fire_department_outlined,
            label: 'Trending',
            selected: currentRoute == '/trending',
            onTap: () => Navigator.pushReplacementNamed(context, '/trending'),
          ),
          _SidebarNavItem(
            icon: Icons.add_box_outlined,
            label: 'Post a Scene',
            selected: currentRoute == '/create',
            onTap: () => Navigator.pushReplacementNamed(context, '/create'),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFEAEAF0)),
          const SizedBox(height: 18),
          const _SideLabel('RESOURCES'),
          const SizedBox(height: 8),
          const _SidebarNavItem(
            icon: Icons.info_outline,
            label: 'About Scenagram',
            selected: false,
          ),
          const _SidebarNavItem(
            icon: Icons.help_outline,
            label: 'Help Center',
            selected: false,
          ),
          const _SidebarNavItem(
            icon: Icons.campaign_outlined,
            label: 'Advertise',
            selected: false,
          ),
          const _SidebarNavItem(
            icon: Icons.code_rounded,
            label: 'Developer Platform',
            selected: false,
          ),
          const _SidebarNavItem(
            icon: Icons.article_outlined,
            label: 'Blog',
            selected: false,
          ),
          const _SidebarNavItem(
            icon: Icons.work_outline,
            label: 'Careers',
            selected: false,
          ),
          const _SidebarNavItem(
            icon: Icons.policy_outlined,
            label: 'Policies',
            selected: false,
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
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
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
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFF3E8F4)
                  : (_hovering
                      ? const Color(0xFFF1F3F7)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFFF0D5E5)
                    : (_hovering
                        ? const Color(0xFFEAEAF0)
                        : Colors.transparent),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  alignment: Alignment.center,
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: selected
                        ? const Color(0xFFE84586)
                        : const Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: const Color(0xFF111827),
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
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFDFE),
        border: Border(
          bottom: BorderSide(color: Color(0xFFEAEAF0)),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: SceneType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final type = SceneType.values[index];
          return _SceneTypeTab(
            type: type,
            selected: selected == type,
            onTap: () => onSelect?.call(type),
          );
        },
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
    final isSelected = widget.selected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 130,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF3E8F4)
                : (_hovering
                    ? const Color(0xFFF3F4F8)
                    : const Color(0xFFF7F8FB)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFF0D5E5)
                  : const Color(0xFFEAEAF0),
            ),
            boxShadow: _hovering
                ? const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                sceneTypeIcon(widget.type),
                size: 18,
                color: sceneTypeColor(widget.type),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  sceneTypeLabel(widget.type),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: sceneTypeColor(widget.type),
                  ),
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
  SceneType? _filter;

  @override
  Widget build(BuildContext context) {
    var list = [...homeScenes];
    if (_filter != null) {
      list = list.where((s) => s.type == _filter).toList();
    }

    final scene = list.isNotEmpty ? list.first : null;

    return ScenagramFrame(
      currentRoute: '/',
      selectedSceneType: _filter,
      onSelectSceneType: (value) {
        setState(() {
          _filter = value;
        });
      },
      centerContent: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          const _PageSectionHeader(
            title: 'Home Feed',
            subtitle: 'Scenes people are reacting to right now.',
          ),
          const SizedBox(height: 16),
          if (scene == null)
            const _EmptyStateCard(
              title: 'No scenes yet',
              subtitle: 'When scenes are published, they will appear here.',
            )
          else
            ApprovedFeedCard(
              scene: scene,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SceneDetailPage(scene: scene),
                ),
              ),
            ),
        ],
      ),
      rightSidebar: const ApprovedRightSidebar(),
    );
  }
}


class _PageSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageSectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Color(0xFF6B7280),
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
  State<ApprovedFeedCard> createState() => _ApprovedFeedCardState();
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
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.identity()..translate(0.0, _hovering ? -2.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _hovering
                  ? const Color(0x16000000)
                  : const Color(0x0A000000),
              blurRadius: _hovering ? 22 : 14,
              offset: Offset(0, _hovering ? 10 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
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
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.45,
                          color: Color(0xFF111827),
                        ),
                        children: [
                          const TextSpan(
                            text: 'Just now: ',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: scene.caption.replaceFirst('Just now: ', ''),
                          ),
                        ],
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
                                    Colors.black.withOpacity(0.22),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Center(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: _hovering ? 84 : 76,
                                height: _hovering ? 84 : 76,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.36),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 48,
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
                    const SizedBox(height: 18),
                    const Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _LanePill(
                          'Reactions',
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
                    const Divider(height: 1, color: Color(0xFFEAEAF0)),
                    const SizedBox(height: 14),
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
                          label: '2.4K Comments',
                        ),
                        _ActionPill(
                          icon: Icons.reply_rounded,
                          label: 'Share',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Top Comments',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _CommentCard(),
                  ],
                ),
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
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nadia K.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 2),
              Text(
                '12 min ago  •  Witnessed',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Follow'),
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

class _CommentCard extends StatelessWidget {
  const _CommentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFCFE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
                ),
              ),
              SizedBox(width: 10),
              Text(
                'David L.',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '+ min ago',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Respect goes both ways, if this is how she treats people in public, imagine what happens.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFEAEAF0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Add your reaction...',
              style: TextStyle(
                color: Color(0xFF8A8FA0),
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniReaction(
                'Insightful',
                Color(0xFFE9D5FF),
                Color(0xFF7E22CE),
              ),
              _MiniReaction('Agree', Color(0xFFFECACA), Color(0xFFDC2626)),
              _MiniReaction('Not Sure', Color(0xFFD1FAE5), Color(0xFF047857)),
              _MiniReaction('Unfair', Color(0xFFFDE68A), Color(0xFFB45309)),
              _MiniReaction('Crazy', Color(0xFFFBCFE8), Color(0xFFBE185D)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniReaction extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _MiniReaction(this.label, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
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
      padding: const EdgeInsets.all(18),
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
              _RightSectionTitle(title: 'Trending'),
              SizedBox(height: 12),
              _MiniTrendItem(
                title: 'Hot Take: Youngling repary culture. Is he right?',
                meta: 'Collin  •  5 hours',
              ),
              _MiniTrendItem(
                title: 'Advice: He caught his girlfriend cheating. Now what?',
                meta: 'Bryan Y.  •  1 hour',
              ),
              _MiniTrendItem(
                title: 'I bailed on my friend’s wedding. Should I apologize?',
                meta: 'Bea  •  38 min ago',
                noBorder: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        _RightSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RightSectionTitle(title: 'Hot Scenes'),
              SizedBox(height: 12),
              _MiniTrendItem(
                title: 'Elephants rescue baby elephant from mud',
                meta: 'Event  •  3 min ago',
              ),
              _MiniTrendItem(
                title: 'Mine blowing new alien discovery! 1m in',
                meta: 'Media  •  9 min ago',
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

  const _RightSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEAF0)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}

class _RightSectionTitle extends StatelessWidget {
  final String title;
  const _RightSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ),
        const Text(
          'See More',
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF2563EB),
          size: 18,
        ),
      ],
    );
  }
}

class _MiniTrendItem extends StatefulWidget {
  final String title;
  final String meta;
  final bool noBorder;

  const _MiniTrendItem({
    required this.title,
    required this.meta,
    this.noBorder = false,
  });

  @override
  State<_MiniTrendItem> createState() => _MiniTrendItemState();
}

class _MiniTrendItemState extends State<_MiniTrendItem> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _hovering ? const Color(0xFFF8F9FC) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: widget.noBorder
              ? null
              : const Border(
                  bottom: BorderSide(color: Color(0xFFEAEAF0)),
                ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _hovering
                    ? const Color(0xFFFCE7F3)
                    : const Color(0xFFF3F4F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.whatshot_rounded,
                size: 20,
                color: Color(0xFFE84586),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.meta,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.38,
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.more_horiz_rounded,
              color: _hovering
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF9CA3AF),
              size: 20,
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAEAF0)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
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
  SceneType _type = SceneType.drama;
  final TextEditingController _captionCtrl = TextEditingController();
  final List<Uint8List> _pickedImages = [];
  Scene? _preview;
  String? _errorText;
  bool _isPublishing = false;

  @override
  void dispose() {
    _captionCtrl.dispose();
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
        type: _type,
        caption: cap,
        images: List<Uint8List>.from(_pickedImages),
        heat: 0,
      );
    });
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
        type: _type,
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
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFEAEAF0)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a Scene',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Share a moment, upload media, and let people react through structured lanes.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Scene Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<SceneType>(
                  value: _type,
                  items: SceneType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Row(
                            children: [
                              Icon(
                                sceneTypeIcon(t),
                                size: 18,
                                color: sceneTypeColor(t),
                              ),
                              const SizedBox(width: 10),
                              Text(sceneTypeLabel(t)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _type = v);
                    }
                  },
                  decoration: InputDecoration(
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
                    if (_errorText != null) {
                      setState(() {
                        _errorText = null;
                      });
                    }
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
                const Text(
                  'Structured Lanes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _LanePill(
                      'Reactions',
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
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text('Add Images (${_pickedImages.length}/3)'),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Upload 1–3 images',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (_pickedImages.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEAEAF0)),
                    ),
                    child: SizedBox(
                      height: 96,
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
                                  width: 128,
                                  height: 96,
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
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.65),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEAEAF0)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Right Panel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Trending scenes, hot updates, and sidebar tools live here.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF6B7280),
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
          const Text(
            'Scene Map',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Radar of where scene activity is heating up.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAEAF0)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                ),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                ),
                Container(width: 132, height: 1, color: const Color(0xFFE2E8F0)),
                Container(width: 1, height: 132, color: const Color(0xFFE2E8F0)),
                const Positioned(
                  top: 34,
                  right: 62,
                  child: _RadarDot(
                    color: Color(0xFFE84586),
                    label: 'Drama',
                  ),
                ),
                const Positioned(
                  bottom: 34,
                  left: 56,
                  child: _RadarDot(
                    color: Color(0xFF2563EB),
                    label: 'Media',
                  ),
                ),
                const Positioned(
                  top: 72,
                  left: 34,
                  child: _RadarDot(
                    color: Color(0xFFF59E0B),
                    label: 'Event',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniLegendDot(Color(0xFFE84586), 'Drama'),
              _MiniLegendDot(Color(0xFF2563EB), 'Media'),
              _MiniLegendDot(Color(0xFFF59E0B), 'Event'),
            ],
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
      child: Row(
        children: const [
          Expanded(
            child: _MiniStat(
              label: 'Hot',
              value: '24',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _MiniStat(
              label: 'New',
              value: '18',
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: _MiniStat(
              label: 'Saved',
              value: '07',
            ),
          ),
        ],
      ),
    );
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE84586)
              : const Color(0xFFF3F4F8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color(0xFFE84586)
                : const Color(0xFFEAEAF0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  final String text;
  final int upvotes;
  final bool alreadyVoted;
  final VoidCallback? onUpvote;

  const _ResponseCard({
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
                '$totalReactionsPosted',
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

class ReactionItem {
  final String text;
  int upvotes;

  ReactionItem(this.text, {this.upvotes = 0});
}

class SceneDetailPage extends StatefulWidget {
  final Scene scene;

  const SceneDetailPage({super.key, required this.scene});

  @override
  State<SceneDetailPage> createState() => _SceneDetailPageState();
}

class _SceneDetailPageState extends State<SceneDetailPage> {
  int selectedLaneIndex = 0;
  LaneSort _sort = LaneSort.best;
  final TextEditingController _reactionCtrl = TextEditingController();

  late List<String> lanes;
  late Map<String, List<ReactionItem>> reactionsByLane;
  late Map<String, Set<int>> votedIndexesByLane;

  @override
  void initState() {
    super.initState();
    lanes = widget.scene.lanes;
    reactionsByLane = {
      for (final lane in lanes)
        lane: [
          ReactionItem('First response in $lane.', upvotes: 2),
          ReactionItem('Another response in $lane.', upvotes: 1),
          ReactionItem('One more response in $lane.', upvotes: 0),
        ],
    };
    votedIndexesByLane = {
      for (final lane in lanes) lane: <int>{},
    };
  }

  int _countForLane(String lane) => (reactionsByLane[lane] ?? const []).length;

  void _postReaction() {
    final lane = lanes[selectedLaneIndex];
    final text = _reactionCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      reactionsByLane[lane] = [
        ReactionItem(text, upvotes: 0),
        ...(reactionsByLane[lane] ?? []),
      ];
      final old = votedIndexesByLane[lane] ?? <int>{};
      votedIndexesByLane[lane] = old.map((i) => i + 1).toSet();
      widget.scene.heat += 1;
      totalReactionsPosted += 1;
      _reactionCtrl.clear();
    });
  }

  void _upvoteReaction(int index) {
    final lane = lanes[selectedLaneIndex];
    final voted = votedIndexesByLane[lane] ?? <int>{};

    if (voted.contains(index)) return;

    setState(() {
      final list = reactionsByLane[lane] ?? <ReactionItem>[];
      if (index >= 0 && index < list.length) {
        list[index].upvotes += 1;
        widget.scene.heat += 1;
        voted.add(index);
        votedIndexesByLane[lane] = voted;
      }
    });
  }

  @override
  void dispose() {
    _reactionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lane = lanes[selectedLaneIndex];
    final base = reactionsByLane[lane] ?? const <ReactionItem>[];
    final reactions = [...base];

    if (_sort == LaneSort.best) {
      reactions.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    }

    final votedSet = votedIndexesByLane[lane] ?? <int>{};

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
                            'Reactions',
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
                            label: '2.4K Comments',
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
                      'Add a response in: $lane',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reactionCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Add your response...',
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
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: _postReaction,
                        child: const Text('Post Response'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Responses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(reactions.length, (i) {
                final r = reactions[i];
                final originalIndex = base.indexOf(r);
                final alreadyVoted =
                    originalIndex >= 0 && votedSet.contains(originalIndex);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ResponseCard(
                    text: r.text,
                    upvotes: r.upvotes,
                    alreadyVoted: alreadyVoted,
                    onUpvote: alreadyVoted
                        ? null
                        : () => _upvoteReaction(originalIndex),
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