// @dart=2.9

import 'package:file_picker/file_picker.dart';
import 'package:frappe_app/model/doctype_response.dart';

class FilterOperator {
  String label;
  String value;

  FilterOperator({this.label, this.value});

  FilterOperator.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['value'] = this.value;
    return data;
  }
}

class Filter {
  DoctypeField field;
  FilterOperator filterOperator;
  String value;

  Filter({
    this.filterOperator,
    this.value,
    this.field,
  });

  Filter.fromJson(Map<String, dynamic> json) {
    filterOperator = FilterOperator.fromJson(
      json['filterOperator'],
    );
    field = DoctypeField.fromJson(
      json['field'],
    );
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filterOperator'] = this.filterOperator.toJson();
    data['field'] = this.field.toJson();
    data['value'] = this.value;
    return data;
  }
}

class FrappeFile {
  bool isPrivate;
  PlatformFile file;

  FrappeFile({
    this.isPrivate = true,
    this.file,
  });
}
