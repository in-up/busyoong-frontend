import 'package:busyoong/ui/palette.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      appBar: AppBar(
        title: const Text('알림'),
        centerTitle: true,
      ),
      body: Center(
        child: TextButton(
          onPressed: (){},
          child: Text(
            '알림이 없습니다.',
            style: TextStyle(fontSize: 24, color: Palette.black),
          ),
        ),
      ),
    );
  }
}
