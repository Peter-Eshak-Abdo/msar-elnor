import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/blocker_provider.dart';
import 'services/blocker_channel.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for offline-first persistence
  await Hive.initFlutter();

  // Initialize Native MethodChannel listener
  BlockerChannel.initialize();

  runApp(const MsarElnorApp());
}

class MsarElnorApp extends StatelessWidget {
  const MsarElnorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BlockerProvider()..init()),
      ],
      child: MaterialApp(
        title: 'مسار النور',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF3B82F6),
          scaffoldBackgroundColor: const Color(0xFF090D16),
          fontFamily: 'Roboto',
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3B82F6),
            secondary: Color(0xFFF59E0B),
            surface: Color(0xFF0F172A),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
