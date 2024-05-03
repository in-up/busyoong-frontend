import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> init() async {
  await initializeDateFormatting();
}