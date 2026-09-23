import 'package:flutter/material.dart';

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
