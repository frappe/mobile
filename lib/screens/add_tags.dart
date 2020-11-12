import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/form/controls/autocomplete.dart';

import '../services/backend_service.dart';
import '../widgets/card_list_tile.dart';

class AddTags extends StatefulWidget {
  final String doctype;
  final String name;

  const AddTags({
    Key key,
    @required this.doctype,
    @required this.name,
  }) : super(key: key);

  @override
  _AddTagsState createState() => _AddTagsState();
}

class _AddTagsState extends State<AddTags> {
  var newTags = [];

  List<Widget> _generateChildren() {
    List<Widget> children = [];
    if (newTags.isNotEmpty) {
      children = newTags.asMap().entries.map<Widget>((entry) {
        var idx = entry.key;
        var val = entry.value;
        return CardListTile(
          title: Text(val),
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              newTags.removeAt(idx);
              BackendService.removeTag(
                widget.doctype,
                widget.name,
                val,
              );
              setState(() {});
            },
          ),
        );
      }).toList();
    }

    return children;
  }

  _handleBack() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () {
              _handleBack();
            },
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: FormBuilder(
                child: AutoComplete(
                  key: UniqueKey(),
                  prefixIcon: Icon(Icons.search),
                  fillColor: Colors.white,
                  hint: 'Add a tag ...',
                  onSuggestionSelected: (item) async {
                    if (item != "") {
                      var addedTag = await BackendService.addTag(
                        widget.doctype,
                        widget.name,
                        item,
                      );
                      setState(() {
                        newTags.insert(0, addedTag["message"]);
                      });
                    }
                  },
                  suggestionsCallback: (query) async {
                    var lowercaseQuery = query.toLowerCase();
                    var response = await BackendService.getTags(
                      widget.doctype,
                      lowercaseQuery,
                    );

                    return response["message"];
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: _generateChildren(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
