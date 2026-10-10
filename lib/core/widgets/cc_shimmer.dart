import 'package:flutter/material.dart';

/// A reusable high-performance shimmer animation widget.
/// Shimmers its child widget with a moving gradient highlight.
class CCShimmer extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const CCShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1300),
  });

  @override
  State<CCShimmer> createState() => _CCShimmerState();
}

class _CCShimmerState extends State<CCShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBase = isDark ? const Color(0xFF1E2638) : const Color(0xFFE2E8F0);
    final defaultHighlight = isDark ? const Color(0xFF2E384D) : const Color(0xFFF1F5F9);

    final base = widget.baseColor ?? defaultBase;
    final highlight = widget.highlightColor ?? defaultHighlight;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: const Alignment(-1.5, -0.3),
              end: const Alignment(1.5, 0.3),
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              colors: [
                base,
                base,
                highlight,
                base,
                base,
              ],
              transform: _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * (slidePercent * 2.5 - 1.0), 0, 0);
  }
}

/// A convenient rounded skeleton placeholder box that shimmers.
class CCSkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;

  const CCSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? const Color(0xFF222B3D) : const Color(0xFFE2E8F0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? defaultColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
