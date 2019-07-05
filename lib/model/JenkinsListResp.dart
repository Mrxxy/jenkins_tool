import 'package:jenkins_tool/model/ProjectBean.dart';
import 'package:jenkins_tool/model/meta.dart';

class JenkinsListResp {

  Meta meta;
  List<ProjectBean> data;

	JenkinsListResp.fromJsonMap(Map<String, dynamic> map): 
		meta = Meta.fromJsonMap(map["meta"]),
		data = List<ProjectBean>.from(map["data"].map((it) => ProjectBean.fromJsonMap(it)));

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['meta'] = meta == null ? null : meta.toJson();
		data['data'] = data != null ? 
			this.data.map((v) => v.toJson()).toList()
			: null;
		return data;
	}
}
