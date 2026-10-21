import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/siswa.dart';

// GANTI dua nilai di bawah ini dengan punya Project Supabase kamu.
// Ambil dari: Supabase Dashboard > Project Settings > API
const String supabaseUrl = 'https://uqapmzdxqtiupvvhknyj.supabase.co';
const String supabaseAnonKey = 'sb_publishable_AZng462EJoEKWOvN-BBiXw_U6FxVp72';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }

  // ---------- AUTH ----------
  static Future<String?> login(String username, String password) async {
    try {
      // Admin login memakai Supabase Auth. Username diperlakukan sebagai email.
      final email = username.contains('@') ? username : '$username@admin.local';
      await client.auth.signInWithPassword(email: email, password: password);
      return null; // null = sukses
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Login gagal. Periksa username/password Anda.';
    }
  }

  static Future<void> logout() async {
    await client.auth.signOut();
  }

  static bool get isLoggedIn => client.auth.currentSession != null;

  // ---------- SISWA CRUD ----------
  static Future<List<Siswa>> getSiswa({String? search, String? kelas}) async {
    var query = client.from('siswa').select();

    if (kelas != null && kelas != 'Semua Kelas') {
      query = query.eq('kelas', kelas);
    }
    if (search != null && search.trim().isNotEmpty) {
      query = query.or(
          'nama_siswa.ilike.%$search%,nis.ilike.%$search%,nisn.ilike.%$search%');
    }

    final data = await query.order('nama_siswa', ascending: true);
    return (data as List).map((e) => Siswa.fromMap(e)).toList();
  }

  static Future<String> addSiswa(Siswa siswa) async {
    final data = await client.from('siswa').insert(siswa.toMap()).select('id').single();
    return data['id'].toString();
  }

  static Future<void> updateSiswa(String id, Siswa siswa) async {
    await client.from('siswa').update(siswa.toMap()).eq('id', id);
  }

  static Future<void> deleteSiswa(String id) async {
    await client.from('siswa').delete().eq('id', id);
  }

  static Future<List<String>> getDaftarKelas() async {
    final data = await client.from('siswa').select('kelas');
    final set = <String>{};
    for (final row in data) {
      if (row['kelas'] != null && row['kelas'].toString().isNotEmpty) {
        set.add(row['kelas'].toString());
      }
    }
    final list = set.toList()..sort();
    return ['Semua Kelas', ...list];
  }

  // ---------- FOTO ----------
  static Future<String> uploadFoto(File file, String fileName) async {
    final bytes = await file.readAsBytes();
    await client.storage.from('foto-siswa').uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return client.storage.from('foto-siswa').getPublicUrl(fileName);
  }
}
