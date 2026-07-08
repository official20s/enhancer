import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://vltnyoquzhnyhrdwjgyt.supabase.co',
    anonKey: 'sb_publishable_YChIvTT7vr7mnzXO9yMgGg_9vKkZniM',
  );
  await Hive.initFlutter();
  await Hive.openBox('downloads');
  await MobileAds.instance.initialize();
  runApp(const EnhancerApp());
}
class EnhancerApp extends StatefulWidget {
  const EnhancerApp({super.key});

  @override
  State<EnhancerApp> createState() => _EnhancerAppState();
}

class _EnhancerAppState extends State<EnhancerApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  static const seedColor = Color(0xFF1FA37D); // green like the reference design

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rattamaar',
      debugShowCheckedModeBanner: false,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9F8),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: HomeShell(onToggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class HomeShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  const HomeShell({super.key, required this.onToggleTheme, required this.isDarkMode});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  List<Widget> get _pages => [
    const HomePage(),
    const ExplorePage(),
    const DownloadsPage(),
    const NotificationsPage(),
    MorePage(onToggleTheme: widget.onToggleTheme, isDarkMode: widget.isDarkMode),
  ];

  // Google's official TEST banner ad unit ID — replace with your real one from AdMob later
  static const _testBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: _testBannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _bannerLoaded = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_bannerLoaded && _bannerAd != null)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) => setState(() => _currentIndex = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Explore'),
              NavigationDestination(icon: Icon(Icons.download_outlined), selectedIcon: Icon(Icons.download), label: 'Downloads'),
              NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
              NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: 'More'),
            ],
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('Rattamaar', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Quality Study Material,\nOrganized for Your Success.',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Explore Courses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 130,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('courses').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final courses = snapshot.data!.docs;
                  if (courses.isEmpty) {
                    return const Center(child: Text('No courses yet'));
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      final data = course.data() as Map<String, dynamic>;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubjectsPage(
                                courseId: course.id,
                                courseName: data['name'] ?? '',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 130,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
  fit: StackFit.expand,
  children: [
    if (data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty)
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          data['imageUrl'],
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.menu_book, color: Theme.of(context).colorScheme.primary),
        ),
      ),
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
        ),
      ),
    ),
    Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Text(
        data['name'] ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final courses = snapshot.data!.docs;
          if (courses.isEmpty) {
            return const Center(child: Text('No courses yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final data = course.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(data['name'] ?? 'Untitled',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text(data['examType'] ?? ''),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SubjectsPage(
                          courseId: course.id,
                          courseName: data['name'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SubjectsPage extends StatelessWidget {
  final String courseId;
  final String courseName;
  const SubjectsPage({super.key, required this.courseId, required this.courseName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(courseName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('subjects')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final subjects = snapshot.data!.docs;
          if (subjects.isEmpty) {
            return const Center(child: Text('No subjects yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final data = subject.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(data['name'] ?? 'Untitled'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChaptersPage(
                          courseId: courseId,
                          subjectId: subject.id,
                          subjectName: data['name'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ChaptersPage extends StatelessWidget {
  final String courseId;
  final String subjectId;
  final String subjectName;
  const ChaptersPage({
    super.key,
    required this.courseId,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(subjectName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('subjects')
            .doc(subjectId)
            .collection('chapters')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chapters = snapshot.data!.docs;
          if (chapters.isEmpty) {
            return const Center(child: Text('No chapters yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              final data = chapter.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(data['name'] ?? 'Untitled'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => LecturesPage(
        courseId: courseId,
        subjectId: subjectId,
        chapterId: chapter.id,
        chapterName: data['name'] ?? '',
      ),
    ),
  );
},
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  Box get _box => Hive.box('downloads');

  void _delete(String key, String path) {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
    _box.delete(key);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final keys = _box.keys.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Downloads')),
      body: keys.isEmpty
          ? const Center(child: Text('No downloads yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                final key = keys[index] as String;
                final entry = _box.get(key);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    title: Text(entry['name'] ?? 'Untitled'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _delete(key, entry['path']),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfViewerPage(
                            url: key,
                            title: entry['name'] ?? 'PDF',
                            localPath: entry['path'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Notifications'));
}

class MorePage extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;
  const MorePage({super.key, required this.onToggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Dark Mode'),
              subtitle: Text(isDarkMode ? 'Currently on' : 'Currently off'),
              value: isDarkMode,
              onChanged: (_) => onToggleTheme(),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About Rattamaar'),
              subtitle: Text('Study. Practice. Succeed.'),
            ),
          ),
        ],
      ),
    );
  }
}
class LecturesPage extends StatelessWidget {
  final String courseId;
  final String subjectId;
  final String chapterId;
  final String chapterName;
  const LecturesPage({
    super.key,
    required this.courseId,
    required this.subjectId,
    required this.chapterId,
    required this.chapterName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(chapterName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('subjects')
            .doc(subjectId)
            .collection('chapters')
            .doc(chapterId)
            .collection('lectures')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final lectures = snapshot.data!.docs;
          if (lectures.isEmpty) {
            return const Center(child: Text('No lectures yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lectures.length,
            itemBuilder: (context, index) {
              final lecture = lectures[index];
              final data = lecture.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.play_circle_fill, size: 32),
                  title: Text(data['title'] ?? 'Untitled'),
                  subtitle: Text('${((data['durationSec'] ?? 0) / 60).floor()} min'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LectureDetailPage(data: data),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class LectureDetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const LectureDetailPage({super.key, required this.data});

  @override
  State<LectureDetailPage> createState() => _LectureDetailPageState();
}

class _LectureDetailPageState extends State<LectureDetailPage> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final youtubeId = widget.data['youtubeId'] as String?;
    if (youtubeId != null && youtubeId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: youtubeId,
        flags: const YoutubePlayerFlags(autoPlay: false),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.data['title'] ?? 'Lecture';
    final pdfName = widget.data['pdfName'] as String?;
    final pdfUrl = widget.data['pdfUrl'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_controller != null)
            YoutubePlayer(controller: _controller!)
          else
            Container(
              height: 200,
              color: Colors.black12,
              child: const Center(child: Text('No video available')),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          if (pdfName != null && pdfName.isNotEmpty && pdfUrl != null && pdfUrl.isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: PdfCard(pdfName: pdfName, pdfUrl: pdfUrl),
  ),
        ],
      ),
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String title;
  final String? localPath;
  const PdfViewerPage({super.key, required this.url, required this.title, this.localPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: (localPath != null && File(localPath!).existsSync())
          ? SfPdfViewer.file(File(localPath!))
          : SfPdfViewer.network(url),
    );
  }
}

class PdfCard extends StatefulWidget {
  final String pdfName;
  final String pdfUrl;
  const PdfCard({super.key, required this.pdfName, required this.pdfUrl});

  @override
  State<PdfCard> createState() => _PdfCardState();
}

class _PdfCardState extends State<PdfCard> {
  double? _progress;
  String? _localPath;

  Box get _box => Hive.box('downloads');

  @override
  void initState() {
    super.initState();
    final saved = _box.get(widget.pdfUrl);
    if (saved != null && File(saved['path']).existsSync()) {
      _localPath = saved['path'];
    }
  }

  Future<void> _download() async {
    setState(() => _progress = 0);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final safeName = widget.pdfName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final savePath = '${dir.path}/$safeName.pdf';
      await Dio().download(
        widget.pdfUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            setState(() => _progress = received / total);
          }
        },
      );
      await _box.put(widget.pdfUrl, {'name': widget.pdfName, 'path': savePath});
      setState(() {
        _localPath = savePath;
        _progress = null;
      });
    } catch (e) {
      setState(() => _progress = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(widget.pdfName),
        subtitle: _progress != null
            ? LinearProgressIndicator(value: _progress)
            : null,
        trailing: _progress != null
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : IconButton(
                icon: Icon(_localPath != null ? Icons.check_circle : Icons.download,
                    color: _localPath != null ? Colors.green : null),
                onPressed: _localPath != null ? null : _download,
              ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfViewerPage(
                url: widget.pdfUrl,
                title: widget.pdfName,
                localPath: _localPath,
              ),
            ),
          );
        },
      ),
    );
  }
}
