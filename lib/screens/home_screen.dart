import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/message_service.dart';
import '../widgets/message_card.dart';
import '../widgets/message_popup.dart';
import 'post_message_screen.dart';
import 'animated_view_screen.dart';
import 'floating_view_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NEC Solution Innovators\n50周年記念メッセージ',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/user');
            },
            tooltip: 'ユーザー画面',
          ),
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.pushNamed(context, '/admin');
            },
            tooltip: '管理画面',
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnimatedViewScreen(),
                ),
              );
            },
            tooltip: 'スライドアニメーション',
          ),
          IconButton(
            icon: const Icon(Icons.flutter_dash),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FloatingViewScreen(),
                ),
              );
            },
            tooltip: '浮遊アニメーション',
          ),
        ],
      ),
      body: Consumer<MessageService>(
        builder: (context, messageService, child) {
          final messages = messageService.messages;
          
          if (messages.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.message_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'メッセージがありません',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '新しいメッセージを投稿してみましょう',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // 将来的にAPIからデータを再取得する処理を追加
              await Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageCard(
                  message: message,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return MessagePopup(message: message);
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostMessageScreen(),
            ),
          );
        },
        tooltip: '新しいメッセージを投稿',
        child: const Icon(Icons.add),
      ),
    );
  }


}
