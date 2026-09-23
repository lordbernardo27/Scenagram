import 'package:flutter/material.dart';

import '../models/scene_type.dart';
import '../features/scenes/scene_type_presentation.dart';

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
