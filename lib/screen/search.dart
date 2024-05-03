import 'package:flutter/material.dart';

import '../ui/card_button.dart';
import '../ui/palette.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '어디로 갈까요?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 20),
            CardButton('누르고 말하기', onTap:(){Navigator.pushNamed(context, '/result');}, icon: Icons.mic_rounded, color: Palette.red, width: 200,),
            SizedBox(height: 15),
            CardButton('취소', onTap:(){Navigator.of(context).pop();}, color: Palette.gray, width: 200, height: 70,),
          ],
        ),
      ),
    );
  }
}
