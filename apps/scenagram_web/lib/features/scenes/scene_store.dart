import '../../models/scene.dart';
import '../../models/scene_type.dart';

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
