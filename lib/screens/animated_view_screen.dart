import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/message_service.dart';
import '../widgets/animated_message_card.dart';
import '../widgets/message_popup.dart';
import 'post_message_screen.dart';

class AnimatedViewScreen extends StatefulWidget {
  const AnimatedViewScreen({super.key});

  @override
  State<AnimatedViewScreen> createState() => _AnimatedViewScreenState();
}

class _AnimatedViewScreenState extends State<AnimatedViewScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  int _currentMessageIndex = 0;
  List<Widget> _animatedCards = [];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 30),
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
    _startMessageAnimation();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  void _startMessageAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createAnimatedCards();
    });
  }

  void _createAnimatedCards() {
    final messageService = Provider.of<MessageService>(context, listen: false);
    final messages = messageService.messages;
    
    if (messages.isEmpty) return;

    final random = Random();
    final screenHeight = MediaQuery.of(context).size.height;
    final maxVerticalOffset = screenHeight * 0.4; // 画面の40%の範囲で分散

    setState(() {
      _animatedCards.clear();
      for (int i = 0; i < messages.length; i++) {
        // ランダムなY座標オフセットを生成（重なりを避けるため）
        final verticalOffset = (random.nextDouble() - 0.5) * maxVerticalOffset;
        
        _animatedCards.add(
          AnimatedMessageCard(
            message: messages[i],
            delay: Duration(milliseconds: 2000 + i * 1000), // 2秒で開始、1秒間隔
            animationDuration: const Duration(seconds: 15), // アニメーション時間を延長
            verticalOffset: verticalOffset,
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MessagePopup(message: messages[i]);
                },
              );
            },
          ),
        );
      }
    });
  }

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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _currentMessageIndex = 0;
              });
              _startMessageAnimation();
            },
            tooltip: 'アニメーション再開',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 背景アニメーション
            AnimatedBuilder(
              animation: _backgroundAnimation,
              builder: (context, child) {
                return Positioned(
                  top: MediaQuery.of(context).size.height * 0.1 * _backgroundAnimation.value,
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
            // メッセージカード
            ..._animatedCards,
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
                    // 投稿後にアニメーションを再開
                    _startMessageAnimation();
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
