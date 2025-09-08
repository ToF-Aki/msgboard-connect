import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageService extends ChangeNotifier {
  List<Message> _messages = [];
  String _appTitle = 'NEC Solution Innovators 50周年記念メッセージ';
  String? _backgroundImagePath;
  Uint8List? _backgroundImageBytes;
  
  // サンプルデータを初期化
  MessageService() {
    _initializeSampleData();
  }

  List<Message> get messages => List.unmodifiable(_messages);
  String get appTitle => _appTitle;
  String? get backgroundImagePath => _backgroundImagePath;
  Uint8List? get backgroundImage => _backgroundImageBytes;

  // サンプルデータの初期化
  void _initializeSampleData() {
    _messages = [
      Message(
        id: '1',
        type: MessageType.challenge,
        content: 'AI技術を活用した革新的なソリューションの開発',
        author: 'たなちゃん',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        fontFamily: 'Noto Sans JP',
        textColor: null,
      ),
      Message(
        id: '2',
        type: MessageType.company,
        content: '技術で社会に貢献できる素晴らしい会社',
        author: 'さとうちゃん',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        fontFamily: 'ゴシック体',
        textColor: Colors.blue,
      ),
      Message(
        id: '3',
        type: MessageType.challenge,
        content: 'グローバルな視点でのプロジェクトマネジメント',
        author: 'すずきくん',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        fontFamily: '明朝体',
        textColor: Colors.green,
      ),
      Message(
        id: '4',
        type: MessageType.company,
        content: '仲間と共に成長できる最高の職場',
        author: 'たかはしさん',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        fontFamily: '手書き風',
        textColor: Colors.purple,
      ),
      Message(
        id: '5',
        type: MessageType.challenge,
        content: 'クリエイティブな発想で新しい価値を創造',
        author: 'やまださん',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        fontFamily: '和風文字',
        textColor: Colors.orange,
      ),
      Message(
        id: '6',
        type: MessageType.company,
        content: '夢と希望を与えてくれる素晴らしい場所',
        author: 'いとうさん',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        fontFamily: '可愛い文字',
        textColor: Colors.pink,
      ),
    ];
  }

  // メッセージを追加
  void addMessage(Message message) {
    _messages.insert(0, message);
    notifyListeners();
  }

  // メッセージを削除
  void deleteMessage(String id) {
    _messages.removeWhere((message) => message.id == id);
    notifyListeners();
  }

  // メッセージを更新
  void updateMessage(Message updatedMessage) {
    final index = _messages.indexWhere((message) => message.id == updatedMessage.id);
    if (index != -1) {
      _messages[index] = updatedMessage;
      notifyListeners();
    }
  }

  // IDでメッセージを取得
  Message? getMessageById(String id) {
    try {
      return _messages.firstWhere((message) => message.id == id);
    } catch (e) {
      return null;
    }
  }

  // 新しいIDを生成
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // アプリタイトルを設定
  void setAppTitle(String title) {
    _appTitle = title;
    notifyListeners();
  }

  // 背景画像パスを設定
  void setBackgroundImagePath(String path) {
    _backgroundImagePath = path;
    _backgroundImageBytes = null;
    notifyListeners();
  }

  // 背景画像バイトを設定
  void setBackgroundImage(Uint8List bytes) {
    _backgroundImageBytes = bytes;
    _backgroundImagePath = 'web_image';
    notifyListeners();
  }
}
