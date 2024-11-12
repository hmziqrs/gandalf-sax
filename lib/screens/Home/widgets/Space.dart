import 'package:flutter/material.dart';
import 'package:gandalf/constants.dart';

class Space extends StatelessWidget {
  Space({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: PADDING * 2),
      child: this.child,
    );
  }
}
