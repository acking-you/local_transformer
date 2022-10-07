import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_transform_tool/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/position/gf_toast_position.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/http_service.dart';
import '../storage/files_info_provider.dart';
import '../utils/info_notify.dart';
import '../utils/logger.dart';
import '../utils/platform.dart';
import '../utils/widgets.dart';

class DownloadPage extends StatelessWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var filesInfo = Provider.of<FilesInfoProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: kIsWeb?Text("点击文件进行下载"): Text("路径：${filesInfo.saveDir}"),
        centerTitle: kIsWeb?true:null,
        elevation: 12.0,
        actions: kIsWeb ?null:[
          IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: filesInfo.saveDir));
                ShowInfo("成功复制文件保存路径：${filesInfo.saveDir}", GFToastPosition.TOP,
                    context: context);
              },
              icon: const Icon(Icons.copy))
        ],
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
              for (final filename in filesInfo.downloadNames)
                buildFile(filename, context),
            ],
          ),
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
        ret = Colors.orangeAccent;
    }
    return ret;
  }

  onOpenFile(String filename, BuildContext context) {
    final info = context.read<FilesInfoProvider>();
    final filepath = '${info.saveDir}/$filename';
    if (Platforms.isMobile()) {
      OpenFile.open(filepath); //如果是移动平台则直接打开
    } else if (Platforms.isDesktop()) {
      //如果是桌面平台则复制对应的路径到剪切板
      Clipboard.setData(ClipboardData(text: filepath));
      log.d(filepath);
      ShowInfo("路径信息成功复制到剪切板：$filepath ", GFToastPosition.BOTTOM,
          context: context);
    }
  }

  Widget buildFile(String filename, BuildContext context) {
    var index = filename.lastIndexOf('.');
    String? ext;
    if (index != -1) {
      ext = filename.substring(index + 1);
    }
    final extension = ext ?? "none";
    final color = getColor(extension);
    final filesInfo = context.read<FilesInfoProvider>();

    return InkWell(
      onTap: () =>kIsWeb?launch('http://${filesInfo.serverIp}:$kRemoteServerPort/static/$filename') :onOpenFile(filename, context),
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
              filename,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            kIsWeb? const SizedBox(height: 10.0,): StreamBuilder(
                stream: HttpService.instance.getStream(filename),
                builder: (ctx, snapshot) {
                  if (snapshot.hasData) {
                    filesInfo.progressMapping[filename] =
                        snapshot.data as ProgressInfo;
                  }
                  var info = filesInfo.progressMapping[filename];
                  if(info != null&&info.count == info.total){
                    filesInfo.finishSet.add(filename); //下载已完成
                  }
                  return info == null
                      ? getProgressBar(0.0)
                      : getProgressWidget(info.count, info.total);
                }),
            kIsWeb?SizedBox():Center(
              child: IconButton(
                  iconSize: 24.0,
                  icon: Icon(Icons.download),
                  onPressed: () {
                    if(filesInfo.finishSet.contains(filename)){
                      ShowInfo("文件下载已经完成，请勿重复操作", GFToastPosition.TOP,context: context);
                      return;
                    }
                    if (filesInfo.transformSet.contains(filename)) {
                      filesInfo.cancel(filename);
                      filesInfo.transformSet.remove(filename);
                      return;
                    }
                    filesInfo.transformSet.add(filename);
                    if (filesInfo.serverIp.isEmpty) {
                      BotToast.showText(text: '暂未选择任何服务端');
                      return;
                    }
                    filesInfo.resetCancel(filename);
                    HttpService.instance
                        .downloadFile(filename, filesInfo.serverIp);
                  }),
            )
          ],
        ),
      ),
    );
  }

  String getSizeText(int size) {
    final kb = size / 1024;
    final mb = kb / 1024;
    final gb = mb / 1024;
    final tb = gb / 1024;
    var fileSize =
        mb >= 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
    if (gb >= 1) {
      fileSize = '${gb.toStringAsFixed(2)} GB';
    } else if (tb >= 1) {
      fileSize = '${tb.toStringAsFixed(2)} TB';
    }
    return fileSize;
  }

  Widget getProgressWidget(int count, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${getSizeText(count)}/${getSizeText(total)}'),
        getProgressBar(count / total),
      ],
    );
  }
}
