import 'package:ebroker/utils/Extensions/lib/adaptive_type.dart';

class InterestedUserModel {
  InterestedUserModel({
    this.id,
    this.name,
    this.image,
    this.email,
    this.mobile,
    this.customertotalpost,
    this.runtimeTypeLog,
  });

  InterestedUserModel.fromJson(Map<String, dynamic> json) {
    try {
      id = Adapter.forceInt(json['id']);
      name = json['name'];
      image = json['profile'] ?? '';
      email = json['email'];
      mobile = json['mobile'];
      customertotalpost = json['customertotalpost'];
      runtimeTypeLog =
          json.map((key, value) => MapEntry(key, value.runtimeType)).toString();
    } catch (e) {
      runtimeTypeLog =
          json.map((key, value) => MapEntry(key, value.runtimeType)).toString();
    }
  }
  int? id;
  String? name;
  String? image;
  String? email;
  String? mobile;
  int? customertotalpost;
  String? runtimeTypeLog;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['profile'] = image;
    data['email'] = email;
    data['mobile'] = mobile;
    data['customertotalpost'] = customertotalpost;
    return data;
  }
}
