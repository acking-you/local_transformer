import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_transform_tool/service/http_service.dart';
import 'package:file_transform_tool/utils/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../storage/files_info_provider.dart';
import '../utils/logger.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: kOuterBoxDecoration,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80.0,vertical: 10.0),
                child: GFButton(
                  color: Colors.white,
                  elevation: 12.0,
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                  fullWidthButton: true,
                  onPressed: (){
                    if(kIsWeb){
                      onWeb();
                      return;
                    }
                    Navigator.of(context).pushNamed("/upload_page");
                  },
                  size: 70.0,
                  text: kIsWeb?"软件下载":"文件上传",
                  textStyle: TextStyle(
                    fontSize: 30.0,
                    color: Color(0xff96c6ba),
                  ),
                  icon: Icon(Icons.upload_file_sharp),
                ),

              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80.0,vertical: 10.0),
                child: GFButton(
                  color: Colors.white,
                  elevation: 12.0,
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                  fullWidthButton: true,
                  onPressed: (){
                    onDownload();
                  },
                  size: 70.0,
                  text: "文件下载",
                  textStyle: TextStyle(
                    fontSize: 30.0,
                    color: Color(0xffcc7fc3),
                  ),
                  icon: Icon(Icons.download_for_offline_rounded),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80.0,vertical: 10.0),
                child: GFButton(
                  color: Colors.white,
                  elevation: 12.0,
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                  fullWidthButton: true,
                  onPressed: (){
                    Navigator.of(context).pushNamed('/history_page');
                  },
                  size: 70.0,
                  text: "下载上传状态",
                  textStyle: TextStyle(
                    fontSize: 30.0,
                    color: Color(0xff7fcc88),
                  ),
                  icon: Icon(Icons.history),
                ),
              ),
            ],
          )
        ));
  }



  onDownload() async {
    final info = context.read<FilesInfoProvider>();
    if(info.serverIp.isEmpty){
      BotToast.showText(text: "服务器未连接");
      return;
    }
    await HttpService.instance.getFileList(info.serverIp);
    if(!kIsWeb) {
      //设置本地下载的目录
      String dir = '';
      if(Platform.isAndroid) {
        dir = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
        dir += '/transform_tool';
      }else if(Platform.isIOS){
        final tmp = await getTemporaryDirectory();
        dir = tmp.path;
      } else{
        final tmp = await getDownloadsDirectory();
        dir = tmp!.path;
      }
      info.savePath = dir;
    }

    log.d(info.downloadNames);
    Navigator.of(context).pushNamed("/download_page");
  }

  void onWeb() {
      AwesomeDialog(
        context: context,
        animType: AnimType.scale,
        dialogType: DialogType.success,
        body: Column(
          children: [
            getWebLinkItem("移动端APP(安卓)", '/soft/app.apk'),
            getWebLinkItem('桌面端(Windows)', '/soft/windows.zip')
          ],
        )
      ).show();
  }

  Widget getWebLinkItem(String filename,String link){
    return SizedBox(
      width: 250.0,
      height: 200.0,
      child: InkWell(
        onTap: () =>launch(link),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.green, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    filename,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(
                height: 5.0,
              ),
              Text(
                filename,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
           ],
          ),
        ),
      ),
    );
  }
}