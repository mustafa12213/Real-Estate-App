import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final bool enableObscureToggle;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final int? maxLength;
  final bool autofocus;
  final String? prefixText;
  final String? suffixText;
  final bool readOnly;
  final VoidCallback? onTap;
  final InputDecoration? decoration;
  final Color? fillColor;
  final double borderRadius;
  final String? errorText;
  final bool showValidationIcon;
  final bool enabled;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.enableObscureToggle = false,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.prefixText,
    this.suffixText,
    this.readOnly = false,
    this.onTap,
    this.decoration,
    this.fillColor,
    this.borderRadius = 12,
    this.errorText,
    this.showValidationIcon = false,
    this.enabled = true,
    this.autocorrect = false,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(widget.controller.text);
  }

  String? get _currentError {
    if (widget.errorText != null && widget.errorText!.isNotEmpty) {
      return widget.errorText;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _currentError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label,
              style: AppTextStyles.label.copyWith(
                color: hasError ? AppColors.errorRed : AppColors.textSecondary,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: widget.fillColor ?? AppColors.inputBackground,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: hasError
                  ? AppColors.errorRed
                  : (widget.enabled
                      ? AppColors.inputBorder
                      : AppColors.inputBorder.withValues(alpha: 0.5)),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            enabled: widget.enabled,
            autocorrect: widget.autocorrect,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              prefixText: widget.prefixText,
              suffixText: widget.suffixText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              filled: false,
              counterText: '',
              suffixIcon: _buildSuffixIcon(hasError),
            ),
            inputFormatters: widget.inputFormatters,
          ),
        ),
        if (_currentError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              _currentError!,
              style: AppTextStyles.error,
            ),
          ),
      ],
    );
  }

  Widget? _buildSuffixIcon(bool hasError) {
    if (!widget.enableObscureToggle && !widget.showValidationIcon) {
      return null;
    }

    Widget? suffixIcon;

    if (widget.enableObscureToggle) {
      suffixIcon = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textHint,
          size: 22,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.showValidationIcon) {
      final iconWidget = Icon(
        hasError ? Icons.error_outline : Icons.check_circle,
        color: hasError ? AppColors.errorRed : AppColors.successGreen,
        size: 20,
      );
      suffixIcon = suffixIcon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                suffixIcon,
                const SizedBox(width: 8),
                iconWidget,
              ],
            )
          : iconWidget;
    }

    return suffixIcon;
  }
}
