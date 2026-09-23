import 'dart:typed_data';

import 'scene_type.dart';

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
}
