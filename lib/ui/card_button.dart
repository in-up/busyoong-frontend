import 'package:flutter/material.dart';
import 'package:busyoong/ui/palette.dart';

class CardButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData? icon;
  final String string;
  final Color color;
  final Color textColor;
  final Color iconColor;
  final double width;
  final double height;
  final double radius;
  const CardButton(this.string, {required this.onTap, this.icon, required this.color,required this.iconColor, required this.textColor, this.width = 300, this.height = 180, this.radius=35, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
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
                if (icon != null)
                  Icon(icon, color: iconColor, size: 50,),
                if (icon != null)
                  SizedBox(height: 15,),
                Text(string, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.w800),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
