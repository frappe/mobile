class LinkFieldResponse {
  final String value;
  final String description;

  LinkFieldResponse({this.value, this.description});

  factory LinkFieldResponse.fromJson(Map<String, dynamic> json) {
    return LinkFieldResponse(
      value: json['value'],
      description: json['description'],
    );
  }
}

class DioLinkFieldResponse {
  final List<LinkFieldResponse> values;
  final String error;

  DioLinkFieldResponse(this.values, this.error);

  DioLinkFieldResponse.fromJson(Map<String, dynamic> json)
      : values = (json["results"] as List)
            .map((i) => new LinkFieldResponse.fromJson(i))
            .toList(),
        error = "";

  DioLinkFieldResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

class GetDocResponse {
  final List docs;
  final Map docInfo;

  GetDocResponse({
    this.docs,
    this.docInfo,
  });

  factory GetDocResponse.fromJson(json) {
    return GetDocResponse(
      docs: json['docs'],
      docInfo: json['docinfo'],
    );
  }
}

class DioGetDocResponse {
  final values;
  final String error;

  DioGetDocResponse(this.values, this.error);

  DioGetDocResponse.fromJson(json)
      : values = GetDocResponse.fromJson(json),
        error = "";

  DioGetDocResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

class GetMetaResponse {
  final List docs;
  final String userSettings;

  GetMetaResponse({
    this.docs,
    this.userSettings
  });

  factory GetMetaResponse.fromJson(json) {
    return GetMetaResponse(
      docs: json['docs'],
      userSettings: json['user_settings'],
    );
  }
}

class DioGetMetaResponse {
  final values;
  final String error;

  DioGetMetaResponse(this.values, this.error);

  DioGetMetaResponse.fromJson(json)
      : values = GetMetaResponse.fromJson(json),
        error = "";

  DioGetMetaResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}

class GetReportViewResponse {
  final List keys;
  final List values;

  GetReportViewResponse({
    this.keys,
    this.values,
  });

  factory GetReportViewResponse.fromJson(json) {
    if(json.length == 0) {
      return GetReportViewResponse(
        keys: [],
        values: [],
      );
    }
    return GetReportViewResponse(
      keys: json['keys'],
      values: json['values'],
    );
  }
}

class DioGetReportViewResponse {
  final values;
  final String error;

  DioGetReportViewResponse(this.values, this.error);

  DioGetReportViewResponse.fromJson(json)
      : values = GetReportViewResponse.fromJson(json["message"]),
        error = "";

  DioGetReportViewResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}