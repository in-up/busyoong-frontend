import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> init() async {
  await initializeDateFormatting('ko_KR', null);
  await Hive.initFlutter();
  await dotenv.load(fileName: 'assets/.env');
  var box = await Hive.openBox('localdata');
}