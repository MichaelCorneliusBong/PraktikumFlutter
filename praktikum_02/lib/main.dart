import 'package:flutter/material.dart';

class Kontak {
  final String nama;
  final String telepon;
  final String email;

  const Kontak(this.nama, this.telepon, this.email);
}

const daftarKontak = [
  Kontak('David Yehezkiel', '081234567801', 'david.yehezkiel@email.com'),
  Kontak('Andrew Novan Then', '082345678912', 'andrew.novan@email.com'),
  Kontak('Firaas Ferdinal', '083456789123', 'firaas.ferdinal@email.com'),
  Kontak('Ilham Firmansyah', '084567891234', 'ilham.firmansyah@email.com'),
  Kontak('Muhammad Aditya', '085678912345', 'muhammad.aditya@email.com'),
  Kontak('Jonathan Ridwan', '086789123456', 'jonathan.ridwan@email.com'),
];

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Kontak',
      theme: ThemeData(colorSchemeSeed: Colors.yellow, useMaterial3: true),
      home: const KontakPage(),
    );
  }
}

class KontakPage extends StatelessWidget {
  const KontakPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kontak')),
      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final kontak = daftarKontak[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(kontak.nama[0]),
            ),
            title: Text(kontak.nama),
            subtitle: Text(kontak.telepon),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailKontakPage(kontak: kontak),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DetailKontakPage extends StatelessWidget {
  final Kontak kontak;

  const DetailKontakPage({
    super.key,
    required this.kontak,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Kontak')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kontak.nama,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(kontak.telepon),
            const SizedBox(height: 8),
            Text(kontak.email),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}