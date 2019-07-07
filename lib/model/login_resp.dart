import 'meta.dart';

class LoginResp {
  Meta meta;
  String data;

  LoginResp.fromJsonMap(Map<String, dynamic> map)
      : data = map['data'],
        meta = Meta.fromJsonMap(map["meta"]);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['meta'] = meta == null ? null : meta.toJson();
    map['data'] = data;
    return map;
  }
}
