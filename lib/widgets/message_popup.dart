import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/message.dart';
import 'message_card.dart';

class MessagePopup extends StatelessWidget {
  final Message message;

  const MessagePopup({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 300,
        ),
        child: Stack(
          children: [
            // 背景のブラー効果
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            // メッセージカード
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: MessageCard(
                  message: message,
                  onTap: null, // ポップアップ内ではタップ無効
                ),
              ),
            ),
            // 閉じるボタン
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
