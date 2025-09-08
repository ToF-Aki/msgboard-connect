import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import '../services/message_service.dart';
import '../widgets/floating_message_card.dart';
import '../widgets/message_card.dart';
import 'post_message_screen.dart';

class UserViewScreen extends StatefulWidget {
  const UserViewScreen({super.key});

  @override
  State<UserViewScreen> createState() => _UserViewScreenState();
}

class _UserViewScreenState extends State<UserViewScreen>
    with TickerProviderStateMixin {
  List<Widget> _floatingCards = [];
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  String? _backgroundImagePath;
  Uint8List? _backgroundImageBytes;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _backgroundController.repeat();
    _startFloatingAnimation();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _startFloatingAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createFloatingCards();
    });
  }

  void _createFloatingCards() {
    final messageService = Provider.of<MessageService>(context, listen: false);
    final messages = messageService.messages;
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      _floatingCards = messages.asMap().entries.map((entry) {
        final index = entry.key;
        final message = entry.value;
        
        return FloatingMessageCard(
          message: message,
          index: index,
          screenSize: screenSize,
          onTap: () {
            // メッセージ詳細を表示
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Stack(
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ),
                    Center(
                      child: MessageCard(
                        message: message,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      right: 50,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NEC Solution Innovators\n50周年記念メッセージ',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        automaticallyImplyLeading: false, // 戻るボタンを非表示
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: _backgroundImagePath != null
              ? DecorationImage(
                  image: kIsWeb && _backgroundImageBytes != null
                      ? MemoryImage(_backgroundImageBytes!)
                      : FileImage(File(_backgroundImagePath!)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                )
              : null,
          gradient: _backgroundImagePath == null
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  ],
                )
              : null,
        ),
        child: Stack(
          children: [
            // 背景アニメーション（画像がない場合のみ）
            if (_backgroundImagePath == null)
              AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: screenSize.height * 0.1 * _backgroundAnimation.value,
                    left: 0,
                    right: 0,
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.celebration,
                        size: 100,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            // 浮遊メッセージカード（ループ設定）
            ..._floatingCards,
            // 投稿ボタン
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PostMessageScreen(),
                    ),
                  ).then((_) {
                    _startFloatingAnimation();
                  });
                },
                tooltip: '新しいメッセージを投稿',
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
