import 'package:flutter/material.dart';

import '../../controllers/feed_controller.dart';
import 'scene_type_presentation.dart';
import '../../shell/scenagram_frame.dart';
import '../../widgets/approved_right_sidebar.dart';
import 'approved_feed_card.dart';
import 'scene_detail_page.dart';
import 'scene_store.dart';

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
