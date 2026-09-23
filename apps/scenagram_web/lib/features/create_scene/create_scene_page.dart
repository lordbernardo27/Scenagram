import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/scene.dart';
import '../scenes/scene_type_intelligence.dart';
import '../../shell/scenagram_frame.dart';
import '../../widgets/approved_right_sidebar.dart';
import '../scenes/approved_feed_card.dart';
import '../scenes/scene_store.dart';

class CreateScenePage extends StatefulWidget {
  const CreateScenePage({super.key});

  @override
  State<CreateScenePage> createState() => _CreateScenePageState();
}

class _CreateScenePageState extends State<CreateScenePage> {
  final TextEditingController _captionCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _tagsCtrl = TextEditingController();
  final List<Uint8List> _pickedImages = [];
  Uint8List? _pickedVideo;
  String? _pickedVideoName;
  Scene? _preview;
  String? _errorText;
  bool _isPublishing = false;

  @override
  void dispose() {
    _captionCtrl.dispose();
    _locationCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = 3 - _pickedImages.length;
    if (remaining <= 0) return;

    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (res == null) return;

    final newBytes = <Uint8List>[];
    for (final f in res.files) {
      if (f.bytes != null) {
        newBytes.add(f.bytes!);
      }
      if (newBytes.length >= remaining) break;
    }

    if (newBytes.isEmpty) return;

    setState(() {
      _pickedImages.addAll(newBytes);
      if (_pickedImages.length > 3) {
        _pickedImages.removeRange(3, _pickedImages.length);
      }
    });
  }

  void _removeImage(int index) {
    setState(() => _pickedImages.removeAt(index));
  }

  Future<void> _pickVideo() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: true,
    );

    if (res == null || res.files.isEmpty) return;

    final file = res.files.first;
    if (file.bytes == null) return;

    setState(() {
      _pickedVideo = file.bytes;
      _pickedVideoName = file.name;
    });
  }

  void _removeVideo() {
    setState(() {
      _pickedVideo = null;
      _pickedVideoName = null;
    });
  }

  bool _validateCaption() {
    final cap = _captionCtrl.text.trim();
    if (cap.isEmpty) {
      setState(() {
        _errorText = 'Please write a scene caption before continuing.';
      });
      return false;
    }

    setState(() {
      _errorText = null;
    });
    return true;
  }

  void _makePreview() {
    if (!_validateCaption()) return;

    final cap = _captionCtrl.text.trim();

    setState(() {
      _preview = Scene(
        type: detectSceneType(_captionCtrl.text),
        caption: cap,
        images: List<Uint8List>.from(_pickedImages),
        heat: 0,
      );
    });
  }

  void _saveDraft() {
    final cap = _captionCtrl.text.trim();

    if (cap.isEmpty &&
        _pickedImages.isEmpty &&
        _pickedVideoName == null &&
        _locationCtrl.text.trim().isEmpty &&
        _tagsCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to save yet. Add scene details first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved locally for now.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _publish() async {
    if (!_validateCaption()) return;

    final cap = _captionCtrl.text.trim();

    setState(() {
      _isPublishing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    homeScenes.insert(
      0,
      Scene(
        type: detectSceneType(_captionCtrl.text),
        caption: cap,
        images: List<Uint8List>.from(_pickedImages),
        heat: 0,
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Scene published successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return ScenagramFrame(
      currentRoute: '/create',
      centerContent: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFEAEAF0)),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 28,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scene Composer',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Create a scene, choose its type, attach media, and prepare it for Perspectives.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 18),
                const Text(
                  'Scene Caption',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _captionCtrl,
                  maxLines: 6,
                  onChanged: (_) {
                    setState(() {
                      if (_errorText != null) {
                        _errorText = null;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Write the scene...',
                    errorText: _errorText,
                    filled: true,
                    fillColor: const Color(0xFFF8F9FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFEAEAF0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFEAEAF0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _locationCtrl,
                  decoration: InputDecoration(
                    hintText: 'Add location',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFEAEAF0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFEAEAF0)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAEAF0)),
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.image_outlined),
                        label: Text(
                          _pickedImages.isEmpty
                              ? 'Photo'
                              : 'Photos (${_pickedImages.length})',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _pickVideo,
                        icon: const Icon(Icons.videocam_outlined),
                        label: Text(
                          _pickedVideoName == null ? 'Video' : 'Video added',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                        },
                        icon: const Icon(Icons.location_on_outlined),
                        label: const Text('Location'),
                      ),
                    ],
                  ),
                ),
                if (_pickedImages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 86,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _pickedImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(
                                _pickedImages[i],
                                width: 112,
                                height: 86,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: InkWell(
                                onTap: () => _removeImage(i),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
                if (_pickedVideoName != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.videocam_outlined,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _pickedVideoName!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _removeVideo,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Remove video',
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _saveDraft,
                      child: const Text('Save Draft'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: _makePreview,
                      child: const Text('Preview'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _isPublishing ? null : _publish,
                      child: _isPublishing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Publish Scene'),
                    ),
                  ],
                ),
              ],
            ),
              ),
            ),
          ),
          if (_preview != null) ...[
            const SizedBox(height: 20),
            const Text(
              'Preview',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            ApprovedFeedCard(scene: _preview!),
          ],
        ],
      ),
      rightSidebar: const ApprovedRightSidebar(),
    );
  }
}
