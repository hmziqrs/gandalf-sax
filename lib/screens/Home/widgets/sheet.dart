import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gandalf/constants.dart';
import 'package:gandalf/screens/Home/widgets/sheet_content.dart';
import 'package:gandalf/screens/Home/widgets/sheet_controls.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Sheet extends ConsumerWidget {
  const Sheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = 800.0;
    final sheetWidth = min(screenWidth, maxWidth);
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return Container(
      width: screenWidth,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: sheetWidth,
        constraints: BoxConstraints(
          maxHeight: maxHeight,
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
            SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                  SheetContent(),
                  SizedBox(height: PADDING),
                  SheetControls(),
                  SizedBox(height: PADDING),
                ],
              ),
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
