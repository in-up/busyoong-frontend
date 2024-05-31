import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../ui/card_button.dart';
import '../ui/palette.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }




  Future<void> initSpeechState() async {
    var hasSpeech = await speech.initialize(
      onError: errorListener,
      onStatus: statusListener,
      debugLogging: true,
      finalTimeout: Duration(milliseconds: 0),
    );
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale?.localeId ?? '';
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      appBar: AppBar(
        title: const Text('목적지 검색'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '목적지를 말씀해주세요.',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 20),
          Expanded(child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: Container(
                color: Palette.gray,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Text(
                    lastWords,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, ),
                  ),
                ),
              ),
            ),
          ),),
          SizedBox(height: 20),
          CardButton(
            '누르고 말하기',
            onTap: !_hasSpeech || speech.isListening ? cancelListening : startListening,
            icon: Icons.mic_rounded,
            color: Palette.blue,
            textColor: Palette.white,
            iconColor: Palette.white,
            width: 250,
            height: 220,
          ),
          SizedBox(height: 5),
          CardButton(
            '키보드로 입력',
            onTap: () {
              _showTextInputDialog(context);
            },
            color: Palette.gray,
            textColor: Palette.black,
            iconColor: Palette.white,
            width: 250,
            height: 80,
          ),
          SizedBox(height: 5),
          CardButton(
            '취소',
            onTap: () {
              Navigator.of(context).pop();
            },
            color: Palette.gray,
            textColor: Palette.black,
            iconColor: Palette.white,
            width: 250,
            height: 80,
          ),
        ],
      ),
    );
  }

  void cancelListening() {
    if (speech.isListening) {
      speech.stop();
      if (lastWords.isNotEmpty) {
        cancelListening();
        Navigator.pushNamed(
          context,
          '/result',
          arguments: lastWords,
        );
      }
    }
  }

  void startListening() {
    lastWords = '';
    lastError = '';
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 5),
      partialResults: true,
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      listenMode: ListenMode.dictation,
    );
    setState(() {});

    // 음성 인식 시작 후 5초 후에 자동으로 취소
    Future.delayed(Duration(seconds: 5), () {
      if (speech.isListening) {
        cancelListening();
      }
    });
  }


  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });

    if (result.finalResult && lastWords.isNotEmpty) {
      cancelListening();
      Navigator.pushNamed(
        context,
        '/result',
        arguments: lastWords,
      );
    }
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = '$status';
    });

    if (status == "notListening" && lastWords.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/result',
        arguments: lastWords,
      );
    }
  }


  void _showTextInputDialog(BuildContext context) {
    final TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('키보드 입력'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "어디로 갈까요?"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('돌아가기'),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                      (Route<dynamic> route) => false,
                );
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () {
                setState(() {
                  lastWords = _textFieldController.text;
                });
                Navigator.of(context).pop();
                if (lastWords.isNotEmpty && !speech.isListening) {
                  Navigator.pushNamed(
                    context,
                    '/result',
                    arguments: lastWords,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
