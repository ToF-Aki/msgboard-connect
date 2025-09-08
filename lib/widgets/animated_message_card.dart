import 'package:flutter/material.dart';
import '../models/message.dart';
import 'message_card.dart';

class AnimatedMessageCard extends StatefulWidget {
  final Message message;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final Duration delay;
  final double verticalOffset; // Y座標のオフセット

  const AnimatedMessageCard({
    super.key,
    required this.message,
    this.onTap,
    this.animationDuration = const Duration(seconds: 15),
    this.delay = Duration.zero,
    this.verticalOffset = 0.0,
  });

  @override
  State<AnimatedMessageCard> createState() => _AnimatedMessageCardState();
}

class _AnimatedMessageCardState extends State<AnimatedMessageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // 右から開始
      end: const Offset(-1.0, 0.0),   // 左に移動
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.1, curve: Curves.easeIn),
    ));

    // 遅延後にアニメーション開始
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height * 0.2 + widget.verticalOffset,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8, // カード幅を80%に制限
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: MessageCard(
              message: widget.message,
              onTap: widget.onTap,
            ),
          ),
        ),
      ),
    );
  }
}
