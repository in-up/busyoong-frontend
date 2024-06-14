import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      String? baseUrl = dotenv.env['BASE_URL'];
      final response = await http.post(
          Uri.parse('$baseUrl/get-destination/$argument'));
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          resultText = jsonDecode(utf8.decode(response.bodyBytes))['result'];
        });
      } else {
        setState(() {
          resultText = '목적지 인식에 실패했어요.\n다시 시도해주세요.';
        });
      }
    } catch (e) {
      // 예외 발생 시 에러를 출력합니다.
      print('Error fetching data: $e');
      setState(() {
        resultText = '알 수 없는 오류입니다.\n다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      appBar: AppBar(
        title: const Text('검색어 확인'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 40,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '아래 목적지로 출발할까요?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Palette.blue),
              ),
            ),
            SizedBox(height: 5),
            Expanded(child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Container(
                  color: Palette.gray,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Text(
                      resultText,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, ),
                    ),
                  ),
                ),
              ),
            ),),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
                CardButton(
                  '계속하기',
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
                  width: 250,
                  height: 80,
                ),
                SizedBox(height: 10,),
                CardButton(
                  '아니에요',
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                          (Route<dynamic> route) => false,
                    );
                  },
                  color: Palette.gray,
                  textColor: Palette.black,
                  iconColor: Palette.white,
                  width: 250,
                  height: 80,
                ),
                SizedBox(height: 20,),
              ],),
            )
          ],
        ),
      ),
    );
  }
}
