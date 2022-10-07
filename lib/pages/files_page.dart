import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../service/http_service.dart';
import '../storage/files_info_provider.dart';
import '../utils/info_notify.dart';
import '../utils/logger.dart';
import '../utils/platform.dart';
import '../utils/widgets.dart';

class FilesPage extends StatefulWidget {
  FilesPage({Key? key}) : super(key: key);

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  @override
  Widget build(BuildContext context) {
    var filesInfo = Provider.of<FilesInfoProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("All Files"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.0),
          alignment: Alignment.center,
          constraints: BoxConstraints(maxWidth: 1200.0),
          child: GridView.extent(
              maxCrossAxisExtent: 354.0,
              childAspectRatio: 0.8,
              children: [
                for (final file in filesInfo.fileInfos) kIsWeb?buildFileOnWeb(file):buildFile(file)
              ]),
        ),
      ),
    );
  }

  Color getColor(String ext) {
    Color ret = Colors.grey;
    switch (ext) {
      case "pdf":
        ret = Colors.red;
        break;
      case "mp3":
      case "flac":
      case "wav":
        ret = Colors.pink;
        break;
      case "mp4":
        ret = Colors.blue;
        break;
      case "txt":
        ret = Colors.green;
        break;
      case "png":
      case "jpg":
      case "jpeg":
      case "bmp":
      case "ppt":
      case "pptx":
        ret = Colors.orange;
        break;
      case "tar":
      case "tgz":
      case "zip":
        ret = Colors.yellow;
    }
    return ret;
  }

  onOpenFile(PlatformFile file) {
    if (Platforms.isMobile()) {
      OpenFile.open(file.path!); //如果是移动平台则直接打开
    } else {
      //如果是桌面平台则复制对应的路径到剪切板
      Clipboard.setData(ClipboardData(text: file.path));
      log.d(file.path);
      ShowInfo("路径信息成功复制到剪切板：${file.path} ", GFToastPosition.BOTTOM,
          context: context);
    }
  }

  Widget buildFileOnWeb(PlatformFile file){
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final gb = mb / 1024;
    final tb = gb / 1024;
    var fileSize =
    mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
    if (gb >= 1) {
      fileSize = '${gb.toStringAsFixed(2)} GB';
    }
    if (tb >= 1) {
      fileSize = '${tb.toStringAsFixed(2)} TB';
    }
    String id = 'upload_file/${file.name}';


    final extension = file.extension ?? "none";
    final color = getColor(extension);
    final filesInfo = context.read<FilesInfoProvider>();

    return InkWell(
      onTap: () => launch('http://${filesInfo.serverIp}:$kRemoteServerPort/static/${file.name}'),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  ".$extension",
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              file.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              fileSize,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            StreamBuilder(
                stream: HttpService.instance.getStream(id),
                builder: (ctx, snapshot) {
                  if (snapshot.hasData) {
                    filesInfo.progressMapping[id] =
                    snapshot.data as double;
                  }
                  var percent = filesInfo.progressMapping[id];
                  return getProgressBar(percent ?? 0.0);
                }),
            Center(
              child: IconButton(
                  iconSize: 24.0,
                  icon: const Icon(Icons.upload),
                  onPressed: () {
                    if (filesInfo.transformSet.contains(id)) {
                      ShowInfo("该文件已尝试上传过", GFToastPosition.TOP,
                          context: context);
                      return;
                    }
                    filesInfo.transformSet.add(id);
                    if (filesInfo.serverIp.isEmpty) {
                      BotToast.showText(text: '暂未选择任何服务端');
                      return;
                    }
                    if(file.bytes == null){
                     BotToast.showText(text: '文件数据加载出错无法进行上传');
                     return;
                    }
                    HttpService.instance
                            .uploadFileByBytes(id,file.bytes!, filesInfo.serverIp);
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget buildFile(PlatformFile file) {
    final kb = file.size / 1024;
    final mb = kb / 1024;
    final gb = mb / 1024;
    final tb = gb / 1024;
    var fileSize =
        mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
    if (gb >= 1) {
      fileSize = '${gb.toStringAsFixed(2)} GB';
    }
    if (tb >= 1) {
      fileSize = '${tb.toStringAsFixed(2)} TB';
    }
    String filepath = file.path!;

    final extension = file.extension ?? "none";
    final color = getColor(extension);
    final filesInfo = context.read<FilesInfoProvider>();

    return InkWell(
      onTap: () => onOpenFile(file),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  ".$extension",
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(
              file.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              fileSize,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            StreamBuilder(
                stream: HttpService.instance.getStream(filepath),
                builder: (ctx, snapshot) {
                  if (snapshot.hasData) {
                    filesInfo.progressMapping[filepath] =
                        snapshot.data as double;
                  }
                  double percent = 0.0;
                   var c = filesInfo.progressMapping[filepath];
                  if(c != null){
                   percent = c;
                  }
                  if(percent.toInt() == 1){
                    filesInfo.finishSet.add(filepath);
                  }
                  return getProgressBar(percent);
                }),
            Center(
              child: IconButton(
                  iconSize: 24.0,
                  icon: Icon(Icons.upload),
                  onPressed: () {
                    if(filesInfo.finishSet.contains(filepath)){
                      ShowInfo("上传已经完成,请勿重复", GFToastPosition.TOP,context: context);
                      return;
                    }
                    if (filesInfo.transformSet.contains(filepath)) {
                      filesInfo.cancel(filepath);
                      filesInfo.transformSet.remove(filepath);
                      return;
                    }
                    filesInfo.transformSet.add(filepath);
                    if (filesInfo.serverIp.isEmpty) {
                      BotToast.showText(text: '暂未选择任何服务端');
                      return;
                    }
                    filesInfo.resetCancel(filepath);
                    if(filepath.isEmpty){
                      if(file.bytes != null) {
                        HttpService.instance
                          .uploadFileByBytes(filepath,file.bytes!, filesInfo.serverIp);
                      }else{
                        HttpService.instance
                            .uploadFile(file.path!, filesInfo.serverIp);
                      }
                    }else{
                      HttpService.instance
                        .uploadFile(filepath, filesInfo.serverIp);
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
