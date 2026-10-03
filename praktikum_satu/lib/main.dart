import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kartu Perkenalan',
      home: const KartuPerkenalan(),
    );
  }
}

class KartuPerkenalan extends StatelessWidget {
  const KartuPerkenalan({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kartu Perkenalan'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 150, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'Michael Cornelius Bong',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 12),
            const Text(
              'NIM: 20240801004',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 6),
            const Text(
              'Jurusan: Teknik Informatika',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hobi: Gaming & Music Listening',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
