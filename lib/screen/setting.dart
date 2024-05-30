import 'package:busyoong/ui/palette.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  var mybox = Hive.box('localdata');

  void clearData() async {
    await mybox.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('모든 데이터가 초기화되었습니다.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextButton.icon(
            onPressed: clearData,
            icon: Icon(Icons.delete, color: Palette.red),
            label: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '데이터 초기화',
                style: TextStyle(fontSize: 18, color: Palette.black),
              ),
            ),
                    ),
          ),
      ],
      ),

    );
  }
}
