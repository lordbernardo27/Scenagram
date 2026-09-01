import 'dart:typed_data';

import 'scene_type.dart';
import 'scene_type_intelligence.dart';

class Scene {
  final SceneType type;
  final String caption;
  final List<Uint8List> images;
  int heat;

  Scene({
    required this.type,
    required this.caption,
    this.images = const [],
    this.heat = 0,
  });

  List<String> get lanes => lanesForType(type);
  String get typeLabel => sceneTypeLabel(type);
}
