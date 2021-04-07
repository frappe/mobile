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
  String doctype;
  String fieldname;
  FilterOperator filterOperator;
  String value;

  Filter({this.doctype, this.fieldname, this.filterOperator, this.value});

  Filter.fromJson(Map<String, dynamic> json) {
    doctype = json['doctype'];
    fieldname = json['fieldname'];
    filterOperator = FilterOperator.fromJson(
      json['filterOperator'],
    );
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['doctype'] = this.doctype;
    data['fieldname'] = this.fieldname;
    data['filterOperator'] = this.filterOperator.toJson();
    data['value'] = this.value;
    return data;
  }
}
