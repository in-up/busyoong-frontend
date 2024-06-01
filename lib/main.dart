import 'package:busyoong/ui/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/init.dart';
import 'data/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return LimitedSizeBox(child: child!);
      },
      home: homeRoute,
      routes: routes,
      theme: ThemeData(
        useMaterial3: true,
        canvasColor: Color(0xFFfcfcfc),
        fontFamily: 'Pretendard',
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          // TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          // TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          // TargetPlatform.windows: CupertinoPageTransitionsBuilder()
        }),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 0
        ),
        cardTheme: const CardTheme(elevation: 0),
        appBarTheme: const AppBarTheme(color: Palette.white,)
      ),
    );
  }
}

class LimitedSizeBox extends StatelessWidget {
  final Widget child;

  LimitedSizeBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = 500;
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;

          return Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: width > maxWidth ? maxWidth : width,
                  color: Colors.white,
                  child: child,
                ),
                SizedBox(width: 65,),
                Container(
                  width: 550,
                  child: Image.asset('assets/images/bg.png'),
                )
              ],
            ),
          );
        },
      ),
      backgroundColor: Color(0xFF000000),
    );
  }
}