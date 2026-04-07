import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/design_tokens.dart';

void main() => runApp(const ScenagramApp());

class ScenagramApp extends StatelessWidget {
  const ScenagramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scenagram',
      debugShowCheckedModeBanner: false,
      theme: SGTheme.light(),
      darkTheme: SGTheme.dark(),
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/trending': (context) => const TrendingPage(),
        '/create': (context) => const CreateScenePage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

/* ---------------------------
   HELPERS
---------------------------- */
String? badgeForHeat(int heat) {
  if (heat >= 5) return 'HOT';
  if (heat >= 3) return 'RISING';
  return null;
}

/* ---------------------------
   APP SHELL
---------------------------- */
class AppShell extends StatelessWidget {
  final String title;
  final Widget child;

  const AppShell({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
            child: const Text('Home'),
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/trending'),
            child: const Text('Trending'),
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/create'),
            child: const Text('Post'),
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/profile'),
            child: const Text('Profile'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.4,
            colors: [
              Color(0xFF1A2240),
              Color(0xFF111827),
              Color(0xFF070B14),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}

/* ---------------------------
   MVP SCENE TYPES
---------------------------- */
enum SceneType {
  confession,
  dilemma,
  drama,
  celebration,
  hotTake,
  adviceNeeded,
  event,
  awkwardMoment,
}

/* ---------------------------
   FROZEN LANE RULES
---------------------------- */
const List<String> kDefaultLanes = [
  'Comedy',
  'Advice Mode',
  'Plot Twists',
  'Savage Takes',
];

const List<String> kEventLanes = [
  'Analysis',
  'Community Response',
  'What Should Happen?',
];

String sceneTypeLabel(SceneType t) {
  switch (t) {
    case SceneType.confession:
      return 'Confession';
    case SceneType.dilemma:
      return 'Dilemma';
    case SceneType.drama:
      return 'Drama';
    case SceneType.celebration:
      return 'Celebration';
    case SceneType.hotTake:
      return 'Hot Take';
    case SceneType.adviceNeeded:
      return 'Advice Needed';
    case SceneType.event:
      return 'Event';
    case SceneType.awkwardMoment:
      return 'Awkward Moment';
  }
}

List<String> lanesForType(SceneType t) {
  return (t == SceneType.event) ? kEventLanes : kDefaultLanes;
}

/* ---------------------------
   SCENE MODEL
---------------------------- */
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

/* ---------------------------
   DATA (LOCAL-ONLY)
---------------------------- */
final List<Scene> homeScenes = [
  Scene(
    type: SceneType.drama,
    caption:
        'I just found out my best friend has been lying to me for months. What should I do?',
    heat: 2,
  ),
  Scene(
    type: SceneType.hotTake,
    caption:
        'Some people say money buys happiness. I think it buys freedom. What do you think?',
    heat: 1,
  ),
];

int totalReactionsPosted = 0;

/* ---------------------------
   HOME PAGE (New/Best)
---------------------------- */
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _best = false;

  @override
  Widget build(BuildContext context) {
    final list = [...homeScenes];
    if (_best) {
      list.sort((a, b) => b.heat.compareTo(a.heat));
    }

    return AppShell(
      title: 'Scenagram • Home',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ChoiceChip(
                label: const Text('New'),
                selected: !_best,
                onSelected: (_) => setState(() => _best = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Best'),
                selected: _best,
                onSelected: (_) => setState(() => _best = true),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(list.length, (i) {
            final s = list[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SceneCard(
                typeLabel: s.typeLabel,
                caption: s.caption,
                lanes: s.lanes,
                heat: s.heat,
                badgeText: badgeForHeat(s.heat),
                thumbnail: s.images.isNotEmpty ? s.images.first : null,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SceneDetailPage(scene: s)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/* ---------------------------
   TRENDING PAGE (Top 10 by heat + Type filter)
---------------------------- */
class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  SceneType? _filter;

  @override
  Widget build(BuildContext context) {
    final ranked = [...homeScenes]..sort((a, b) => b.heat.compareTo(a.heat));
    final filtered =
        (_filter == null) ? ranked : ranked.where((s) => s.type == _filter).toList();
    final top = filtered.take(10).toList();

    return AppShell(
      title: 'Scenagram • Trending',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Trending (Ranked by Heat)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              ...SceneType.values.map((t) {
                return ChoiceChip(
                  label: Text(sceneTypeLabel(t)),
                  selected: _filter == t,
                  onSelected: (_) => setState(() => _filter = t),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          if (top.isEmpty)
            const Text('No scenes match this filter yet.')
          else
            ...List.generate(top.length, (i) {
              final s = top[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SceneCard(
                  typeLabel: s.typeLabel,
                  caption: s.caption,
                  lanes: s.lanes,
                  heat: s.heat,
                  badgeText: badgeForHeat(s.heat),
                  thumbnail: s.images.isNotEmpty ? s.images.first : null,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SceneDetailPage(scene: s)),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

/* ---------------------------
   SCENE CARD
---------------------------- */
class SceneCard extends StatelessWidget {
  final String typeLabel;
  final String caption;
  final List<String> lanes;
  final int? heat;
  final String? badgeText;
  final Uint8List? thumbnail;
  final VoidCallback? onTap;

  const SceneCard({
    super.key,
    required this.typeLabel,
    required this.caption,
    required this.lanes,
    this.heat,
    this.badgeText,
    this.thumbnail,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                typeLabel,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (badgeText != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (heat != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Heat: $heat',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                caption,
                style: const TextStyle(fontSize: 16),
              ),
              if (thumbnail != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    thumbnail!,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: lanes
                    .map(
                      (t) => Chip(
                        label: Text(t),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------------------
   SCENE DETAIL PAGE
---------------------------- */
enum LaneSort { best, newest }

class ReactionItem {
  final String text;
  int upvotes;

  ReactionItem(this.text, {this.upvotes = 0});
}

class SceneDetailPage extends StatefulWidget {
  final Scene scene;

  const SceneDetailPage({super.key, required this.scene});

  @override
  State<SceneDetailPage> createState() => _SceneDetailPageState();
}

class _SceneDetailPageState extends State<SceneDetailPage> {
  int selectedLaneIndex = 0;
  LaneSort _sort = LaneSort.best;

  final TextEditingController _reactionCtrl = TextEditingController();
  late final List<String> lanes = widget.scene.lanes;

  late final Map<String, List<ReactionItem>> reactionsByLane = {
    for (final lane in lanes)
      lane: [
        ReactionItem('First take in $lane.', upvotes: 2),
        ReactionItem('Another reaction in $lane.', upvotes: 1),
        ReactionItem('One more opinion in $lane.', upvotes: 0),
      ]
  };

  late final Map<String, Set<int>> votedIndexesByLane = {
    for (final lane in lanes) lane: <int>{}
  };

  int _countForLane(String lane) => (reactionsByLane[lane] ?? const []).length;

  void _postReaction() {
    final lane = lanes[selectedLaneIndex];
    final text = _reactionCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() {
      reactionsByLane[lane] = [
        ReactionItem(text, upvotes: 0),
        ...(reactionsByLane[lane] ?? [])
      ];

      final old = votedIndexesByLane[lane] ?? <int>{};
      votedIndexesByLane[lane] = old.map((i) => i + 1).toSet();

      widget.scene.heat += 1;
      totalReactionsPosted += 1;
      _reactionCtrl.clear();
    });
  }

  void _postReactionText(String text) {
    final lane = lanes[selectedLaneIndex];

    setState(() {
      reactionsByLane[lane] = [
        ReactionItem(text, upvotes: 0),
        ...(reactionsByLane[lane] ?? [])
      ];

      final old = votedIndexesByLane[lane] ?? <int>{};
      votedIndexesByLane[lane] = old.map((i) => i + 1).toSet();

      widget.scene.heat += 1;
      totalReactionsPosted += 1;
    });
  }

  void _upvoteReaction(int index) {
    final lane = lanes[selectedLaneIndex];
    final voted = votedIndexesByLane[lane] ?? <int>{};

    if (voted.contains(index)) return;

    setState(() {
      final list = reactionsByLane[lane] ?? <ReactionItem>[];
      if (index >= 0 && index < list.length) {
        list[index].upvotes += 1;
        widget.scene.heat += 1;
        voted.add(index);
        votedIndexesByLane[lane] = voted;
      }
    });
  }

  @override
  void dispose() {
    _reactionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lane = lanes[selectedLaneIndex];
    final base = reactionsByLane[lane] ?? const <ReactionItem>[];
    final reactions = [...base];

    if (_sort == LaneSort.best) {
      reactions.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    }

    final votedSet = votedIndexesByLane[lane] ?? <int>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scene'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.scene.images.isNotEmpty) ...[
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.scene.images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      widget.scene.images[i],
                      width: 260,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.scene.typeLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.scene.caption,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Heat: ${widget.scene.heat}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Reaction Lanes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: lanes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final isSelected = i == selectedLaneIndex;
                final laneName = lanes[i];
                final count = _countForLane(laneName);

                return InkWell(
                  onTap: () => setState(() => selectedLaneIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$laneName ($count)',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write a reaction in: $lane',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _reactionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Type your reaction...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          final laneNow = lanes[selectedLaneIndex];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateReactionPage(
                                lane: laneNow,
                                onPost: (text) => _postReactionText(text),
                              ),
                            ),
                          );
                        },
                        child: const Text('Reply'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _postReaction,
                        child: const Text('Quick Post'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ChoiceChip(
                label: const Text('Best'),
                selected: _sort == LaneSort.best,
                onSelected: (_) => setState(() => _sort = LaneSort.best),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('New'),
                selected: _sort == LaneSort.newest,
                onSelected: (_) => setState(() => _sort = LaneSort.newest),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Top in: $lane',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...List.generate(reactions.length, (i) {
            final r = reactions[i];
            final originalIndex = base.indexOf(r);
            final alreadyVoted =
                originalIndex >= 0 && votedSet.contains(originalIndex);

            return Card(
              child: ListTile(
                title: Text(r.text),
                subtitle: Text('Upvotes: ${r.upvotes}'),
                trailing: ElevatedButton(
                  onPressed:
                      alreadyVoted ? null : () => _upvoteReaction(originalIndex),
                  child: Text(alreadyVoted ? 'Upvoted' : 'Upvote'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/* ---------------------------
   CREATE REACTION PAGE
---------------------------- */
class CreateReactionPage extends StatefulWidget {
  final String lane;
  final void Function(String text) onPost;

  const CreateReactionPage({
    super.key,
    required this.lane,
    required this.onPost,
  });

  @override
  State<CreateReactionPage> createState() => _CreateReactionPageState();
}

class _CreateReactionPageState extends State<CreateReactionPage> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    widget.onPost(text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reply • ${widget.lane}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a reaction in: ${widget.lane}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Type your reaction...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Post'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------------------
   CREATE SCENE PAGE
---------------------------- */
class CreateScenePage extends StatefulWidget {
  const CreateScenePage({super.key});

  @override
  State<CreateScenePage> createState() => _CreateScenePageState();
}

class _CreateScenePageState extends State<CreateScenePage> {
  SceneType _type = SceneType.drama;
  final TextEditingController _captionCtrl = TextEditingController();
  final List<Uint8List> _pickedImages = [];

  Scene? _preview;

  @override
  void dispose() {
    _captionCtrl.dispose();
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

    final files = res.files;
    final newBytes = <Uint8List>[];

    for (final f in files) {
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
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  void _makePreview() {
    final cap = _captionCtrl.text.trim();
    if (cap.isEmpty) return;

    setState(() {
      _preview = Scene(
        type: _type,
        caption: cap,
        images: List<Uint8List>.from(_pickedImages),
        heat: 0,
      );
    });
  }

  void _publish() {
    final cap = _captionCtrl.text.trim();
    if (cap.isEmpty) return;

    final newScene = Scene(
      type: _type,
      caption: cap,
      images: List<Uint8List>.from(_pickedImages),
      heat: 0,
    );

    homeScenes.insert(0, newScene);
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Scenagram • Post a Scene',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Create a Scene',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<SceneType>(
            value: _type,
            items: SceneType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(sceneTypeLabel(t)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _type = v);
            },
            decoration: const InputDecoration(
              labelText: 'Scene Type',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _captionCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Caption (required)',
              hintText: 'Write the scene...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickImages,
                child: Text('Add Images (${_pickedImages.length}/3)'),
              ),
              const SizedBox(width: 10),
              const Text('1–3 images allowed'),
            ],
          ),
          if (_pickedImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pickedImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _pickedImages[i],
                          width: 120,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: InkWell(
                          onTap: () => _removeImage(i),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
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
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _makePreview,
                child: const Text('Preview'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _publish,
                child: const Text('Publish'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_preview != null) ...[
            const Text(
              'Preview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SceneCard(
              typeLabel: _preview!.typeLabel,
              caption: _preview!.caption,
              lanes: _preview!.lanes,
              heat: _preview!.heat,
              badgeText: badgeForHeat(_preview!.heat),
              thumbnail: _preview!.images.isNotEmpty ? _preview!.images.first : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SceneDetailPage(scene: _preview!),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/* ---------------------------
   PROFILE
---------------------------- */
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final totalScenes = homeScenes.length;
    final top = [...homeScenes]..sort((a, b) => b.heat.compareTo(a.heat));
    final topScene = top.isNotEmpty ? top.first : null;

    return AppShell(
      title: 'Scenagram • Profile',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Profile (Local MVP)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              title: const Text('Total Scenes (Home)'),
              trailing: Text('$totalScenes'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Total Reactions Posted'),
              trailing: Text('$totalReactionsPosted'),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Top Scene (by Heat)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (topScene == null)
            const Text('No scenes yet.')
          else
            SceneCard(
              typeLabel: topScene.typeLabel,
              caption: topScene.caption,
              lanes: topScene.lanes,
              heat: topScene.heat,
              badgeText: badgeForHeat(topScene.heat),
              thumbnail: topScene.images.isNotEmpty ? topScene.images.first : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SceneDetailPage(scene: topScene)),
              ),
            ),
        ],
      ),
    );
  }
}