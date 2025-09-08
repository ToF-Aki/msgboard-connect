import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/message_service.dart';
import '../widgets/floating_message_card.dart';
import '../widgets/message_popup.dart';
import 'post_message_screen.dart';

class FloatingViewScreen extends StatefulWidget {
  const FloatingViewScreen({super.key});

  @override
  State<FloatingViewScreen> createState() => _FloatingViewScreenState();
}

class _FloatingViewScreenState extends State<FloatingViewScreen>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  List<Widget> _floatingCards = [];
  String? _backgroundImagePath;
  Uint8List? _backgroundImageBytes;
  bool _isImagePickerOpen = false;

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
    
    if (messages.isEmpty) return;

    setState(() {
      _floatingCards.clear();
      for (int i = 0; i < messages.length; i++) {
        _floatingCards.add(
          FloatingMessageCard(
            message: messages[i],
            screenSize: screenSize,
            index: i,
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

  Future<void> _pickBackgroundImage() async {
    if (_isImagePickerOpen) return;
    
    setState(() {
      _isImagePickerOpen = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (kIsWeb) {
          // Web用: bytesを使用
          setState(() {
            _backgroundImagePath = 'web_image'; // フラグとして使用
            _backgroundImageBytes = file.bytes;
          });
        } else {
          // デスクトップ用: pathを使用
          setState(() {
            _backgroundImagePath = file.path;
            _backgroundImageBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('画像の選択中にエラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isImagePickerOpen = false;
      });
    }
  }

  void _removeBackgroundImage() {
    setState(() {
      _backgroundImagePath = null;
      _backgroundImageBytes = null;
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
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _isImagePickerOpen ? null : _pickBackgroundImage,
            tooltip: '背景画像を設定',
          ),
          if (_backgroundImagePath != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _removeBackgroundImage,
              tooltip: '背景画像を削除',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _startFloatingAnimation();
            },
            tooltip: 'アニメーション再開',
          ),
          IconButton(
            icon: const Icon(Icons.loop),
            onPressed: () {
              // ループ状態を切り替える（将来的な機能拡張用）
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ループ機能が有効です'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'ループ機能',
          ),
        ],
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
            // 浮遊メッセージカード
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
            // 背景画像設定ガイド
            if (_backgroundImagePath == null)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '右上の画像アイコンで\n背景画像を設定できます',
                    style: GoogleFonts.notoSansJp(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
