import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:ui';
import '../services/message_service.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';
import 'fullscreen_view_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _titleController = TextEditingController();
  String? _backgroundImagePath;
  Uint8List? _backgroundImageBytes;
  bool _isImagePickerOpen = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = 'NEC Solution Innovators 50周年記念メッセージ';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
          // Web環境
          if (file.bytes != null) {
            setState(() {
              _backgroundImageBytes = file.bytes;
              _backgroundImagePath = 'web_image';
            });
          }
        } else {
          // デスクトップ環境
          if (file.path != null) {
            setState(() {
              _backgroundImagePath = file.path;
              _backgroundImageBytes = null;
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('画像の選択に失敗しました: $e')),
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

  void _showDeleteDialog(Message message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('メッセージを削除'),
          content: Text('「${message.content}」を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<MessageService>(context, listen: false)
                    .deleteMessage(message.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('メッセージを削除しました')),
                );
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理画面'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/user');
            },
            tooltip: 'ユーザー画面',
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullscreenViewScreen(
                    title: _titleController.text,
                    backgroundImagePath: _backgroundImagePath,
                    backgroundImageBytes: _backgroundImageBytes,
                  ),
                ),
              );
            },
            tooltip: '全画面表示',
          ),
        ],
      ),
      body: Column(
        children: [
          // 設定パネル
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '設定',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // タイトル設定
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'アプリタイトル',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // 背景画像設定
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '背景画像: ${_backgroundImagePath != null ? "設定済み" : "未設定"}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
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
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        final messageService = Provider.of<MessageService>(context, listen: false);
                        messageService.setAppTitle(_titleController.text);
                        if (_backgroundImageBytes != null) {
                          messageService.setBackgroundImage(_backgroundImageBytes!);
                        } else if (_backgroundImagePath != null) {
                          messageService.setBackgroundImagePath(_backgroundImagePath!);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('設定を保存しました')),
                        );
                      },
                      tooltip: '設定を保存',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // メッセージリスト
          Expanded(
            child: Consumer<MessageService>(
              builder: (context, messageService, child) {
                final messages = messageService.messages;
                
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'メッセージがありません',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          message.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('投稿者: ${message.author}'),
                            Text('投稿日時: ${_formatDateTime(message.createdAt)}'),
                            Text('タイプ: ${message.type == MessageType.challenge ? "挑戦" : "会社"}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showDeleteDialog(message),
                          tooltip: '削除',
                        ),
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
