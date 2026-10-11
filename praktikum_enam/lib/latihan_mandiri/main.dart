import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);

const pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final modeGelap = prefs.getBool('modeGelap') ?? false;
  final indeksWarna =
      (prefs.getInt('warnaTema') ?? 0).clamp(0, pilihanWarna.length - 1).toInt();

  themeMode.value = modeGelap ? ThemeMode.dark : ThemeMode.light;
  seedColor.value = pilihanWarna[indeksWarna];

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Praktikum 6',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {
            '/': (_) => const ShellPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final item = settings.arguments as Item;
              return PageRouteBuilder<void>(
                settings: settings,
                pageBuilder: (context, animation, secondaryAnimation) {
                  return DetailPage(item: item);
                },
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              );
            }
            return null;
          },
          onUnknownRoute: (settings) {
            return MaterialPageRoute<void>(
              builder: (_) => const NotFoundPage(),
            );
          },
        );
      },
    );
  }
}

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (v) async {
                themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('modeGelap', v);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Warna tema',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                for (final c in pilihanWarna)
                  GestureDetector(
                    onTap: () async {
                      seedColor.value = c;
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('warnaTema', pilihanWarna.indexOf(c));
                    },
                    child: CircleAvatar(
                      backgroundColor: c,
                      child: seedColor.value == c
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class Item {
  final String nama;
  final IconData ikon;
  final Color warna;

  const Item(this.nama, this.ikon, this.warna);
}

const daftarItem = [
  Item('Flutter', Icons.flutter_dash, Colors.blue),
  Item('Musik', Icons.music_note, Colors.pink),
  Item('Kamera', Icons.camera_alt, Colors.orange),
  Item('Peta', Icons.map, Colors.green),
];

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: daftarItem.length,
      itemBuilder: (context, i) {
        final item = daftarItem[i];
        return ListTile(
          leading: Hero(
            tag: 'ikon-${item.nama}',
            child: CircleAvatar(
              backgroundColor: item.warna,
              child: Icon(item.ikon, color: Colors.white),
            ),
          ),
          title: Text(item.nama),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.pushNamed(context, '/detail', arguments: item);
          },
        );
      },
    );
  }
}

class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(item.nama)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'ikon-${item.nama}',
              child: CircleAvatar(
                radius: 64,
                backgroundColor: item.warna,
                child: Icon(item.ikon, size: 64, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(item.nama, style: tema.textTheme.headlineMedium),
            Text('Detail untuk ${item.nama}', style: tema.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class AnimasiTab extends StatefulWidget {
  const AnimasiTab({super.key});

  @override
  State<AnimasiTab> createState() => _AnimasiTabState();
}

class _AnimasiTabState extends State<AnimasiTab>
    with SingleTickerProviderStateMixin {
  bool _besar = false;
  bool _terlihat = true;
  int _hitung = 0;
  late final AnimationController _putar;

  @override
  void initState() {
    super.initState();
    _putar = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _putar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('1. AnimatedContainer', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: _besar ? 200 : 100,
            height: 100,
            decoration: BoxDecoration(
              color: _besar ? warna.primary : warna.tertiary,
              borderRadius: BorderRadius.circular(_besar ? 50 : 8),
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _besar = !_besar),
          child: const Text('Ubah bentuk'),
        ),
        const Divider(),
        Text('2. AnimatedSwitcher', style: tema.textTheme.titleMedium),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) {
              return ScaleTransition(scale: anim, child: child);
            },
            child: Text(
              '$_hitung',
              key: ValueKey(_hitung),
              style: tema.textTheme.displayMedium,
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _hitung++),
          child: const Text('Tambah'),
        ),
        const Divider(),
        Text('3. AnimationController', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Center(
          child: RotationTransition(
            turns: _putar,
            child: Icon(Icons.settings, size: 64, color: warna.primary),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_putar.isAnimating) {
              _putar.stop();
            } else {
              _putar.repeat();
            }
            setState(() {});
          },
          child: Text(_putar.isAnimating ? 'Berhenti' : 'Putar'),
        ),
        const Divider(),
        Text('4. AnimatedOpacity', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Center(
          child: AnimatedOpacity(
            opacity: _terlihat ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 400),
            child: Card(
              color: warna.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: warna.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Text(
                      'Kartu animasi',
                      style: tema.textTheme.titleMedium?.copyWith(
                        color: warna.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _terlihat = !_terlihat),
          child: Text(_terlihat ? 'Sembunyikan kartu' : 'Tampilkan kartu'),
        ),
      ],
    );
  }
}

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  static const _halaman = [
    BerandaTab(),
    AnimasiTab(),
    PengaturanTab(),
  ];

  static const _judul = ['Beranda', 'Animasi', 'Pengaturan'];

  void _pilihTab(int index) {
    setState(() => _index = index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Praktikum 6',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Beranda'),
                selected: _index == 0,
                onTap: () => _pilihTab(0),
              ),
              ListTile(
                leading: const Icon(Icons.animation),
                title: const Text('Animasi'),
                selected: _index == 1,
                onTap: () => _pilihTab(1),
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Pengaturan'),
                selected: _index == 2,
                onTap: () => _pilihTab(2),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.animation),
            label: 'Animasi',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: const Center(
        child: Text('404 - Halaman tidak ditemukan'),
      ),
    );
  }
}