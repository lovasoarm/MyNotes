import 'package:flutter/material.dart';

class AnimationWidget {
  /// Animation de slide depuis le bas
  static Widget slideFromBottom({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: (duration.inMilliseconds + delay * 1000).round()),
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * 100),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de scale avec bounce
  static Widget scaleWithBounce({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: (duration.inMilliseconds + delay * 1000).round()),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation de fade in
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: (duration.inMilliseconds + delay * 1000).round()),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation de slide depuis la gauche
  static Widget slideFromLeft({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: (duration.inMilliseconds + delay * 1000).round()),
      tween: Tween(begin: -1.0, end: 0.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * MediaQuery.of(context).size.width, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation de rotation douce
  static Widget gentleRotation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: (duration.inMilliseconds + delay * 1000).round()),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 0.1, // Rotation très douce
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation combinée (fade + scale)
  static Widget fadeAndScale({
    required Widget child,
    Duration duration = const Duration(milliseconds: 700),
    double delay = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: (duration.inMilliseconds + delay * 1000).round()),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // S'assurer que l'opacité reste dans les limites valides
        final opacity = value.clamp(0.0, 1.0);
        final scale = (0.8 + (0.2 * value)).clamp(0.1, 1.0);
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de liste progressive
  static Widget listItemAnimation({
    required Widget child,
    required int index,
    Duration baseDelay = const Duration(milliseconds: 100),
  }) {
    return slideFromBottom(
      child: child,
      delay: index * baseDelay.inMilliseconds / 1000,
    );
  }

  /// Animation de bouton avec pulse
  static Widget buttonPulse({
    required Widget child,
    bool isActive = false,
  }) {
    if (!isActive) return child;
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 1.0, end: 1.05),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Widget de chargement animé
  static Widget loadingDots({
    Color color = Colors.blue,
    double size = 8.0,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 600),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -10 * value),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: value),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Widget pour animations personnalisées
class CustomAnimatedWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AnimationType type;

  const CustomAnimatedWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
    this.type = AnimationType.fadeIn,
  });

  @override
  State<CustomAnimatedWidget> createState() => _CustomAnimatedWidgetState();
}

class _CustomAnimatedWidgetState extends State<CustomAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case AnimationType.fadeIn:
        return FadeTransition(opacity: _animation, child: widget.child);
      case AnimationType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(_animation),
          child: widget.child,
        );
      case AnimationType.scale:
        return ScaleTransition(scale: _animation, child: widget.child);
      case AnimationType.rotation:
        return RotationTransition(turns: _animation, child: widget.child);
    }
  }
}

enum AnimationType { fadeIn, slideUp, scale, rotation }
