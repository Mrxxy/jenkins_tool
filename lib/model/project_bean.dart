
class ProjectBean {

  int nextBuildNumber;
  String currentBuildTime;
  int lastSuccessNumber;
  String name;
  String fullName;
  int currentBuildNumber;
  String pacUrl;

	ProjectBean.fromJsonMap(Map<String, dynamic> map): 
		nextBuildNumber = map["nextBuildNumber"],
		currentBuildTime = map["currentBuildTime"],
		lastSuccessNumber = map["lastSuccessNumber"],
		name = map["name"],
		fullName = map["fullName"],
		currentBuildNumber = map["currentBuildNumber"],
		pacUrl = map["pacUrl"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['nextBuildNumber'] = nextBuildNumber;
		data['currentBuildTime'] = currentBuildTime;
		data['lastSuccessNumber'] = lastSuccessNumber;
		data['name'] = name;
		data['fullName'] = fullName;
		data['currentBuildNumber'] = currentBuildNumber;
		data['pacUrl'] = pacUrl;
		return data;
	}
}
