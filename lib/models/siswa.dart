class Siswa {
  final String? id;
  final String nisn;
  final String nis;
  final String namaSiswa;
  final String tempatLahir;
  final String tanggalLahir; // format yyyy-MM-dd
  final String jenisKelamin; // 'L' atau 'P'
  final String alamat;
  final String noTelepon;
  final String kelas;
  final String jurusan;
  final String? fotoUrl;

  Siswa({
    this.id,
    required this.nisn,
    required this.nis,
    required this.namaSiswa,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.jenisKelamin,
    required this.alamat,
    required this.noTelepon,
    required this.kelas,
    required this.jurusan,
    this.fotoUrl,
  });

  factory Siswa.fromMap(Map<String, dynamic> map) {
    return Siswa(
      id: map['id']?.toString(),
      nisn: map['nisn'] ?? '',
      nis: map['nis'] ?? '',
      namaSiswa: map['nama_siswa'] ?? '',
      tempatLahir: map['tempat_lahir'] ?? '',
      tanggalLahir: map['tanggal_lahir'] ?? '',
      jenisKelamin: map['jenis_kelamin'] ?? 'L',
      alamat: map['alamat'] ?? '',
      noTelepon: map['no_telepon'] ?? '',
      kelas: map['kelas'] ?? '',
      jurusan: map['jurusan'] ?? '',
      fotoUrl: map['foto_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nisn': nisn,
      'nis': nis,
      'nama_siswa': namaSiswa,
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': tanggalLahir,
      'jenis_kelamin': jenisKelamin,
      'alamat': alamat,
      'no_telepon': noTelepon,
      'kelas': kelas,
      'jurusan': jurusan,
      'foto_url': fotoUrl,
    };
  }
}
