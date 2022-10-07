import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FilesInfoProvider extends ChangeNotifier {
  var _fileInfos = <PlatformFile>[];
  VoidCallback? _callback;
  var _ip = "";
  bool _dragging = false;
  final _downloadNames = <String>[];
  final _cancelMapping = <String,CancelToken>{};
  var _savePath = "";
  final _finishSet = <String>{};

  Set<String> get finishSet => _finishSet;

  Map<String,CancelToken> get cancelMap => _cancelMapping;

  cancel(String id){
    final cancel = _cancelMapping[id];
   if(cancel != null&&!cancel.isCancelled){
     try{
       cancel.cancel();
     }on DioError catch(e){
      if(e.type == DioErrorType.cancel){
        BotToast.showText(text: "成功取消");
      }
     }
    }
  }

  void resetCancel(String id) {
    final cancel = _cancelMapping[id];
    if(cancel != null && !cancel.isCancelled){
      return;
    }
    _cancelMapping[id] = CancelToken();
    notifyListeners();
  }

  set callback(VoidCallback callback) => _callback = callback;

  List<String> get downloadNames =>_downloadNames;

  String get serverIp => _ip;

  List<PlatformFile> get fileInfos => _fileInfos;

  bool get dragging => _dragging;

  set savePath(String savePath) => _savePath = savePath;
  String get saveDir => _savePath;

  void changedDragging(bool state){
    _dragging = state;
    notifyListeners();
  }

  void changedFileNames(List<dynamic> filenames){
     for(final name in filenames){
        if(_downloadNames.contains(name)) {
         continue;
        }
        _downloadNames.add(name);
      }
     notifyListeners();
  }

  void changedServerIp(String ip){
   _ip  = ip;
   notifyListeners();
  }

  void changedFileInfos({required List<PlatformFile> fileInfos}){
    _fileInfos = fileInfos;
    notifyListeners();
  }
  final _progressMapping = <String,dynamic>{};
  final _transformSet = <String>{};
  Map<String,dynamic> get progressMapping => _progressMapping;
  Set<String> get transformSet => _transformSet;
}
