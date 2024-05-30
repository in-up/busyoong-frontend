import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../ui/card_button.dart';
import '../ui/palette.dart';

class ResultScreen extends StatefulWidget {
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String resultText = '로딩 중...';
  var mybox = Hive.box('localdata');

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final String argument = ModalRoute.of(context)!.settings.arguments as String? ?? '';
    fetchDestination(argument);
  }


  Future<void> fetchDestination(String argument) async {
    print('Received argument: $argument');

    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/get-destination/$argument'));
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          resultText = jsonDecode(utf8.decode(response.bodyBytes))['result'];
        });
      } else {
        setState(() {
          resultText = '데이터를 불러오지 못했습니다';
        });
      }
    } catch (e) {
      // 예외 발생 시 에러를 출력합니다.
      print('Error fetching data: $e');
      setState(() {
        resultText = '데이터를 불러오지 못했습니다';
      });
    }
  }



  void addItem(data) async {
    await mybox.add(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('즐겨찾기에 추가되었습니다.'),
        duration: Duration(seconds: 1),
      ),
    );
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('검색어 확인'),
        centerTitle: true,
      ),
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
              textColor: Palette.white,
              iconColor: Palette.white,
              width: 200,
              height: 70,
            ),
            SizedBox(height: 15),
            CardButton(
              '경로 검색하기',
              onTap: () {
                print(resultText);
                Navigator.pushNamed(
                  context,
                  '/bus',
                  arguments: resultText,
                );
              },
              color: Palette.blue,
              textColor: Palette.white,
              iconColor: Palette.white,
              width: 200,
              height: 70,
            ),
            CardButton(
              '처음으로',
              onTap: () {
                Navigator.of(context).pop();
              },
              color: Palette.gray,
              textColor: Palette.black,
              iconColor: Palette.white,
              width: 200,
              height: 70,
            ),
          ],
        ),
      ),
    );
  }
}
