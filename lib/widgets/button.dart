import 'package:flutter/material.dart';
import 'package:loan_app/core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final bool enabled;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.color,
    this.width,
    this.height,
    this.textStyle,
    this.borderRadius,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final Color backgroundColor =
    //     enabled ? (color ?? buttonColor) : Colors.grey.shade300;

    final Color textColor = enabled ? Colors.white : Colors.grey.shade600;

    return SizedBox(
      width: width ?? 350,
      height: height ?? 50.0,
      child: ElevatedButton(
        onPressed: () {
          if (enabled) {
            onPressed!();
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            enabled ? (color ?? buttonColor) : Colors.grey.shade300,
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(6.0),
            ),
          ),
          foregroundColor: WidgetStateProperty.all(
            enabled ? Colors.white : Colors.grey.shade600,
          ),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black12;
            }
            return null;
          }),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? textColor, size: iconSize ?? 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style:
                  textStyle ??
                  TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: enabled ? Colors.white : Colors.grey.shade600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
