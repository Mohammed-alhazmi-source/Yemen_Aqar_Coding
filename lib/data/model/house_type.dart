import 'package:ebroker/utils/api.dart';

class HouseType {
  HouseType({this.id, this.type});

  HouseType.fromJson(Map<String, dynamic> json) {
    id = json[Api.id].toString();
    type = json[Api.type];
  }
  String? id;
  String? type;
}
