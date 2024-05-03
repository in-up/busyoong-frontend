import 'package:flutter/material.dart';
import 'package:busyoong/ui/palette.dart';

class CardButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData? icon;
  final String string;
  final Color color;
  final double width;
  final double height;
  const CardButton(this.string, {required this.onTap, this.icon, required this.color, this.width = 300, this.height = 180, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.4),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) // 아이콘이 있는 경우에만 보여줍니다.
                Icon(icon, color: Palette.white, size: 50,),
              if (icon != null) // 아이콘이 있는 경우에만 간격을 추가합니다.
                SizedBox(height: 15,),
              Text(string, style: TextStyle(color: Palette.white, fontSize: 22, fontWeight: FontWeight.w800),)
            ],
          ),
        ),
      ),
    );
  }
}
