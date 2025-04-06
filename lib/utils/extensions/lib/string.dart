import 'dart:developer' as d;

import 'package:ebroker/exports/main_export.dart';

extension StringExtensiton on String {
  void get logg {
    if (Constant.terminalLogMode == 'debug') {
      d.log(this);
    } else {}
  }

  void log([String? name]) {
    if (Constant.terminalLogMode == 'debug') {
      d.log(this, name: name ?? '');
    } else {}
  }
}

extension OB on Object {
  void get logg {
    if (Constant.terminalLogMode == 'debug') {
      d.log(toString());
    } else {}
  }

  void mlog([String? name]) {
    if (Constant.terminalLogMode == 'debug') {
      d.log(toString(), name: name ?? '');
    } else {}
  }
}
