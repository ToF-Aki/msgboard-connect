import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/message_service.dart';
import '../widgets/floating_message_card.dart';
import 'post_message_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _showInstructions = true;

  @override
  void initState() {
    super.initState();
    // 3秒後に説明を自動で非表示にする
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showInstructions = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MessageService>(
        builder: (context, messageService, child) {
          return Stack(
            children: [
              // 背景画像またはデフォルト背景
              Container(
                decoration: BoxDecoration(
                  image: messageService.backgroundImage != null || messageService.backgroundImagePath != null
                      ? DecorationImage(
                          image: kIsWeb && messageService.backgroundImage != null
                              ? MemoryImage(messageService.backgroundImage!)
                              : messageService.backgroundImagePath != null && messageService.backgroundImagePath != 'web_image'
                                  ? FileImage(File(messageService.backgroundImagePath!)) as ImageProvider
                                  : MemoryImage(messageService.backgroundImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  gradient: messageService.backgroundImage == null && messageService.backgroundImagePath == null
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFE3F2FD),
                            Color(0xFFBBDEFB),
                          ],
                        )
                      : null,
                ),
                child: Stack(
                  children: [
                    // 浮遊アニメーション
                    ...messageService.messages.asMap().entries.map((entry) {
                      final index = entry.key;
                      final message = entry.value;
                      return FloatingMessageCard(
                        message: message,
                        index: index,
                        screenSize: MediaQuery.of(context).size,
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              // 投稿方法の説明（デザインに配慮した表示）
              if (_showInstructions)
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: AnimatedOpacity(
                    opacity: _showInstructions ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'メッセージ投稿方法',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showInstructions = false;
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '右下の＋ボタンをタップして、\nあなたのメッセージを投稿できます！',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostMessageScreen(),
            ),
          );
          
          // 投稿完了後、説明を再表示
          if (result == true) {
            setState(() {
              _showInstructions = true;
            });
            // 3秒後に再び非表示
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _showInstructions = false;
                });
              }
            });
          }
        },
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
