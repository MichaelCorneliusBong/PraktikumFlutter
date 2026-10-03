import 'package:flutter/material.dart';

class Makanan {
  final String nama;
  final int harga;
  final String deskripsi;
  const Makanan(this.nama, this.harga, this.deskripsi);
}

const daftarMenu = [
  Makanan('Nasi Goreng', 15000, 'Nasi goreng pedas dengan ayam dan kerupuk.'),
  Makanan('Mie Ayam', 12000, 'Mie kenyal dengan ayam dadu.'),
  Makanan('Es Teh', 4000, 'Teh dengan pilihan tawar atau manis.'),
  Makanan('Ayam Bakar', 20000, 'Ayam bakar dengan sambal pedas.'),
  Makanan('Burger', 18000, 'Burger dengan daging grill pilihan.'),
  Makanan('Sate Kambing', 13000, 'Sate kambing dengan bumbu yang khas.'),
  Makanan('Es Cincau', 5000, 'Cincau yang dilengkapi jeli yang kenyal.'),
];

String formatRupiah(int angka) {
  final ribuan = angka ~/ 1000;
  final sisa = angka % 1000;
  return 'Rp $ribuan.${sisa.toString().padLeft(3, '0')}';
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 2',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Menu')),
      body: ListView.builder(
        itemCount: daftarMenu.length,
        itemBuilder: (context, index) {
          final item = daftarMenu[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.yellow.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.restaurant),
              title: Text(item.nama),
              subtitle: Text(formatRupiah(item.harga)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPage(makanan: item)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final Makanan makanan;

  const DetailPage({super.key, required this.makanan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(makanan.nama)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restaurant_menu, size: 80),
              const SizedBox(height: 16),
              Text(makanan.nama, style: const TextStyle(fontSize: 24)),
              Text(formatRupiah(makanan.harga)),
              const SizedBox(height: 12),
              Text(makanan.deskripsi),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
