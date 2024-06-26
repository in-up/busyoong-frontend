import 'package:busyoong/ui/card_button.dart';
import 'package:busyoong/ui/palette.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(37.2973874, 127.0398951);  // 시연용 출발 위치 설정
  String? _mapStyle;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_mapStyle != null) {
      controller.setMapStyle(_mapStyle);
    }
  }

  var mybox = Hive.box('localdata');
  List<Map<String, dynamic>> mydata = [];

  var myText = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    getItem();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    getItem();
  }

  Future _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map.json');
  }

  void addItem(Map<String, dynamic> data) async {
    await mybox.add(data);
    print(mybox.values);
    getItem();
  }

  void deleteItem(int index) {
    mybox.delete(mydata[index]['key']);
    getItem();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('삭제되었습니다'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void getItem() {
    setState(() {
      mydata = mybox.keys.map((e) {
        var res = mybox.get(e);
        return {'key': e, 'title': res['title']};
      }).toList();
    });
  }

  void navigateToHome() {
    var homeData = mybox.get('home');
    if (homeData != null) {
      Navigator.pushNamed(
        context,
        '/bus',
        arguments: homeData['title'],
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장된 우리집이 없습니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate =
    DateFormat('M월 d일 (EE)', 'ko_KR').format(DateTime.now());

    return Scaffold(
      backgroundColor: Palette.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      Text(
                        formattedDate,
                        style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Text(
                            '오늘은 어디로 갈까요?',
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                  Expanded(child: Container(),),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: IconButton(onPressed: () {  Navigator.pushNamed(context, '/notification'); }, icon: Icon(Icons.notifications_none_rounded, size: 40),),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Palette.white,
                    child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _center,
                          zoom: 16.0,
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
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CardButton(
                      '즐겨찾기',
                      onTap: () {
                        Navigator.pushNamed(context, '/favorite');
                      },
                      icon: Icons.star_rounded,
                      color: Palette.alt,
                      textColor: Palette.black,
                      iconColor: Palette.yellow,
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: CardButton(
                      '우리집',
                      onTap: navigateToHome,
                      icon: Icons.home_rounded,
                      color: Palette.alt,
                      textColor: Palette.black,
                      iconColor: Palette.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CardButton(
                      '목적지 검색하기',
                      onTap: () {Navigator.pushNamed(context, '/search');},
                      icon: Icons.near_me_rounded,
                      color: Palette.blue,
                      textColor: Palette.white,
                      iconColor: Palette.white,
                      radius: 50,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () {Navigator.pushNamed(
                  context,
                  '/setting'
                );},
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings, size: 18),
                      SizedBox(width: 8),
                      Text(
                        '설정',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
