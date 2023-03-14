abstract class BaseRequestModel {
  Map<String, dynamic> toJson();
}

abstract class BaseResponseModel<T> extends CommandResponseModel {
  T fromJson(Map<String, dynamic> json);
}

class StringResponseModel extends BaseResponseModel<String> {
  String? body;

  @override
  String fromJson(Map<String, dynamic> json) => '';
}

class CommandResponseModel {
  int? statusCode;

  String? errorMessage;

  String? errorCode;

  bool get success => statusCode == 200;

  CommandResponseModel({ this.statusCode = 200, this.errorCode = '', this.errorMessage = '' });
}