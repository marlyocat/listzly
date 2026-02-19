// ignore_for_file: deprecated_member_use
import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:listzly/theme/colors.dart';

class FlipBoxNavItem {
  FlipBoxNavItem({
    required this.name,
    this.selectedImage,
    this.unselectedImage,
    this.icon,
    this.selectedBackgroundColor = Colors.blue,
    this.unselectedBackgroundColor = Colors.lightBlue,
  }) : assert(
          (selectedImage != null && unselectedImage != null) || icon != null,
          'Either provide both selectedImage and unselectedImage, or provide an icon.',
        );

  final String name;
  final String? selectedImage;
  final String? unselectedImage;
  final IconData? icon;
  final Color selectedBackgroundColor;
  final Color unselectedBackgroundColor;
}

class FlipBoxNavBar extends StatefulWidget {
  const FlipBoxNavBar({
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.iconSize = 24.0,
    this.verticalPadding = 16.0,
    this.textStyle,
    this.duration = const Duration(milliseconds: 800),
    super.key,
  });

  final List<FlipBoxNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final double iconSize;
  final double verticalPadding;
  final TextStyle? textStyle;
  final Duration duration;

  double get tileHeight => verticalPadding * 2 + iconSize;

  @override
  State<FlipBoxNavBar> createState() => _FlipBoxNavBarState();
}

class _FlipBoxNavBarState extends State<FlipBoxNavBar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  int? _oldIndex;

  void _resetControllers() {
    _controllers = List.generate(
      widget.items.length,
      (i) => AnimationController(duration: widget.duration, vsync: this),
    );
  }

  void _switchIndex() {
    if (_oldIndex != null && _oldIndex != widget.currentIndex) {
      _controllers[_oldIndex!].reverse(from: 1.0);
      _controllers[widget.currentIndex].forward(from: 0.0);
    } else {
      _controllers[widget.currentIndex].forward(from: 0.8);
    }
  }

  @override
  void initState() {
    super.initState();
    _resetControllers();
    _oldIndex = widget.currentIndex;
    _switchIndex();
  }

  @override
  void didUpdateWidget(FlipBoxNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      for (final c in _controllers) {
        c.dispose();
      }
      _resetControllers();
      _oldIndex = widget.currentIndex;
    } else {
      _oldIndex = oldWidget.currentIndex;
    }
    _switchIndex();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: widget.tileHeight,
      decoration: const BoxDecoration(
        color: navBarBg,
        border: Border(
          top: BorderSide(
            color: Color(0x14FFFFFF),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: List.generate(widget.items.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () => widget.onTap?.call(index),
              child: _FlipBoxTile(
                key: UniqueKey(),
                item: widget.items[index],
                controller: _controllers[index],
                height: widget.tileHeight,
                iconSize: widget.iconSize,
                textStyle: widget.textStyle ??
                    GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _FlipBoxTile extends StatefulWidget {
  _FlipBoxTile({
    required this.item,
    required AnimationController controller,
    required this.height,
    required this.iconSize,
    required this.textStyle,
    super.key,
  }) : animation = TweenSequence(<TweenSequenceItem<double>>[
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.1), weight: 10),
          TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.0), weight: 25),
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 30),
          TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 20),
        ]).animate(controller);

  final FlipBoxNavItem item;
  final Animation<double> animation;
  final double height;
  final double iconSize;
  final TextStyle textStyle;

  @override
  State<_FlipBoxTile> createState() => _FlipBoxTileState();
}

class _FlipBoxTileState extends State<_FlipBoxTile> {
  Widget get _selectedSide => Container(
        height: widget.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.item.selectedBackgroundColor,
              navBarBg,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Coral active indicator
            Center(
              child: Container(
                height: 2.5,
                width: 28,
                decoration: BoxDecoration(
                  color: accentCoral,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentCoral.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.item.selectedImage != null)
                    Image.asset(widget.item.selectedImage!,
                        width: widget.iconSize, height: widget.iconSize)
                  else
                    Icon(widget.item.icon, size: widget.iconSize,
                        color: Colors.white),
                  const SizedBox(height: 3),
                  Text(widget.item.name,
                      textAlign: TextAlign.center, style: widget.textStyle),
                ],
              ),
            ),
          ],
        ),
      );

  Widget get _unselectedSide => Container(
        height: widget.height,
        color: navBarBg,
        child: Center(
          child: widget.item.unselectedImage != null
              ? Image.asset(widget.item.unselectedImage!,
                  width: widget.iconSize, height: widget.iconSize)
              : Icon(widget.item.icon, size: widget.iconSize,
                  color: Colors.white.withAlpha(140)),
        ),
      );

  double _abs(double x) => x >= 0.0 ? x : -x;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (_, _) {
          final v = widget.animation.value;
          final selectedSide = Positioned(
            child: Transform.translate(
              offset: Offset(0.0, (1 - v) * widget.height),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.005)
                  ..rotateX((1 - v) * pi / 2)
                  ..scale(1 + (0.5 - _abs(v - 0.5)) / 5),
                alignment: Alignment.topCenter,
                child: _selectedSide,
              ),
            ),
          );
          final unselectedSide = Positioned(
            child: Transform.translate(
              offset: Offset(0.0, -v * widget.height),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.005)
                  ..rotateX(-v * pi / 2)
                  ..scale(1 + (0.5 - _abs(v - 0.5)) / 5),
                alignment: Alignment.bottomCenter,
                child: _unselectedSide,
              ),
            ),
          );
          return Stack(
            children: (v > 1.0)
                ? [unselectedSide, selectedSide]
                : [selectedSide, unselectedSide],
          );
        },
    );
  }
}
