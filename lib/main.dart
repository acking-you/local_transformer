import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:file_transform_tool/pages/download_page.dart';
import 'package:file_transform_tool/pages/history_page.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import '../constants.dart';
import '../pages/upload_page.dart';
import '../storage/files_info_provider.dart';
import '../pages/files_page.dart';
import '../pages/home_page.dart';
import '../service/udp_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  UDPService.instance.start();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => FilesInfoProvider(),
      child: FilesystemPickerDefaultOptions(
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        theme: FilesystemPickerTheme(
          topBar: FilesystemPickerTopBarThemeData(
            backgroundColor: Colors.teal,
          ),
        ),
        child: MaterialApp(
          navigatorObservers: [BotToastNavigatorObserver()],
            builder: BotToastInit(),
            navigatorKey: kNavigatorKey,
            debugShowCheckedModeBanner: false,
            initialRoute: "/",
            routes: {
            '/': (context) => HomePage(),
            "/files_page": (ctx) => FilesPage(),
              "/upload_page":(_) => UploadPage(),
              "/download_page":(_)=> const DownloadPage(),
              "/history_page":(_) => const HistoryPage(),
          }
        ),
      ),
    );
  }
}



