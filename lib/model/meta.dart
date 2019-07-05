
class Meta {

  int errorCode;
  String errorMsg;
  String trackMsg;
  Object conditions;

	Meta.fromJsonMap(Map<String, dynamic> map): 
		errorCode = map["errorCode"],
		errorMsg = map["errorMsg"],
		trackMsg = map["trackMsg"],
		conditions = map["conditions"];

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['errorCode'] = errorCode;
		data['errorMsg'] = errorMsg;
		data['trackMsg'] = trackMsg;
		data['conditions'] = conditions;
		return data;
	}
}
