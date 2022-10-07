
import 'package:bot_toast/bot_toast.dart';
import 'package:file_transform_tool/utils/info_notify.dart';
import 'package:file_transform_tool/utils/logger.dart';
import 'package:file_transform_tool/service/http_service.dart';
import 'package:file_transform_tool/storage/files_info_provider.dart';
import 'package:file_transform_tool/utils/platform.dart';
import 'package:file_transform_tool/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getwidget/getwidget.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  String? getFileExt(String filename){
    final idx =  filename.lastIndexOf('.');
    if(idx == -1){
      return null;
    }
    return filename.substring(idx+1);
  }

  bool getFileType(String filename){
    return filename.contains('/') || filename.contains('\\');
  }

  String getPath(String savePath,String filename){
    if(getFileType(filename)){
      return filename;
    }
    return '$savePath/$filename';
  }
  
  String getFilename(String filename){
    if(!getFileType(filename)){
      return filename; 
    }
    int idx = filename.lastIndexOf('/');
    if(idx == -1) idx = filename.lastIndexOf('\\');
    return filename.substring(idx+1);
  }

  

  @override
  Widget build(BuildContext context) {
    final info = context.read<FilesInfoProvider>();
    final union = <String>{};
    union.addAll(info.transformSet);
    union.addAll(info.finishSet);
    return Scaffold(
      appBar: AppBar(
        title: Text('文件传输状态'),
        centerTitle: true,
      ),
      body: GridView.extent(maxCrossAxisExtent: 354.0,
      children: [
        for(final item in union)
          getFileInkWell(
            ext: getFileExt(item),
            icon: getFileType(item)?Icons.upload:Icons.download,
            filename: getFilename(item),
            stream: HttpService.instance.getStream(item),
           filepath: getPath(info.saveDir, item),
            onStream: (ctx,snapshot){
              if(getFileType(item)){
                return onUpload(snapshot,item,info.progressMapping);
              }else{
                return onDownload(snapshot,item,info.progressMapping);
              }
            }
          ),
        ],
      ),
    );
  }

  Widget onUpload(AsyncSnapshot<dynamic> snapshot,String id,Map<String,dynamic> progress) {
    if (snapshot.hasData) {
      progress[id] =
      snapshot.data as double;
    }
    double percent = 0.0;
    var c = progress[id];
    if(c != null){
      percent = c;
    }
    if(percent.toInt() == 1){
      BotToast.showText(text: '上传$id完成');
    }

    return getProgressBar(percent);
  }

  Widget onDownload(AsyncSnapshot<dynamic> snapshot,String id,Map<String,dynamic> progress) {
    if (snapshot.hasData) {
      progress[id] =
      snapshot.data as ProgressInfo;
    }
    var info = progress[id];
    if(info != null && info.count == info.total){
      BotToast.showText(text: '下载 $id 完成');
    }
    return info==null?getProgressBar(0.0):getProgressWidget(info.count, info.total);
  }

  Widget getProgressWidget(int count, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${getSize(count)}/${getSize(total)}'),
        getProgressBar(count / total),
      ],
    );
  }
}
