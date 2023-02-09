// This is a Model for CSRF Token

class CSRF {
  String? parameterName;
  String? headerName;
  String? token;

  CSRF(
      {required this.parameterName,
      required this.headerName,
      required this.token});

  CSRF.empty();

  factory CSRF.fromJson(Map<String, dynamic> json) {
    return CSRF(
      parameterName: json['parameterName'],
      headerName: json['headerName'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson(CSRF csrf) {
    return {
      "parameterName": csrf.parameterName,
      "headerName": csrf.headerName,
      "token": csrf.token
    };
  }

  @override
  String toString() {
    return 'CSRF{parameterName: $parameterName,'
        ' headerName: $headerName,'
        ' token: $token,'
        '}';
  }
}
