import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/siswa.dart';
import '../services/supabase_service.dart';

class SiswaFormPage extends StatefulWidget {
  final Siswa? siswa;
  const SiswaFormPage({super.key, this.siswa});

  @override
  State<SiswaFormPage> createState() => _SiswaFormPageState();
}

class _SiswaFormPageState extends State<SiswaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nisn = TextEditingController();
  final _nis = TextEditingController();
  final _nama = TextEditingController();
  final _tmpLahir = TextEditingController();
  final _tglLahir = TextEditingController();
  final _alamat = TextEditingController();
  final _telp = TextEditingController();
  String _jk = 'L';
  String? _kelas;
  String? _jurusan;
  File? _foto;
  String? _fotoUrl;
  bool _loading = false;

  final _listKelas = ['X', 'XI', 'XII'];
  final _listJurusan = ['Analis Kimia', 'Farmasi', 'PPLG'];

  bool get _isEdit => widget.siswa != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final s = widget.siswa!;
      _nisn.text = s.nisn;
      _nis.text = s.nis;
      _nama.text = s.namaSiswa;
      _tmpLahir.text = s.tempatLahir;
      _tglLahir.text = s.tanggalLahir;
      _alamat.text = s.alamat;
      _telp.text = s.noTelepon;
      _kelas = s.kelas;
      _jurusan = s.jurusan;
      _jk = s.jenisKelamin;
      _fotoUrl = s.fotoUrl;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nisn,
      _nis,
      _nama,
      _tmpLahir,
      _tglLahir,
      _alamat,
      _telp,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _foto = File(picked.path));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _tglLahir.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      String? url = _fotoUrl;
      if (_foto != null) {
        url = await SupabaseService.uploadFoto(
          _foto!,
          'siswa_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      final s = Siswa(
        nisn: _nisn.text,
        nis: _nis.text,
        namaSiswa: _nama.text,
        tempatLahir: _tmpLahir.text,
        tanggalLahir: _tglLahir.text,
        jenisKelamin: _jk,
        alamat: _alamat.text,
        noTelepon: _telp.text,
        kelas: _kelas!,
        jurusan: _jurusan!,
        fotoUrl: url,
      );

      if (_isEdit) {
        await SupabaseService.updateSiswa(widget.siswa!.id!, s);
      } else {
        await SupabaseService.addSiswa(s);
      }

      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Berhasil update' : 'Data siswa berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Siswa' : 'Tambah Siswa'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: _foto != null ? FileImage(_foto!) : null,
                  child: _foto == null
                      ? (_fotoUrl != null && _fotoUrl!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  _fotoUrl!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.camera_alt,
                                color: Colors.blue.shade700,
                              ))
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              _numField(_nisn, 'NISN', 12),
              _numField(_nis, 'NIS', 12),
              _field(_nama, 'Nama Siswa'),
              _field(_tmpLahir, 'Tempat Lahir'),
              GestureDetector(
                onTap: _pickDate,
                child: AbsorbPointer(child: _field(_tglLahir, 'Tanggal Lahir')),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Laki-laki'),
                      value: 'L',
                      groupValue: _jk,
                      onChanged: (v) => setState(() => _jk = v!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Perempuan'),
                      value: 'P',
                      groupValue: _jk,
                      onChanged: (v) => setState(() => _jk = v!),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              _field(_alamat, 'Alamat'),
              _numField(_telp, 'No. Telepon', 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: _kelas,
                  decoration: const InputDecoration(
                    labelText: 'Kelas',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _listKelas
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (v) => setState(() => _kelas = v),
                  validator: (v) => v == null ? 'Kelas wajib dipilih' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<String>(
                  value: _jurusan,
                  decoration: const InputDecoration(
                    labelText: 'Jurusan',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _listJurusan
                      .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                      .toList(),
                  onChanged: (v) => setState(() => _jurusan = v),
                  validator: (v) => v == null ? 'Jurusan wajib dipilih' : null,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEdit ? 'UPDATE' : 'SIMPAN',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: (v) => v == null || v.isEmpty ? '$label wajib diisi' : null,
      ),
    );
  }

  Widget _numField(TextEditingController c, String label, int max) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        maxLength: max,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          counterText: '',
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return '$label wajib diisi';
          if (!RegExp(r'^[0-9]+$').hasMatch(v)) return '$label hanya boleh angka';
          return null;
        },
      ),
    );
  }
}
