import '../../models/scene_type.dart';

String sceneTypeFeedRoute(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return '/feed/confess';
    case SceneType.dilemma:
      return '/feed/dilemma';
    case SceneType.drama:
      return '/feed/drama';
    case SceneType.media:
      return '/feed/media';
    case SceneType.celebration:
      return '/feed/celebration';
    case SceneType.hotTake:
      return '/feed/hot-take';
    case SceneType.event:
      return '/feed/event';
  }
}
