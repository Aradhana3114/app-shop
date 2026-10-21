import 'package:flutter/material.dart';
import 'services/supabase_service.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const DataSiswa());
}

class DataSiswa extends StatelessWidget {
  const DataSiswa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uji Kompetensi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
