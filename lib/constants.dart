
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

GlobalKey<NavigatorState> kNavigatorKey = GlobalKey();

const kLocalBindPort = 5666;
const kRemoteServerPort = 8888;

const kOuterBoxDecoration = BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        stops: [0.0, 1.0],
        colors: [Color(0xffbc95c6), Color(0xff7dc4cc)]));
