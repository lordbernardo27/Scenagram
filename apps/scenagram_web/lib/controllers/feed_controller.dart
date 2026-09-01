import 'package:flutter/foundation.dart';

import '../models/scene.dart';
import '../models/scene_type.dart';

class FeedController extends ChangeNotifier {
  SceneType _activeFeed = SceneType.media;

  SceneType get activeFeed => _activeFeed;

  void selectFeed(SceneType feed) {
    if (_activeFeed == feed) return;

    _activeFeed = feed;
    notifyListeners();
  }

  List<Scene> scenesForActiveFeed(List<Scene> scenes) {
    return scenes
        .where((scene) => scene.type == _activeFeed)
        .toList();
  }

  bool isActive(SceneType feed) => _activeFeed == feed;
}
