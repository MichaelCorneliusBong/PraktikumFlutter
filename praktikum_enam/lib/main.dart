import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);
final daftarFavorit = ValueNotifier<Set<int>>(<int>{});

const List<Color> pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

class Wisata {
  final int id;
  final String nama;
  final String lokasi;
  final String deskripsi;
  final IconData ikon;

  const Wisata({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.deskripsi,
    required this.ikon,
  });
}

const daftarWisata = [
  Wisata(
    id: 1,
    nama: 'Candi Borobudur',
    lokasi: 'Magelang, Jawa Tengah',
    deskripsi:
        'Candi Buddha bersejarah dengan relief dan stupa yang menjadi salah satu tujuan wisata budaya Indonesia.',
    ikon: Icons.account_balance,
  ),
  Wisata(
    id: 2,
    nama: 'Raja Ampat',
    lokasi: 'Papua Barat Daya',
    deskripsi:
        'Kepulauan dengan perairan jernih, pulau-pulau karst, dan keanekaragaman kehidupan laut.',
    ikon: Icons.waves,
  ),
  Wisata(
    id: 3,
    nama: 'Gunung Bromo',
    lokasi: 'Jawa Timur',
    deskripsi:
        'Destinasi pegunungan yang dikenal dengan pemandangan kaldera dan matahari terbit.',
    ikon: Icons.terrain,
  ),
  Wisata(
    id: 4,
    nama: 'Danau Toba',
    lokasi: 'Sumatera Utara',
    deskripsi:
        'Danau vulkanik luas dengan Pulau Samosir dan pemandangan alam di sekitarnya.',
    ikon: Icons.water,
  ),
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
  final indeksWarna = (prefs.getInt('warnaTema') ?? 0)
      .clamp(0, pilihanWarna.length - 1)
      .toInt();

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
          title: 'Galeri Wisata Indonesia',
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
              final wisata = settings.arguments as Wisata;
              return MaterialPageRoute<void>(
                builder: (_) => DetailPage(wisata: wisata),
                settings: settings,
              );
            }
            return null;
          },
        );
      },
    );
  }
}

void ubahFavorit(Wisata wisata) {
  final favorit = Set<int>.from(daftarFavorit.value);
  if (!favorit.add(wisata.id)) {
    favorit.remove(wisata.id);
  }
  daftarFavorit.value = favorit;
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
    FavoritTab(),
    PengaturanTab(),
  ];

  static const _judul = [
    'Beranda',
    'Favorit',
    'Pengaturan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      body: IndexedStack(
        index: _index,
        children: _halaman,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() => _index = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
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

class BerandaTab extends StatefulWidget {
  const BerandaTab({super.key});

  @override
  State<BerandaTab> createState() => _BerandaTabState();
}

class _BerandaTabState extends State<BerandaTab>
    with SingleTickerProviderStateMixin {
  bool _besar = false;
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
        Text('Jelajahi Indonesia', style: tema.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Temukan destinasi wisata pilihan.',
          style: tema.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(_besar ? 24 : 16),
          decoration: BoxDecoration(
            color: warna.primaryContainer,
            borderRadius: BorderRadius.circular(_besar ? 28 : 16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.explore,
                size: _besar ? 42 : 32,
                color: warna.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mulai perjalananmu',
                  style: tema.textTheme.titleMedium?.copyWith(
                    color: warna.onPrimaryContainer,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _besar = !_besar),
                tooltip: 'Ubah tampilan kartu',
                icon: Icon(
                  _besar ? Icons.expand_less : Icons.expand_more,
                  color: warna.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: RotationTransition(
              turns: _putar,
              child: Icon(Icons.explore, color: warna.primary, size: 30),
            ),
            title: const Text('AnimationController'),
            subtitle: const Text('Contoh animasi eksplisit'),
            trailing: IconButton(
              tooltip: _putar.isAnimating ? 'Berhenti' : 'Putar',
              onPressed: () {
                if (_putar.isAnimating) {
                  _putar.stop();
                } else {
                  _putar.repeat();
                }
                setState(() {});
              },
              icon: Icon(
                _putar.isAnimating ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Destinasi pilihan', style: tema.textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final wisata in daftarWisata)
          KartuWisata(wisata: wisata, pakaiHero: true),
      ],
    );
  }
}

class FavoritTab extends StatelessWidget {
  const FavoritTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListenableBuilder(
      listenable: daftarFavorit,
      builder: (context, _) {
        final favorit = daftarWisata
            .where((wisata) => daftarFavorit.value.contains(wisata.id))
            .toList();

        if (favorit.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Belum ada destinasi favorit.\nBuka detail wisata untuk menambah favorit.',
                textAlign: TextAlign.center,
                style: tema.textTheme.bodyLarge,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorit.length,
          itemBuilder: (context, index) {
            return KartuWisata(wisata: favorit[index]);
          },
        );
      },
    );
  }
}

class KartuWisata extends StatelessWidget {
  final Wisata wisata;
  final bool pakaiHero;

  const KartuWisata({
    super.key,
    required this.wisata,
    this.pakaiHero = false,
  });

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    Widget ikon = CircleAvatar(
      backgroundColor: warna.secondaryContainer,
      child: Icon(wisata.ikon, color: warna.onSecondaryContainer),
    );

    if (pakaiHero) {
      ikon = Hero(tag: 'wisata-${wisata.id}', child: ikon);
    }

    return Card(
      child: ListTile(
        leading: ikon,
        title: Text(wisata.nama),
        subtitle: Text(wisata.lokasi),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detail',
            arguments: wisata,
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Wisata wisata;

  const DetailPage({super.key, required this.wisata});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(wisata.nama),
        actions: [
          ListenableBuilder(
            listenable: daftarFavorit,
            builder: (context, _) {
              final favorit = daftarFavorit.value.contains(wisata.id);
              return IconButton(
                tooltip: favorit ? 'Hapus dari favorit' : 'Tambah ke favorit',
                onPressed: () => ubahFavorit(wisata),
                icon: Icon(
                  favorit ? Icons.favorite : Icons.favorite_border,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Hero(
              tag: 'wisata-${wisata.id}',
              child: CircleAvatar(
                radius: 70,
                backgroundColor: warna.primaryContainer,
                child: Icon(
                  wisata.ikon,
                  size: 68,
                  color: warna.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            wisata.nama,
            textAlign: TextAlign.center,
            style: tema.textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            wisata.lokasi,
            textAlign: TextAlign.center,
            style: tema.textTheme.titleMedium?.copyWith(
              color: warna.primary,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                wisata.deskripsi,
                style: tema.textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  Future<void> _simpanMode(bool gelap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modeGelap', gelap);
  }

  Future<void> _simpanWarna(Color warna) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('warnaTema', pilihanWarna.indexOf(warna));
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warna = tema.colorScheme;

    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Tampilan', style: tema.textTheme.titleLarge),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (gelap) {
                themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light;
                _simpanMode(gelap);
              },
            ),
            const SizedBox(height: 16),
            Text('Warna tema', style: tema.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final pilihan in pilihanWarna)
                  InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      seedColor.value = pilihan;
                      _simpanWarna(pilihan);
                    },
                    child: CircleAvatar(
                      backgroundColor: pilihan,
                      child: seedColor.value == pilihan
                          ? Icon(Icons.check, color: warna.onPrimary)
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