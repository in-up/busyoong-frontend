import 'dart:math';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';

import '../ui/card_button.dart';
import '../ui/palette.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _hasSpeech = false;
  bool _logEvents = false;
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
    _logEvent('Initialize');
    var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: true,
        finalTimeout: Duration(milliseconds: 0));
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
          SizedBox(
            height: 200,
            child: Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    lastWords,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          CardButton(
            '누르고 말하기',
            onTap: !_hasSpeech || speech.isListening ? null : startListening,
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

  void startListening() {
    _logEvent('start listening');
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
        listenMode: ListenMode.confirmation);
    setState(() {});
  }

  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result
            .recognizedWords}');
    setState(() {
      lastWords = result.recognizedWords;
    });

    if (result.finalResult && lastWords.isNotEmpty) {
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
    _logEvent(
        'Received error status: $error, listening: ${speech.isListening}');
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    _logEvent(
        'Received listener status: $status, listening: ${speech.isListening}');
    setState(() {
      lastStatus = '$status';
    });
  }

  void _logEvent(String eventDescription) {
    if (_logEvents) {
      var eventTime = DateTime.now().toIso8601String();
      print('$eventTime $eventDescription');
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
                Navigator.of(context).pop();
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