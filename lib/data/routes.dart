import 'package:busyoong/screen/result.dart';
import 'package:busyoong/screen/search.dart';
import 'package:busyoong/screen/favorite.dart';
import 'package:busyoong/screen/favorite_search.dart';

import 'package:flutter/material.dart';
import '../screen/home.dart';

final Widget homeRoute = HomeScreen();

final Map<String, WidgetBuilder> routes = {
  '/home': (context) => HomeScreen(),
  '/search': (context) => SearchScreen(),
  '/result': (context) => ResultScreen(),
  '/favorite': (context) => FavoriteScreen(),
  '/favorite_search': (context) => FavoriteSearchScreen(),
};
