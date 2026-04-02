import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:listzly/providers/nav_provider.dart';

class AnimatedSealTooltip extends ConsumerStatefulWidget {
  const AnimatedSealTooltip({
    super.key,
    required this.onTap,
    required this.navIndex,
  });

  final VoidCallback onTap;
  final int navIndex;

  @override
  ConsumerState<AnimatedSealTooltip> createState() =>
      _AnimatedSealTooltipState();
}

class _AnimatedSealTooltipState extends ConsumerState<AnimatedSealTooltip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasPlayed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.85), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.05), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 15),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _playIfFirst() {
    if (!_hasPlayed && mounted) {
      _hasPlayed = true;
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _controller.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navIndexProvider);

    // Play on the first build where this tab is active
    if (currentIndex == widget.navIndex && !_hasPlayed) {
      _playIfFirst();
    }

    ref.listen(navIndexProvider, (prev, next) {
      if (next == widget.navIndex && !_hasPlayed) {
        _playIfFirst();
      }
    });

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: _hasPlayed ? _animation.value : 0.0,
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SvgPicture.asset(
          'lib/images/licensed/svg/seal_tooltip.svg',
          width: 30,
          height: 30,
        ),
      ),
    );
  }
}
