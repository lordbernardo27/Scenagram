import 'package:flutter/material.dart';

import '../../models/scene.dart';
import '../../widgets/feed_header_row.dart';

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
                  const FeedHeaderRow(),

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
