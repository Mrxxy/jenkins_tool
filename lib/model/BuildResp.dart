import 'package:jenkins_tool/model/ProjectBean.dart';
import 'package:jenkins_tool/model/meta.dart';

class BuildResp {
  Meta meta;

  BuildResp.fromJsonMap(Map<String, dynamic> map)
      : meta = Meta.fromJsonMap(map["meta"]);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['meta'] = meta == null ? null : meta.toJson();
  }
}
