import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:file_transform_tool/storage/files_info_provider.dart';
import 'package:file_transform_tool/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/getwidget.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../constants.dart';

Widget getProgressBar(double percent) {
  return LayoutBuilder(
    builder: (ctx, cts) => GFProgressBar(
      percentage: percent,
      width: cts.maxWidth * 6 / 11,
      radius: 15,
      type: GFProgressType.linear,
      backgroundColor: Colors.black26,
      progressBarColor: GFColors.SUCCESS,
      trailing: Text(
        '%${(percent * 100).toStringAsFixed(2)}',
      ),
    ),
  );
}

Future getAlert(String text,
    {BuildContext? context, VoidCallback? onConfirm, VoidCallback? onCancel}) {
  var ctx = context ?? kNavigatorKey.currentState!.context;
  return AwesomeDialog(
          context: ctx,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: "消息",
          desc: text,
          btnCancelText: '取消',
          btnOkText: '确认',
          width: 400.0,
          dismissOnTouchOutside: false,
          btnCancelOnPress: onCancel,
          btnOkOnPress: onConfirm)
      .show();
}

Color _getColor(String ext) {
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

String getSize(int filesize) {
  final kb = filesize / 1024;
  final mb = kb / 1024;
  final gb = mb / 1024;
  final tb = gb / 1024;
  String ret;
  if (tb >= 1) {
    ret = '${tb.toStringAsFixed(2)} TB';
  } else if (gb >= 1) {
    ret = '${gb.toStringAsFixed(2)} GB';
  } else if (mb >= 1) {
    ret = '${mb.toStringAsFixed(2)} MB';
  } else {
    ret = '${kb.toStringAsFixed(2)} KB';
  }
  return ret;
}

onOpenFile(String filepath) {
  if (Platforms.isMobile()) {
    OpenFile.open(filepath); //如果是移动平台则直接打开
  } else {
    //如果是桌面平台则复制对应的路径到剪切板
    Clipboard.setData(ClipboardData(text: filepath));
    BotToast.showText(text: '路径信息成功复制 $filepath');
  }
}

Widget getFileInkWell({
  Stream? stream,
  Widget Function(BuildContext context, AsyncSnapshot<dynamic> snapshot)?
      onStream,
  String? filepath,
  int? filesize,
  String? filename,
  String? ext,
  IconData? icon,
  VoidCallback? onIconPressed,
}) {
  final extension = ext ?? "none";
  final color = _getColor(extension);

  return InkWell(
    onTap: filepath == null ? null : (){
      onOpenFile(filepath);
    },
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
            filename ?? extension,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          if (filesize != null)
            Text(
              getSize(filesize),
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          if (stream != null && onStream != null)
            StreamBuilder(
              stream: stream,
              builder: onStream,
            ),
          if (icon != null)
            Center(
                child: IconButton(
              iconSize: 24.0,
              icon: Icon(icon),
              onPressed: onIconPressed,
            ))
        ],
      ),
    ),
  );
}
