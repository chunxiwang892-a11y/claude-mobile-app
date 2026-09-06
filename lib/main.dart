import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/websocket_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化通知服务
  await NotificationService().init();

  runApp(const ClaudeCodeApp());
}

class ClaudeCodeApp extends StatelessWidget {
  const ClaudeCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WebSocketService()),
      ],
      child: MaterialApp(
        title: 'Claude Code Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B35),
            brightness: Brightness.dark,
            background: const Color(0xFF1A1A1A),
            surface: const Color(0xFF2D2D2D),
          ),
          scaffoldBackgroundColor: const Color(0xFF1A1A1A),
          fontFamily: 'SF Pro Display',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
