import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/message.dart';
import 'message_card.dart';

class FloatingMessageCard extends StatefulWidget {
  final Message message;
  final VoidCallback? onTap;
  final Size screenSize;
  final int index;

  const FloatingMessageCard({
    super.key,
    required this.message,
    this.onTap,
    required this.screenSize,
    required this.index,
  });

  @override
  State<FloatingMessageCard> createState() => _FloatingMessageCardState();
}

class _FloatingMessageCardState extends State<FloatingMessageCard>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late Animation<double> _scaleAnimation;
  
  late double _startX;
  late double _endX;
  late double _scale;

  @override
  void initState() {
    super.initState();
    
    // より安定した動きのための設定
    final random = math.Random(widget.index);
    _startX = widget.screenSize.width + 200; // より右側から開始
    
    _endX = -300; // より左側で終了
    
    // スケールを固定して安定させる
    _scale = 1.0; // 固定サイズ

    _floatController = AnimationController(
      duration: Duration(seconds: 30 + random.nextInt(10)), // 30-40秒（軽量化）
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.linear, // 線形の動きで安定させる
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    // アニメーション完了時のコールバックを設定
    _floatController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // アニメーション完了後、再度開始
        _floatController.reset();
        _floatController.forward();
      }
    });

    // 遅延後にアニメーション開始（2秒で開始）
    Future.delayed(Duration(milliseconds: 2000 + widget.index * 1000), () {
      if (mounted) {
        _floatController.forward();
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnimation, _scaleAnimation]),
      builder: (context, child) {
        final currentX = _startX + (_endX - _startX) * _floatAnimation.value;
        // Y座標を完全に分離して重なりを防ぐ
        final cardHeight = widget.screenSize.height * 0.3; // カードの高さ
        final spacing = cardHeight * 0.5; // カード間のスペース
        final totalHeight = cardHeight + spacing; // 1つのカードが占める高さ
        final currentY = (widget.index * totalHeight) % (widget.screenSize.height - cardHeight);
        final currentScale = _scale * _scaleAnimation.value;

        return Positioned(
          left: currentX,
          top: currentY,
          child: Transform.scale(
            scale: currentScale,
            child: Opacity(
              opacity: _scaleAnimation.value,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: widget.screenSize.width * 0.35, // 画面幅の35%に制限（より小さく）
                  maxHeight: widget.screenSize.height * 0.25, // 高さも制限（より小さく）
                ),
                child: MessageCard(
                  message: widget.message,
                  onTap: widget.onTap,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
