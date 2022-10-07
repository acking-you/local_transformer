import 'dart:async';
import 'dart:typed_data';
import 'package:bot_toast/bot_toast.dart';

import 'package:dio/dio.dart';
import 'package:file_transform_tool/storage/files_info_provider.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../utils/logger.dart';

class ProgressInfo{
  int count;
  int total;
  ProgressInfo(this.count,this.total);
}

class HttpService{
  static final instance = HttpService._internal();
  final _httpStream = <String,StreamController>{};
  HttpService._internal();

  StreamController _getController(String filepath){
     var controller = _httpStream[filepath];
    if(controller == null){
      controller = StreamController.broadcast();
      _httpStream[filepath] = controller;
    }
    return controller;
  }

  Stream getStream(String filepath){
    return _getController(filepath).stream;
  }
  _showError(String error){
   BotToast.showText(text: error,);
  }

  uploadFileByBytes(String id,Uint8List bytes,String ip) async {
    final formData = FormData.fromMap({
      "files": MultipartFile.fromBytes(bytes)
    });
    try{
      final info = kNavigatorKey.currentState!.context.read<FilesInfoProvider>();
      String reqUrl = 'http://$ip:$kRemoteServerPort/transform/file';
      log.d(reqUrl );
      log.d(bytes.length);

      final resp = await Dio().post(reqUrl,data: formData,
          cancelToken: info.cancelMap[id],
          onSendProgress:(cnt,tot){
            final percent = cnt / tot;
            _getController(id).sink.add(percent);
          });
      BotToast.showText(text: resp.data["status_msg"]);
    }on DioError catch(e){
      log.d("上传文件出错 $e");
      if(e.type == DioErrorType.cancel){
       _showError("取消上传成功，暂不支持断点续传");
       return;
     }
      _showError("内部网络出错");
    }
  }

  uploadFile(String filepath,String ip)async{
    final formData = FormData.fromMap({
     "files": await MultipartFile.fromFile(filepath)
    });
    try{
      final info = kNavigatorKey.currentState!.context.read<FilesInfoProvider>();
    final resp = await Dio().post(
      cancelToken:info.cancelMap[filepath],
        'http://$ip:$kRemoteServerPort/transform/file',data: formData,
       onSendProgress:(cnt,tot){
        final percent = cnt / tot;
        _getController(filepath).sink.add(percent);
       });
    BotToast.showText(text: resp.data["status_msg"]);
    }on DioError catch(e){
     log.d("上传文件出错 $e");
     if(e.type == DioErrorType.cancel){
       _showError("取消上传成功，暂不支持断点续传");
       return;
     }
     _showError("内部网络出错");
    }
  }

  getFileList(String ip)async {
    try{
    final rep = await Dio().get('http://$ip:$kRemoteServerPort/transform/files');
    if(rep.data["status_code"] == 0){
      final list = rep.data["list_msg"] as List<dynamic>;
      final f = kNavigatorKey.currentState!.context.read<FilesInfoProvider>();
      f.changedFileNames(list);
    }else if(rep.data["status_code"]){
      _showError(rep.data["list_msg"][0]);
    }
    }on DioError catch(e){
     log.d(e);
     _showError('ip无效');
    }
  }

  downloadFile(String filename,String ip){
    final info = kNavigatorKey.currentState!.context.read<FilesInfoProvider>();
    String dir = info.saveDir;
    try{
    if(dir.isEmpty){
      _showError("保存路径为空无法下载");
      return;
    }
    String url = 'http://$ip:$kRemoteServerPort/static/$filename';
    String savePath = '$dir/$filename';
    Dio().download(url, savePath,
    cancelToken: info.cancelMap[filename],
    onReceiveProgress: (count,total){
      _getController(filename).sink.add(ProgressInfo(count, total));
    });
    }on DioError catch(e){
      if(e.type == DioErrorType.cancel){
       _showError("取消下载成功，暂不支持分块下载");
       return;
     }
      _showError("网络请求出错");
      log.d('$e');
    }
  }
}