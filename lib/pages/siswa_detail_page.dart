import 'package:flutter/material.dart';
import '../models/siswa.dart';

class SiswaDetailPage extends StatelessWidget {
  final Siswa siswa;
  const SiswaDetailPage({super.key, required this.siswa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Siswa'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: siswa.fotoUrl != null && siswa.fotoUrl!.isNotEmpty
                ? CircleAvatar(radius: 50, backgroundImage: NetworkImage(siswa.fotoUrl!))
                : CircleAvatar(radius: 50, backgroundColor: Colors.blue.shade100, child: Text(siswa.namaSiswa[0].toUpperCase(), style: TextStyle(fontSize: 40, color: Colors.blue.shade700))),
          ),
          const SizedBox(height: 20),
          _row('NISN', siswa.nisn),
          _row('NIS', siswa.nis),
          _row('Nama', siswa.namaSiswa),
          _row('Kelas', siswa.kelas),
          _row('Jurusan', siswa.jurusan),
          _row('Tempat Lahir', siswa.tempatLahir),
          _row('Tanggal Lahir', siswa.tanggalLahir),
          _row('Alamat', siswa.alamat),
          _row('No. Telepon', siswa.noTelepon),
          _row('Jenis Kelamin', siswa.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan'),
          
        ],
      ),
    );
  }

  Widget _row(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(val)),
        ],
      ),
    );
  }
}
