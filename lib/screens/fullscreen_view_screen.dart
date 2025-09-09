import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import '../services/message_service.dart';
import '../widgets/floating_message_card.dart';

class FullscreenViewScreen extends StatefulWidget {
  final String title;
  final String? backgroundImagePath;
  final Uint8List? backgroundImageBytes;

  const FullscreenViewScreen({
    super.key,
    required this.title,
    this.backgroundImagePath,
    this.backgroundImageBytes,
  });

  @override
  State<FullscreenViewScreen> createState() => _FullscreenViewScreenState();
}

class _FullscreenViewScreenState extends State<FullscreenViewScreen> {
  List<Widget> _floatingCards = [];

  @override
  void initState() {
    super.initState();
    _startFloatingAnimation();
    _enterFullscreen();
  }

  void _enterFullscreen() {
    // ブラウザのフルスクリーンモードを有効にする
    if (kIsWeb) {
      // Webでフルスクリーンモードを有効にする
      _requestFullscreen();
    }
  }

  void _requestFullscreen() {
    // JavaScriptでフルスクリーンモードを有効にする
    // この機能はWebブラウザの制限により、ユーザーの操作が必要
  }

  void _toggleFullscreen() {
    if (kIsWeb) {
      // Webでフルスクリーンモードを切り替え
      _requestFullscreen();
    }
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
            // 全画面表示ではポップアップは表示しない
          },
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.green, // グリーンバック
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green, // グリーンバック
          image: widget.backgroundImagePath != null
              ? DecorationImage(
                  image: kIsWeb && widget.backgroundImageBytes != null
                      ? MemoryImage(widget.backgroundImageBytes!)
                      : FileImage(File(widget.backgroundImagePath!)),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.green.withOpacity(0.3), // グリーンバックに合わせる
                    BlendMode.multiply,
                  ),
                )
              : null,
        ),
        child: Stack(
          children: [
            // 浮遊メッセージカード（ループ設定）
            ..._floatingCards,
            
            // フルスクリーンボタン
            Positioned(
              top: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _toggleFullscreen,
                backgroundColor: Colors.black.withOpacity(0.7),
                child: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                ),
              ),
            ),
            
            // 終了ボタン
            Positioned(
              top: 20,
              left: 20,
              child: FloatingActionButton(
                onPressed: () => Navigator.of(context).pop(),
                backgroundColor: Colors.red.withOpacity(0.7),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
