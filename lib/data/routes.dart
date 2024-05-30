import 'package:busyoong/screen/bus.dart';
import 'package:busyoong/screen/result.dart';
import 'package:busyoong/screen/search.dart';
import 'package:busyoong/screen/favorite.dart';
import 'package:busyoong/screen/favorite_search.dart';
import 'package:busyoong/screen/setting.dart';
import 'package:flutter/material.dart';
import '../screen/home.dart';
import '../screen/notification.dart';

final Widget homeRoute = HomeScreen();

final Map<String, WidgetBuilder> routes = {
  '/home': (context) => HomeScreen(),
  '/search': (context) => SearchScreen(),
  '/result': (context) => ResultScreen(),
  '/bus': (context) => BusScreen(),
  '/favorite': (context) => FavoriteScreen(),
  '/favorite_search': (context) => FavoriteSearchScreen(),
  '/setting' : (context) => SettingScreen(),
  '/notification' : (context) => NotificationScreen(),
};
