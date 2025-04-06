import 'package:flutter/material.dart';

/*when we need to parse API data. this class will helpfull it will give you easy
 access of data without using Map and if you see <T> in this class it will be any type,
its like dynamic, instead of creating new model for data output we use T, or any english Capital
alphabets you can use any like <B>*/
class DataOutput<T> {
  DataOutput({required this.total, required this.modelList, this.extraData});
  final int total;
  final List<T> modelList;
  final ExtraData? extraData;

  DataOutput<T> copyWith({
    int? total,
    int? offset,
    List<T>? modelList,
    ExtraData? extraData,
  }) {
    return DataOutput<T>(
      total: total ?? this.total,
      modelList: modelList ?? this.modelList,
      extraData: extraData ?? this.extraData,
    );
  }
}

@protected
class ExtraData<T> {
  ExtraData({
    required this.data,
  });
  final T data;
}
