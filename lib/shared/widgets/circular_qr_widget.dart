import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// 圓形漸層包裝的 QR Code 組件
class CircularQrWidget extends StatefulWidget {
  const CircularQrWidget({
    super.key,
    required this.data,
    this.size = AppConstants.qrContainerSize,
    this.animated = false,
    this.description,
  });

  /// QR Code 數據
  final String data;
  
  /// 整體大小
  final double size;
  
  /// 是否顯示動畫效果
  final bool animated;
  
  /// 描述文字
  final String? description;

  @override
  State<CircularQrWidget> createState() => _CircularQrWidgetState();
}

class _CircularQrWidgetState extends State<CircularQrWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    if (widget.animated) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circleSize = widget.size * 0.92;
    final backgroundSize = widget.size * 0.85;
    final qrSize = widget.size * 0.69;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 動態漸層外環
              if (widget.animated)
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: child,
                    );
                  },
                  child: _buildGradientCircle(circleSize),
                )
              else
                _buildGradientCircle(circleSize),

              // 白色圓形背景
              Container(
                width: backgroundSize,
                height: backgroundSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),

              // QR Code
              QrImageView(
                data: widget.data,
                version: QrVersions.auto,
                size: qrSize,
                backgroundColor: Colors.white,
                gapless: false,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ],
          ),
        ),

        // 描述文字
        if (widget.description != null) ...[
          const SizedBox(height: AppTheme.spacingM),
          Text(
            widget.description!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildGradientCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(
          colors: AppTheme.circularGradient,
          stops: [0.0, 0.33, 0.66, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
