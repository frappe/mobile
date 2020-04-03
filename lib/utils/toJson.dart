class Response {
  final String value;
  final String description;

  Response({this.value, this.description});

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      value: json['value'],
      description: json['description'],
    );
  }
}

class DioResponse {
  final List<Response> values;
  final String error;

  DioResponse(this.values, this.error);

  DioResponse.fromJson(Map<String, dynamic> json)
      : values = (json["results"] as List)
            .map((i) => new Response.fromJson(i))
            .toList(),
        error = "";

  DioResponse.withError(String errorValue)
      : values = List(),
        error = errorValue;
}