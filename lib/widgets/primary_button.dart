import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final IconData? icon;
  final double iconSize;
  final EdgeInsets? padding;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.height = 50,
    this.width,
    this.borderRadius,
    this.textStyle,
    this.icon,
    this.iconSize = 22,
    this.padding,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isDisabled || widget.isLoading || widget.onPressed == null;
    final bgColor = widget.backgroundColor ?? AppColors.buttonBackground;
    final txtColor = widget.textColor ?? AppColors.buttonText;

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Material(
        color: isDisabled
            ? AppColors.buttonDisabled.withValues(alpha: 0.5)
            : bgColor,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: InkWell(
          onTap: isDisabled ? null : widget.onPressed,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: widget.iconSize,
                          color: txtColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: widget.textStyle ??
                            AppTextStyles.button.copyWith(
                              color: txtColor,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
