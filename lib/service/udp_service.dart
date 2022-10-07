import 'dart:async';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../storage/files_info_provider.dart';
import '../utils/logger.dart';
import '../utils/widgets.dart';

class UDPService{
  static UDPService instance = UDPService._internal();
  var _cacheServerIp = "";
  RawDatagramSocket? _bindSocket;


  UDPService._internal();
  runWeb(){
    final controller  = TextEditingController();
     Future.delayed(const Duration(seconds: 2), () {
         AwesomeDialog(
           width: 420.0,
           context: kNavigatorKey.currentState!.context,
           dialogType: DialogType.success,
           btnOkText: '确认',
           btnCancelText: '取消',
           btnOkOnPress: (){
             final info = kNavigatorKey.currentState!.context.read<FilesInfoProvider>();
             info.changedServerIp(controller.text);
           },
           btnCancelOnPress: (){
             runWeb();
           },
           body: Padding(
             padding: const EdgeInsets.all(20.0),
             child: TextField(
               decoration: InputDecoration(
                 hintText: '默认使用本服务器IP',
                 labelText: '请输入需要下载的IP',
               ),
                controller: controller,
             ),
           ),
         )..show();
      });
  }
  start() async {
    if(kIsWeb){
      runWeb();
    }
    else{
      _bindSocket = await RawDatagramSocket.bind("0.0.0.0", kLocalBindPort);
      _bindSocket?.listen(_onEvent);
    }
  }
  bool _nullCheck(){
    if(_bindSocket == null)
      {
       log.e("_bindSocket null");
       return false;
      }
    return true;
  }

  _onEvent(event){
    switch(event){
      case RawSocketEvent.read:
        {
          if(_nullCheck()){
            var data = _bindSocket?.receive();
            final ipAddr = '${data?.address.address}';
            if(_cacheServerIp == ipAddr){
              log.d('本服务IP正在被使用');
              break;
            }
            log.d(ipAddr);
            _cacheServerIp = ipAddr;
            getAlert('检测到本地服务 ${data?.address.address}:$kRemoteServerPort，是否加入？',
                onCancel: (){
              _cacheServerIp = ""; //恢复未选择状态
            },
                onConfirm: (){
                  var filesInfo =kNavigatorKey.currentState!.context.read<FilesInfoProvider>();
                  filesInfo.changedServerIp(ipAddr);
            });
          }
        }
    }
  }
}