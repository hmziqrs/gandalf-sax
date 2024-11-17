import 'package:flutter/material.dart';
import 'package:gandalf/constants.dart';

class AlphaButton extends StatelessWidget {
  AlphaButton({
    // Required
    required this.onTap,
    this.label,

    // Not required
    this.icon,
    this.margin = EdgeInsets.zero,
    this.color, // Add new optional color parameter
    this.mainAxisSize = MainAxisSize.min,

    // Assignable
    borderRadius,
  }) : this.borderRadius = borderRadius ?? BorderRadius.circular(8.0);

  final String? label;
  final IconData? icon;
  final EdgeInsets margin;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final Color? color; // Add color property
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final hasIcon = this.icon != null;
    final backgroundColor = this.color ??
        Colors.black.withOpacity(0.24); // Use provided color or default

    return Padding(
      padding: this.margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: this.onTap,
          borderRadius: this.borderRadius,
          child: Container(
            width: null,
            decoration: BoxDecoration(
              color: backgroundColor, // Use the backgroundColor variable
              borderRadius: this.borderRadius,
            ),
            padding: EdgeInsets.symmetric(
              vertical: PADDING * 1.3,
              horizontal: PADDING * 2,
            ),
            child: Row(
              mainAxisSize: this.mainAxisSize,
              children: [
                hasIcon
                    ? Icon(
                        this.icon,
                        size: 16,
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                      )
                    : SizedBox(),
                if (this.label != null && hasIcon)
                  SizedBox(width: hasIcon ? PADDING * 1.5 : 0.0),
                if (this.label != null)
                  Text(
                    this.label!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
