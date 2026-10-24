import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;

  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'nama': nama,
    'jumlah': jumlah,
    'kategori': kategori,
    'tanggal': tanggal,
  };

  factory Pengeluaran.fromMap(Map<String, Object?> m) => Pengeluaran(
    id: m['id'] as int,
    nama: m['nama'] as String,
    jumlah: m['jumlah'] as int,
    kategori: m['kategori'] as String,
    tanggal: m['tanggal'] as String,
  );
}

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = p.join(await getDatabasesPath(), 'pengeluaran.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE pengeluaran('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'nama TEXT NOT NULL, '
              'jumlah INTEGER NOT NULL, '
              'kategori TEXT NOT NULL, '
              'tanggal TEXT NOT NULL)',
        );
      },
    );

    return _db!;
  }

  static Future<int> tambah(Pengeluaran p) async {
    final db = await database;
    return db.insert('pengeluaran', p.toMap());
  }

  static Future<List<Pengeluaran>> semua() async {
    final db = await database;
    final rows = await db.query(
      'pengeluaran',
      orderBy: 'id DESC',
    );
    return rows.map(Pengeluaran.fromMap).toList();
  }

  static Future<int> ubah(Pengeluaran p) async {
    final db = await database;
    return db.update(
      'pengeluaran',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    return db.delete(
      'pengeluaran',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatat Pengeluaran',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const PengeluaranPage(),
    );
  }
}

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  late Future<List<Pengeluaran>> _future;
  String _kategoriFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _muat();
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final prefs = await SharedPreferences.getInstance();
    final kategori = prefs.getString('kategoriFilter') ?? 'Semua';

    if (!mounted) return;

    setState(() {
      _kategoriFilter = kategori;
    });
  }

  void _muat() {
    setState(() {
      _future = DbHelper.semua();
    });
  }

  Future<void> _simpanFilter(String kategori) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kategoriFilter', kategori);

    if (!mounted) return;

    setState(() {
      _kategoriFilter = kategori;
    });
  }

  Future<void> _buka([Pengeluaran? pengeluaran]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengeluaranPage(
          pengeluaran: pengeluaran,
        ),
      ),
    );

    if (!mounted) return;
    _muat();
  }

  Future<void> _hapus(Pengeluaran pengeluaran) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Hapus pengeluaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await DbHelper.hapus(pengeluaran.id!);
      _muat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran Saya'),
      ),
      body: FutureBuilder<List<Pengeluaran>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Galat: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;

          final dataFilter = _kategoriFilter == 'Semua'
              ? data
              : data
              .where(
                (p) => p.kategori == _kategoriFilter,
          )
              .toList();

          final total = dataFilter.fold<int>(
            0,
                (total, p) => total + p.jumlah,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Total Pengeluaran',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp $total',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    const Text('Kategori:'),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _kategoriFilter,
                      items: const [
                        DropdownMenuItem(
                          value: 'Semua',
                          child: Text('Semua'),
                        ),
                        DropdownMenuItem(
                          value: 'Makanan',
                          child: Text('Makanan'),
                        ),
                        DropdownMenuItem(
                          value: 'Transportasi',
                          child: Text('Transportasi'),
                        ),
                        DropdownMenuItem(
                          value: 'Belanja',
                          child: Text('Belanja'),
                        ),
                        DropdownMenuItem(
                          value: 'Lainnya',
                          child: Text('Lainnya'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _simpanFilter(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: dataFilter.isEmpty
                    ? const Center(
                  child: Text(
                    'Belum ada pengeluaran',
                  ),
                )
                    : ListView.builder(
                  itemCount: dataFilter.length,
                  itemBuilder: (context, i) {
                    final p = dataFilter[i];

                    return ListTile(
                      title: Text(p.nama),
                      subtitle: Text(
                        '${p.kategori} • ${p.tanggal}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Rp ${p.jumlah}'),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                            ),
                            onPressed: () => _hapus(p),
                          ),
                        ],
                      ),
                      onTap: () => _buka(p),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class FormPengeluaranPage extends StatefulWidget {
  final Pengeluaran? pengeluaran;

  const FormPengeluaranPage({
    super.key,
    this.pengeluaran,
  });

  @override
  State<FormPengeluaranPage> createState() =>
      _FormPengeluaranPageState();
}

class _FormPengeluaranPageState
    extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nama;
  late final TextEditingController _jumlah;
  late final TextEditingController _tanggal;

  String? _kategori;

  @override
  void initState() {
    super.initState();

    _nama = TextEditingController(
      text: widget.pengeluaran?.nama ?? '',
    );

    _jumlah = TextEditingController(
      text: widget.pengeluaran?.jumlah.toString() ?? '',
    );

    _tanggal = TextEditingController(
      text: widget.pengeluaran?.tanggal ??
          DateTime.now().toString().substring(0, 10),
    );

    _kategori = widget.pengeluaran?.kategori;
  }

  @override
  void dispose() {
    _nama.dispose();
    _jumlah.dispose();
    _tanggal.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final p = Pengeluaran(
      id: widget.pengeluaran?.id,
      nama: _nama.text.trim(),
      jumlah: int.parse(_jumlah.text.trim()),
      kategori: _kategori!,
      tanggal: _tanggal.text.trim(),
    );

    if (widget.pengeluaran == null) {
      await DbHelper.tambah(p);
    } else {
      await DbHelper.ubah(p);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.pengeluaran == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          baru
              ? 'Pengeluaran Baru'
              : 'Ubah Pengeluaran',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nama,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty)
                  ? 'Nama wajib diisi'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jumlah,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }

                final jumlah = int.tryParse(
                  v.trim(),
                );

                if (jumlah == null) {
                  return 'Jumlah harus berupa angka';
                }

                if (jumlah <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue : _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Makanan',
                  child: Text('Makanan'),
                ),
                DropdownMenuItem(
                  value: 'Transportasi',
                  child: Text('Transportasi'),
                ),
                DropdownMenuItem(
                  value: 'Belanja',
                  child: Text('Belanja'),
                ),
                DropdownMenuItem(
                  value: 'Lainnya',
                  child: Text('Lainnya'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _kategori = value;
                });
              },
              validator: (v) =>
              v == null ? 'Kategori wajib dipilih' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tanggal,
              decoration: const InputDecoration(
                labelText: 'Tanggal',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty)
                  ? 'Tanggal wajib diisi'
                  : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _simpan,
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}