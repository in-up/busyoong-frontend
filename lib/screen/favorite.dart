import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../ui/card_button.dart';
import '../ui/palette.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  var mybox = Hive.box('localdata');
  List mydata = [];

  var myText = TextEditingController();

  @override
  void initState() {
    super.initState();
    getItem();
  }

  void addItem(data) async {
    await mybox.add(data);
    print(mybox.values);
  }

  void getItem() {
    mydata = mybox.keys.map((e) {
      var res = mybox.get(e);
      return {'key': e, 'title': res['title']};
    }).toList();
    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('즐겨찾기'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            // SizedBox(
            //   height: 30,
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   child: TextField(
            //     controller: myText,
            //     decoration: InputDecoration(hintText: 'item'),
            //   ),
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            // ElevatedButton.icon(
            //   onPressed: () {
            //     Map<String, String> d = {
            //       'title': myText.text,
            //     };
            //     addItem(d);
            //     myText.clear();
            //     getItem();
            //   },
            //   icon: Icon(Icons.save),
            //   label: Text('save'),
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: mydata.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "${mydata[index]['title']}",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/result',
                        arguments: mydata[index]['title'],
                      );
                    },
                    onLongPress: () {
                      deleteItem(index);
                    },
                  );
                },
              ),
            ),
            CardButton(
              '처음으로',
              onTap: () {
                Navigator.of(context).pop();
              },
              color: Palette.gray,
              width: 200,
              height: 70,
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
