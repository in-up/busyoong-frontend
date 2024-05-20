import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    /*
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('items', <String>['Earth', 'Moon', 'Sun']);
    로 저장


    final prefs = await SharedPreferences.getInstance();
    List<String> favoriteList = await prefs.get('favorite');
    if (favoriteList.length == 0) {
        밑의 showText부분
    } else {

    }
     */

    _showText();
  }

  void _showText() async {
    // 1초 동안 자연스럽게 나타남
    setState(() {
      _opacity = 1.0;
    });
    await Future.delayed(Duration(seconds: 3));
    // 1초 동안 자연스럽게 사라짐
    setState(() {
      _opacity = 0.0;
    });
    await Future.delayed(Duration(seconds: 1));
    // 글자가 사라진 후 SearchScreen으로 이동
    Navigator.popAndPushNamed(context, '/favorite_search');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _opacity,
              duration: Duration(seconds: 1),
              child: Text(
                '자주 가는 곳을 말해주세요',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}