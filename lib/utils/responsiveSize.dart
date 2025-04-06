// ignore_for_file: file_names

import 'package:flutter/material.dart';

//Warning Don't Edit or change this file otherwise your whole UI will get error

extension Sizing on num {
  ///Responsive height
  double rh(context) {
    //!Don't change [812]
    const aspectedScreenHeight = 812;

    final size = MediaQuery.of(context).size;
    final responsiveHeight = size.height * (this / aspectedScreenHeight);
    return responsiveHeight;
  }

  ///Responsive width
  double rw(context) {
    //!Don't change  [375]
    const aspectedScreenWidth = 375;

    final size = MediaQuery.of(context).size;
    final responsiveWidth = size.width * (this / aspectedScreenWidth);
    return responsiveWidth;
  }

  ///Responsive font
  double rf(context) {
    const aspectedScreenHeight = 812;
    return (this / aspectedScreenHeight) * MediaQuery.of(context).size.height;
  }
}
