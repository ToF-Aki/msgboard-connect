import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final Color? selectedColor;
  final Function(Color?) onColorChanged;

  const ColorSelector({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  // 利用可能な色のリスト
  static const List<Map<String, dynamic>> availableColors = [
    {'name': 'デフォルト（黒）', 'color': null},
    {'name': '赤', 'color': Colors.red},
    {'name': '青', 'color': Colors.blue},
    {'name': '緑', 'color': Colors.green},
    {'name': '紫', 'color': Colors.purple},
    {'name': 'オレンジ', 'color': Colors.orange},
    {'name': 'ピンク', 'color': Colors.pink},
    {'name': '茶色', 'color': Colors.brown},
    {'name': '深い青', 'color': Colors.indigo},
    {'name': 'ティール', 'color': Colors.teal},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFE0B2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '文字色を選択してください',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableColors.map((colorOption) {
                final colorName = colorOption['name'] as String;
                final color = colorOption['color'] as Color?;
                final isSelected = selectedColor == color;
                
                return GestureDetector(
                  onTap: () => onColorChanged(color),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (color != null)
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                          )
                        else
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          colorName,
                          style: TextStyle(
                            color: color ?? Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (selectedColor != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'プレビュー: こんにちは世界！',
                  style: TextStyle(
                    color: selectedColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

