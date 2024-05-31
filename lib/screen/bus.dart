import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ui/card_button.dart';
import '../ui/palette.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusScreen extends StatefulWidget {
  @override
  State<BusScreen> createState() => _BusScreenState();
}

class _BusScreenState extends State<BusScreen> {
  String resultText = '로딩 중...';
  List<String> fastArrive = [];
  List<String> shortTime = [];
  List<String> startBusStop = [];

  var mybox = Hive.box('localdata');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final String argument = ModalRoute.of(context)!.settings.arguments as String? ?? '';
    fetchDestination(argument);
  }

  Future<void> fetchDestination(String argument) async {
    print('Received argument: $argument');

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/get-bus-result'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userLati': '37.3017',
          'userLong': '127.0342167',
          'userOrigin': 'string',
          'userDestination': argument,
        }),
      );
      final utf8Body = utf8.decode(response.bodyBytes);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(utf8Body);
        setState(() {
          resultText = '정보를 가져왔습니다';
          shortTime = List<String>.from(jsonResponse['short_time']);
          startBusStop = List<String>.from(jsonResponse['start_bus_stop']);
        });
        await fetchBusInfo(startBusStop[1]);
      } else {
        setState(() {
          resultText = '데이터를 불러오지 못했습니다';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        resultText = '데이터를 불러오지 못했습니다';
      });
    }
  }

  Future<void> fetchBusInfo(String nodeId) async {
    print(nodeId);
    final response = await http.get(
      Uri.parse('https://apis.data.go.kr/1613000/ArvlInfoInqireService/getSttnAcctoArvlPrearngeInfoList?serviceKey=GO3svuHSZvTjqLvHZZuR6rwyejlkFxa4HXcCeQmJt0izZxMLCc%2Bcg4QXrkMG7zwjgMhtCuqPh12%2BgslQVY3nNg%3D%3D&pageNo=1&numOfRows=10&_type=json&cityCode=31010&nodeId=$nodeId'),
    );
    final jsonResponse = jsonDecode(response.body);
    print(jsonResponse);

    final items = jsonResponse['response']['body']['items']['item'] as List;

    print(items);

    items.sort((a, b) => a['arrtime'].compareTo(b['arrtime']));
    final shortestBusInfo = items.firstWhere((item) => shortTime.contains(item['routeid']), orElse: () => null);

    setState(() {
      fastArrive = items.map<String>((item) => item['routeno'].toString()).toList();
      resultText = '정보를 가져왔습니다';
      // Adding the shortest bus information to the list
      print(fastArrive);
      if (shortestBusInfo != null) {
        fastArrive.add('가장 짧은 시간: ${shortestBusInfo['arrtime'] ~/ 60}분 ${shortestBusInfo['routeno']}번');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    late GoogleMapController mapController;
    final LatLng _center = const LatLng(37.2973874, 127.0398951);

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
    }
    return Scaffold(
      backgroundColor: Palette.white,
      appBar: AppBar(
        title: const Text('버스 검색 결과'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Palette.white,
                child: SizedBox(
                  height: 300,
                  child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _center,
                        zoom: 15.0,
                      ),
                      markers: {
                        Marker(
                            markerId: MarkerId('userLocation'),
                            position: _center
                        )
                      },
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(() => ScaleGestureRecognizer()),
                      }
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(color: Palette.green, onPressed: () {  }, icon: Icon(Icons.directions_bus_filled_rounded, size: 40,),),
              SizedBox(width: 20,),
              Text(
                resultText,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Column(
            children: [
              Text('빠르게 도착하는 버스: ${fastArrive.join(", ")}'),
              Text('소요 시간이 짧은 버스: ${shortTime.join(", ")}'),
              Text('출발 정류장: ${startBusStop.join(", ")}'),
            ],
          ),
          SizedBox(height: 15),
          Expanded(child: Container()),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: CardButton(
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
          ),
        ],
      ),
    );
  }
}
