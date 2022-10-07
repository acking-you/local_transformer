import 'dart:io';


class Platforms{
  static bool isMobile(){
   return Platform.isIOS || Platform.isAndroid;
  }

  static bool isDesktop(){
    return  Platform.isLinux||Platform.isMacOS||Platform.isWindows;
  }
}