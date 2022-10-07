import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import '../constants.dart';

ShowInfo(String info, GFToastPosition position,{BuildContext? context}) {
  final ctx = context?? kNavigatorKey.currentState!.context;
  GFToast.showToast(info,ctx,
      toastPosition: position,
      textStyle: TextStyle(fontSize: 16, color: GFColors.DARK),
      backgroundColor: GFColors.LIGHT,
      trailing: Icon(
        Icons.notifications,
        color: GFColors.SUCCESS,
      ));
}
