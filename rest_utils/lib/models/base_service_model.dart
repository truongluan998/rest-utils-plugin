abstract class BaseRequestModel {
  Map<String, dynamic> toJson();
}

abstract class BaseResponseModel<T> extends CommandResponseModel {
  final T? data;

  BaseResponseModel({this.data, int? statusCode, String? errorMessage, String? errorCode})
      : super(statusCode: statusCode, errorCode: errorCode, errorMessage: errorMessage);

  T fromJson(Map<String, dynamic> json);
}

class StringResponseModel extends BaseResponseModel<String> {
  StringResponseModel({String? data, int? statusCode})
      : super(data: data, statusCode: statusCode);

  @override
  String fromJson(Map<String, dynamic> json) {
    return json['body']?.toString() ?? '';
  }
}

class CommandResponseModel {
  int? statusCode;
  String? errorMessage;
  String? errorCode;

  bool get success => statusCode == 200;

  CommandResponseModel({this.statusCode = 200, this.errorCode = '', this.errorMessage = ''});
}