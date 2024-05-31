import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _mapStyle;
  String resultText = '로딩 중...';
  String infoText = '';
  String searchText = 'undefined';
  List<String> fastArrive = [];
  List<Map<String, dynamic>> shortTime = [];
  List<String> startBusStop = [];
  LatLng destinationLatLng = LatLng(37.2973874, 127.0398951);
  late GoogleMapController mapController;

  var mybox = Hive.box('localdata');

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final String argument = ModalRoute.of(context)!.settings.arguments as String? ?? '';
    fetchDestination(argument);
  }

  Future _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map.json');
  }

  Future<void> fetchDestination(String argument) async {
    print('Received argument: $argument');
    searchText = argument;

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
          resultText = '$searchText까지 가는 버스를 찾았어요!';
          startBusStop = List<String>.from(jsonResponse['start_bus_stop']);
          fastArrive = List<String>.from(jsonResponse['fast_arrive']);
          shortTime = List<Map<String, dynamic>>.from(jsonResponse['short_time']);
          destinationLatLng = LatLng(jsonResponse['endLati'], jsonResponse['endLong']);
        });

        mapController.animateCamera(
          CameraUpdate.newLatLng(destinationLatLng),
        );

        await fetchBusInfo(startBusStop[1]);
      } else {
        setState(() {
          resultText = '\u{2757} 현재 이곳에서 목적지에 갈 수 없어요.';
          infoText = '도착 예정 버스가 없거나, 버스 이용 가능 경로가 아닙니다.';
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        resultText = '\u{2757} 알 수 없는 오류가 발생했습니다.';
        infoText = '잠시 후 다시 시도해주세요.';
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
    final shortestBusInfo = items.firstWhere((item) => shortTime.any((short) => short['routeId'] == item['routeid']), orElse: () => null);

    setState(() {
      fastArrive = items.map<String>((item) => item['routeno'].toString()).toList();
      resultText = '$searchText까지 가는 버스를 찾았어요!';
      if (shortestBusInfo != null) {
        fastArrive.add('가장 짧은 시간: ${shortestBusInfo['arrtime'] ~/ 60}분 ${shortestBusInfo['routeno']}번');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final LatLng _center = destinationLatLng;

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
      if (_mapStyle != null) {
        controller.setMapStyle(_mapStyle);
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
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue, // 테두리 색상
                    width: 2, // 테두리 두께
                  ),
                  borderRadius: BorderRadius.circular(20), // 테두리 둥글기
                ),
                child: SizedBox(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _center,
                      zoom: 17.0,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('userLocation'),
                        position: _center,
                      )
                    },
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(() => ScaleGestureRecognizer()),
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 50),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  resultText,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                infoText,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Palette.red),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: shortTime.length,
              itemBuilder: (context, index) {
                final bus = shortTime[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    title: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Icon(Icons.directions_bus_rounded, size: 35, color: Palette.green,),
                        ),
                        Text('${bus['routeId']}번 버스', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Palette.green),),
                        Expanded(child: Container()),
                        Text('${bus['routePredictTime'] ~/ 60}분', style: TextStyle(fontSize: 24, color: Palette.black, fontWeight: FontWeight.w700),),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                CardButton(
                  '즐겨찾기에 추가',
                  onTap: () {
                    Map<String, String> d = {
                      'title': searchText,
                    };
                    addItem(d);
                  },
                  color: Palette.yellow,
                  textColor: Palette.white,
                  iconColor: Palette.white,
                  width: 200,
                  height: 70,
                ),
                SizedBox(height: 10,),
                CardButton(
                  '홈으로',
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                          (Route<dynamic> route) => false,
                    );

                  },
                  color: Palette.blue,
                  textColor: Palette.white,
                  iconColor: Palette.white,
                  width: 200,
                  height: 70,
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
