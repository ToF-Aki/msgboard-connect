import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message.dart';

class MessageCard extends StatelessWidget {
  final Message message;
  final VoidCallback? onTap;

  const MessageCard({
    super.key,
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isChallenge = message.type == MessageType.challenge;
    final backgroundColor = isChallenge 
        ? const Color(0xFFFFE0B2) // ピーチ色（挑戦）
        : const Color(0xFFE3F2FD); // 水色（会社）
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(
                      text: message.type.template.split('〇〇')[0].trim(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: '\n' + message.content + '\n',
                      style: _getFontStyle(message.fontFamily).copyWith(
                        color: message.textColor ?? Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: message.type.template.split('〇〇')[1].trim(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    message.author,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDateTime(message.createdAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _getFontStyle(String? fontFamily) {
    switch (fontFamily) {
      case 'Noto Sans JP':
        return GoogleFonts.notoSansJp();
      case 'ゴシック体':
        return GoogleFonts.notoSansJp(fontWeight: FontWeight.w500);
      case '明朝体':
        return GoogleFonts.notoSerifJp();
      case '手書き風':
        return GoogleFonts.kleeOne();
      case '和風文字':
        return GoogleFonts.yujiSyuku();
      case '可愛い文字':
        return GoogleFonts.yuseiMagic();
      default:
        return const TextStyle();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return '今';
    }
  }
}
