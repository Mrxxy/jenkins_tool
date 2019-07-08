import 'meta.dart';

class HistoryResp {
  Meta meta;
  List<HistoryBean> data;

  HistoryResp.fromJsonMap(Map<String, dynamic> map)
      : meta = Meta.fromJsonMap(map["meta"]),
        data = List<HistoryBean>.from(
            map["data"].map((it) => HistoryBean.fromJson(it)));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['meta'] = meta == null ? null : meta.toJson();
    data['data'] =
        data != null ? this.data.map((v) => v.toJson()).toList() : null;
    return data;
  }
}

class HistoryBean {
  String buildTime;
  String name;
  String pacUrl;
  int id;

  HistoryBean({this.buildTime, this.name, this.pacUrl, this.id});

  HistoryBean.fromJson(Map<String, dynamic> json) {
    this.buildTime = json['buildTime'];
    this.name = json['name'];
    this.pacUrl = json['pacUrl'];
    this.id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['buildTime'] = this.buildTime;
    data['name'] = this.name;
    data['pacUrl'] = this.pacUrl;
    data['id'] = this.id;
    return data;
  }
}
