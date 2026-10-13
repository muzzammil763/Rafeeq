import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedBorderButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final String label;
  final IconData? icon;
  final Color primaryColor;
  final Color secondaryColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final double? width;
  final double height;
  final double borderRadius;
  final double borderWidth;

  const AnimatedBorderButton({
    super.key,
    required this.isActive,
    required this.onPressed,
    required this.label,
    this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    this.width,
    this.height = 50,
    this.borderRadius = 16,
    this.borderWidth = 2,
  });

  @override
  State<AnimatedBorderButton> createState() => _AnimatedBorderButtonState();
}

class _AnimatedBorderButtonState extends State<AnimatedBorderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedBorderButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: widget.isActive
                ? LinearGradient(
                    colors: [
                      widget.primaryColor,
                      widget.secondaryColor,
                      widget.primaryColor,
                    ],
                    stops: [
                      (_animation.value - 0.3).clamp(0.0, 1.0),
                      _animation.value.clamp(0.0, 1.0),
                      (_animation.value + 0.3).clamp(0.0, 1.0),
                    ],
                  )
                : null,
            color: widget.isActive ? null : widget.surfaceColor,
          ),
          child: Container(
            margin: widget.isActive ? EdgeInsets.all(widget.borderWidth) : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius - 2),
              color: widget.isActive ? widget.surfaceColor : Colors.transparent,
              border: widget.isActive
                  ? null
                  : Border.all(
                      color: widget.onSurfaceColor.withValues(alpha: 0.3),
                    ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(widget.borderRadius - 2),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.isActive
                              ? widget.onSurfaceColor
                              : widget.onSurfaceColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.isActive
                              ? widget.onSurfaceColor
                              : widget.onSurfaceColor,
                        ),
                      ).animate().slideX().shimmer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
