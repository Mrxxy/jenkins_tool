import 'package:jenkins_tool/model/meta.dart';

class CheckUpdateResp {
  Meta meta;
  UpdateBean data;

  CheckUpdateResp.fromJsonMap(Map<String, dynamic> map)
      : meta = Meta.fromJsonMap(map["meta"]),
        data = UpdateBean.fromJsonMap(map["data"]);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['meta'] = meta == null ? null : meta.toJson();
    map['data'] = data == null ? null : data.toJson();
    return map;
  }
}

class UpdateBean {
  int updateFlag;
  String desc;
  String currVersion;
  String url;

  UpdateBean.fromJsonMap(Map<String, dynamic> map)
      : updateFlag = map["updateFlag"],
        desc = map["desc"],
        currVersion = map["currVersion"],
        url = map["url"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['updateFlag'] = updateFlag;
    data['desc'] = desc;
    data['currVersion'] = currVersion;
    data['url'] = url;
    return data;
  }
}
