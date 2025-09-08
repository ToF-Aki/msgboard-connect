import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSelector extends StatelessWidget {
  final String? selectedFont;
  final Function(String?) onFontChanged;

  const FontSelector({
    super.key,
    required this.selectedFont,
    required this.onFontChanged,
  });

  // 日本語対応フォントのリスト
  static Map<String, TextStyle> get availableFonts {
    return {
      'Noto Sans JP': GoogleFonts.notoSansJp(),
      'ゴシック体': GoogleFonts.notoSansJp(fontWeight: FontWeight.w500),
      '明朝体': GoogleFonts.notoSerifJp(),
      '手書き風': GoogleFonts.kleeOne(),
      '和風文字': GoogleFonts.yujiSyuku(),
      '可愛い文字': GoogleFonts.yuseiMagic(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'フォントを選択',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...availableFonts.entries.map((entry) {
          final fontName = entry.key;
          final fontStyle = entry.value;
          
          return RadioListTile<String>(
            title: Text(
              fontName,
              style: fontStyle.copyWith(fontSize: 16),
            ),
            subtitle: Text(
              'サンプルテキスト',
              style: fontStyle.copyWith(fontSize: 12),
            ),
            value: fontName,
            groupValue: selectedFont,
            onChanged: (value) => onFontChanged(value),
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }
}
