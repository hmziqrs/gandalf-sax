import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/screens/Home/widgets/sheet_content.dart';
import 'package:gandalf/screens/Home/widgets/sheet_controls.dart';

class Sheet extends ConsumerWidget {
  const Sheet({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = 800.0; // Maximum width for the sheet
    final sheetWidth = min(screenWidth, maxWidth); // Take the smaller value
    final maxHeight =
        MediaQuery.of(context).size.height * 0.9; // 90% of screen height
    return Container(
      width: screenWidth, // Full screen width container
      alignment: Alignment.bottomCenter,
      child: Container(
        width: sheetWidth,
        constraints: BoxConstraints(
          maxHeight: maxHeight, // 90% of screen height
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomSheetTheme.backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Add a drag handle
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Add your sheet content here
                SheetContent(),
                SheetControls(),
              ],
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                tooltip: "close",
                icon: Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
