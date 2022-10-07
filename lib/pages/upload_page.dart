import 'dart:io';
import 'dart:typed_data';

import 'package:bot_toast/bot_toast.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_transform_tool/utils/platform.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../storage/files_info_provider.dart';
import '../utils/logger.dart';



class UploadPage extends StatelessWidget {
  CancelFunc? cancelFunc;

  @override
  Widget build(BuildContext context) {
    final fileInfo = context.watch<FilesInfoProvider>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Icon(Icons.arrow_back),
                backgroundColor: Colors.blueAccent,
              ),
            ),
            DropTarget(
                onDragEntered: (detail) {
                  fileInfo.changedDragging(true);
                },
                onDragExited: (_){
                  fileInfo.changedDragging(false);
                },
                onDragDone: (detail) {
                  onDragDone(
                    detail,context
                  );
                },
                child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Container(
                          color: fileInfo.dragging ? Colors.grey.withOpacity(0.2) : Colors.white,
                          child: Container(
                            width: MediaQuery.of(context).size.width*4/5,
                            height: MediaQuery.of(context).size.height*3/7,
                            decoration: DottedDecoration(
                              color: Colors.blue,
                              shape: Shape.box,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(24)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  color: Colors.blue,
                                  size: 60.0,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                TextButton(
                                    onPressed: () {
                                      onOpenFiles(context);
                                    },
                                    child: Text(
                                      "选择本地文件",
                                      style: TextStyle(fontSize: 30.0),
                                    ))
                              ],
                            ),
                          ),
                        ),
                      ))
          ],
        ),
      ),
    );
  }

  void showLoading(){
   cancelFunc = BotToast.showLoading();
  }
  void cancelLoading(){
    if(cancelFunc!=null){
      cancelFunc!();
    }
  }

  void onOpenFiles(BuildContext context) async {
     final result = await FilePicker.platform.pickFiles(allowMultiple: true,onFileLoading: (FilePickerStatus status){
       if(kIsWeb){
         BotToast.showText(text: "正在把内容拷贝到内存");
         return;
       }
      if(status == FilePickerStatus.picking){
        BotToast.showText(text: "正在把选择的文件拷贝到临时目录中");
        showLoading();
      }else if(status == FilePickerStatus.done){
        cancelLoading();
      }
     });
     if (result == null) {
       BotToast.showText(text: "获取文件路径错误");
       return;
     }
     final files = result.files;
    log.d("files-chosen:${files.length}");

    var f = context.read<FilesInfoProvider>();
    f.changedFileInfos(fileInfos: files);
    Navigator.of(context).pushNamed("/files_page");
  }

  void onDragDone(DropDoneDetails detail,BuildContext context) async {
    List<PlatformFile> newFiles = [];

    for (final file in detail.files) {
      final size = await file.length();
      Uint8List? data;
      if(kIsWeb) data = await file.readAsBytes();
      newFiles.add(PlatformFile(path: file.path, name: file.name, size: size,bytes: data));
    }

    var f = context.read<FilesInfoProvider>();
    f.changedFileInfos(fileInfos: newFiles);
    Navigator.of(context).pushNamed("/files_page");
  }
}
