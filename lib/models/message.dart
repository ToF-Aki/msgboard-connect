import 'package:flutter/material.dart';

enum MessageType {
  challenge('私がこれから挑戦することは、〇〇です！'),
  company('私にとって、NEC Solution Innovatorsは、〇〇です！');

  const MessageType(this.template);
  final String template;
}

class Message {
  final String id;
  final MessageType type;
  final String content; // 〇〇の部分
  final String author;
  final DateTime createdAt;
  final String? fontFamily; // フォントファミリー
  final Color? textColor; // テキスト色

  Message({
    required this.id,
    required this.type,
    required this.content,
    required this.author,
    required this.createdAt,
    this.fontFamily,
    this.textColor,
  });

  // JSONからMessageオブジェクトを作成
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      content: json['content'] as String,
      author: json['author'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fontFamily: json['fontFamily'] as String?,
      textColor: json['textColor'] != null 
          ? Color(json['textColor'] as int)
          : null,
    );
  }

  // MessageオブジェクトをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'fontFamily': fontFamily,
      'textColor': textColor?.value,
    };
  }

  // コピーメソッド
  Message copyWith({
    String? id,
    MessageType? type,
    String? content,
    String? author,
    DateTime? createdAt,
    String? fontFamily,
    Color? textColor,
  }) {
    return Message(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      fontFamily: fontFamily ?? this.fontFamily,
      textColor: textColor ?? this.textColor,
    );
  }
}