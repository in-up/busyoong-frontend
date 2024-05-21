import 'package:busyoong/ui/card_button.dart';
import 'package:busyoong/ui/palette.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
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
            CardButton('즐겨찾기', onTap:(){Navigator.pushNamed(context, '/favorite');}, icon: Icons.star_rounded, color: Palette.yellow),
            SizedBox(height: 15),
            CardButton('우리집', onTap:(){}, icon: Icons.home_rounded, color: Palette.green),
            SizedBox(height: 15),
            CardButton('다른 장소', onTap:(){Navigator.pushNamed(context, '/search');}, icon: Icons.more_horiz_rounded, color: Palette.red, width: 200,),
          ],
        ),
      ),
    );
  }
}