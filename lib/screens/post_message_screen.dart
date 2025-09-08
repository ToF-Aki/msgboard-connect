import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import '../widgets/font_selector.dart';
import '../widgets/color_selector.dart';

class PostMessageScreen extends StatefulWidget {
  const PostMessageScreen({super.key});

  @override
  State<PostMessageScreen> createState() => _PostMessageScreenState();
}

class _PostMessageScreenState extends State<PostMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  MessageType _selectedType = MessageType.challenge;
  String? _selectedFont;
  Color? _selectedColor;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('50周年記念メッセージを投稿'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitMessage,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '投稿',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Card(
                color: const Color(0xFFFFE0B2),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'メッセージの種類を選択してください',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<MessageType>(
                              title: const Text('挑戦'),
                              subtitle: const Text('私がこれから挑戦することは、〇〇です！'),
                              value: MessageType.challenge,
                              groupValue: _selectedType,
                              onChanged: (MessageType? value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                              activeColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<MessageType>(
                              title: const Text('会社'),
                              subtitle: const Text('私にとって、NEC Solution Innovatorsは、〇〇です！'),
                              value: MessageType.company,
                              groupValue: _selectedType,
                              onChanged: (MessageType? value) {
                                setState(() {
                                  _selectedType = value!;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FontSelector(
                selectedFont: _selectedFont,
                onFontChanged: (font) {
                  setState(() {
                    _selectedFont = font;
                  });
                },
              ),
              const SizedBox(height: 16),
              ColorSelector(
                selectedColor: _selectedColor,
                onColorChanged: (color) {
                  setState(() {
                    _selectedColor = color;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: '〇〇の部分を入力してください *',
                  hintText: _selectedType == MessageType.challenge 
                      ? '例：AI技術を活用した革新的なソリューションの開発'
                      : '例：技術で社会に貢献できる素晴らしい会社',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '内容を入力してください';
                  }
                  if (value.trim().length < 5) {
                    return '内容は5文字以上で入力してください';
                  }
                  return null;
                },
                maxLines: 3,
                maxLength: 140,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'ニックネーム *',
                  hintText: '例：たなちゃん',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'ニックネームを入力してください';
                  }
                  if (value.trim().length < 2) {
                    return 'ニックネームは2文字以上で入力してください';
                  }
                  return null;
                },
                maxLength: 20,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitMessage,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_isSubmitting ? '投稿中...' : 'メッセージを投稿'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  void _submitMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final messageService = Provider.of<MessageService>(context, listen: false);
      
      final message = Message(
        id: messageService.generateId(),
        type: _selectedType,
        content: _contentController.text.trim(),
        author: _authorController.text.trim(),
        createdAt: DateTime.now(),
        fontFamily: _selectedFont,
        textColor: _selectedColor,
      );

      messageService.addMessage(message);

      if (mounted) {
        // 投稿後、統合ユーザー画面に戻る
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラーが発生しました: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
