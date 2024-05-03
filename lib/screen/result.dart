import 'package:flutter/material.dart';

import '../ui/card_button.dart';
import '../ui/palette.dart';

class ResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '결과 화면 예정',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 15),
            CardButton('처음으로', onTap:(){Navigator.of(context).pop();}, color: Palette.gray, width: 200, height: 70,),
          ],
        ),
      ),
    );
  }
}
