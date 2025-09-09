import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/message_service.dart';
import 'screens/home_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/user_view_screen.dart';
import 'screens/user_screen.dart';
import 'screens/post_message_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MessageService(),
      child: MaterialApp(
        title: 'NEC Solution Innovators 50周年記念メッセージ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2), // NECブルー
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        home: const UserScreen(), // デフォルトでユーザー画面に遷移
        routes: {
          '/admin': (context) => const AdminScreen(),
          '/user-view': (context) => const UserViewScreen(),
          '/user': (context) => const UserScreen(),
          '/post': (context) => const PostMessageScreen(),
          '/home': (context) => const HomeScreen(), // 管理者用ホーム画面
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
