import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../ui/card_button.dart';
import '../ui/palette.dart';

class ResultScreen extends StatefulWidget {
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    final String resultText = ModalRoute.of(context)!.settings.arguments as String? ?? '예기치 못한 오류';
    var mybox = Hive.box('localdata');

    void addItem(data) async {
      await mybox.add(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('즐겨찾기에 추가되었습니다.'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              resultText,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 15),
            CardButton(
              '즐겨찾기에 추가',
              onTap: () {
                  Map<String, String> d = {
                    'title': resultText,
                  };
                  addItem(d);
              },
              color: Palette.yellow,
              width: 200,
              height: 70,
            ),
            SizedBox(height: 15),
            CardButton(
              '처음으로',
              onTap: () {
                Navigator.of(context).pop();
              },
              color: Palette.gray,
              width: 200,
              height: 70,
            ),
          ],
        ),
      ),
    );
  }
}
