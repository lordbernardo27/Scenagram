import 'package:flutter/material.dart';

import '../../shell/scenagram_frame.dart';
import '../../widgets/approved_right_sidebar.dart';
import '../scenes/scene_detail_page.dart';
import '../scenes/scene_store.dart';
import 'trending_scene_card.dart';

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
              child: TrendingSceneCard(
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
