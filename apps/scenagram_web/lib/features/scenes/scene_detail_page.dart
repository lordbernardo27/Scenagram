import 'package:flutter/material.dart';

import '../../models/scene.dart';
import '../../widgets/feed_header_row.dart';
import '../perspectives/perspective_item.dart';
import '../perspectives/perspective_intelligence.dart';
import 'scene_store.dart';
import 'scene_type_intelligence.dart';
import 'scene_type_presentation.dart';

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
    lanes = lanesForType(widget.scene.type);
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
        title: Text(sceneTypeLabel(widget.scene.type)),
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
                      const FeedHeaderRow(),
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
