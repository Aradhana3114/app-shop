import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'login_page.dart';
import 'siswa_list_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _totalSiswa = 0;
  int _totalLaki = 0;
  int _totalPerempuan = 0;
  bool _loading = true;
  String _username = 'Admin';

  @override
  void initState() {
    super.initState();
    _getUsername();
    _load();
  }

  void _getUsername() {
    final email = SupabaseService.client.auth.currentUser?.email ?? '';
    if (email.contains('@')) {
      setState(() => _username = email.split('@')[0]);
    }
  }

  Future<void> _load() async {
    try {
      final siswa = await SupabaseService.getSiswa();
      final laki = siswa.where((s) => s.jenisKelamin == 'L').length;
      final perempuan = siswa.where((s) => s.jenisKelamin == 'P').length;
      setState(() {
        _totalSiswa = siswa.length;
        _totalLaki = laki;
        _totalPerempuan = perempuan;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await SupabaseService.logout();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Selamat Datang, $_username', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _infoBox('Siswa', '$_totalSiswa'),
                    const SizedBox(width: 12),
                    _infoBox('Laki-laki', '$_totalLaki'),
                    const SizedBox(width: 12),
                    _infoBox('Perempuan', '$_totalPerempuan'),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  tileColor: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  leading: Icon(Icons.school, color: Colors.blue.shade700),
                  title: const Text('Data Siswa'),
                  subtitle: const Text('Kelola data siswa'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SiswaListPage())),
                ),
              ],
            ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
