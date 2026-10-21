import 'package:flutter/material.dart';
import '../models/siswa.dart';
import '../services/supabase_service.dart';
import 'siswa_form_page.dart';
import 'siswa_detail_page.dart';

class SiswaListPage extends StatefulWidget {
  const SiswaListPage({super.key});

  @override
  State<SiswaListPage> createState() => _SiswaListPageState();
}

class _SiswaListPageState extends State<SiswaListPage> {
  List<Siswa> _list = [];
  bool _loading = true;
  String _search = '';
  String _kelas = 'Semua Kelas';
  List<String> _daftarKelas = ['Semua Kelas'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await SupabaseService.getSiswa(search: _search, kelas: _kelas);
    final kelas = await SupabaseService.getDaftarKelas();
    setState(() {
      _list = data;
      _daftarKelas = kelas;
      _loading = false;
    });
  }

  Future<void> _delete(Siswa s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus'),
        content: Text('Hapus ${s.namaSiswa}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await SupabaseService.deleteSiswa(s.id!);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      _search = v;
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _kelas,
                    isDense: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    items: _daftarKelas.map((k) => DropdownMenuItem(value: k, child: Text(k, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) {
                      _kelas = v!;
                      _load();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _list.isEmpty
                    ? const Center(child: Text('Tidak ada data'))
                    : ListView.separated(
                        itemCount: _list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final s = _list[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: s.fotoUrl != null && s.fotoUrl!.isNotEmpty
                                  ? ClipOval(child: Image.network(s.fotoUrl!, width: 40, height: 40, fit: BoxFit.cover))
                                  : Text(s.namaSiswa[0].toUpperCase(), style: TextStyle(color: Colors.blue.shade700)),
                            ),
                            title: GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SiswaDetailPage(siswa: s))),
                              child: Text(s.namaSiswa, style: const TextStyle(fontWeight: FontWeight.w500)),
                            ),
                            subtitle: Text('${s.nisn} • ${s.kelas} • ${s.jurusan}'),
                            trailing: PopupMenuButton(
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Hapus', style: TextStyle(color: Colors.red))),
                              ],
                              onSelected: (v) async {
                                if (v == 'edit') {
                                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => SiswaFormPage(siswa: s)));
                                  if (result == true) _load();
                                } else if (v == 'delete') {
                                  _delete(s);
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SiswaFormPage()));
          if (result == true) _load();
        },
      ),
    );
  }
}
