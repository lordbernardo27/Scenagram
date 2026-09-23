import 'package:flutter/material.dart';

import '../../models/scene.dart';
import '../../shell/scenagram_frame.dart';
import '../../widgets/approved_right_sidebar.dart';
import '../scenes/scene_store.dart';
import '../scenes/scene_type_intelligence.dart';
import '../scenes/scene_type_presentation.dart';

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
                sceneTypeLabel(scene.type),
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
                children: lanesForType(scene.type)
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
