import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../utils/enums.dart';
import '../../datamodels/doctype_response.dart';
import '../../app/locator.dart';
import '../../form/controls/autocomplete.dart';
import '../../services/navigation_service.dart';

import '../../widgets/card_list_tile.dart';

import '../../views/add_tags/add_tags_viewmodel.dart';
import '../../views/base_view.dart';

class AddTags extends StatelessWidget {
  final String doctype;
  final String name;

  AddTags({
    Key key,
    @required this.doctype,
    @required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseView<AddTagsViewModel>(
      builder: (context, model, child) => model.state == ViewState.busy
          ? Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : WillPopScope(
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
                          doctypeField: DoctypeField(label: 'Add a tag ...'),
                          onSuggestionSelected: (item) async {
                            if (item != "") {
                              model.addTag(
                                doctype: doctype,
                                name: name,
                                tag: item,
                              );
                            }
                          },
                          suggestionsCallback: (query) async {
                            return await model.getTags(
                              doctype: doctype,
                              query: query,
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: _generateChildren(model),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  List<Widget> _generateChildren(AddTagsViewModel model) {
    List<Widget> children = [];
    if (model.newTags.isNotEmpty) {
      children = model.newTags.asMap().entries.map<Widget>((entry) {
        var idx = entry.key;
        var val = entry.value;
        return CardListTile(
          title: Text(val),
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              model.removeTag(
                doctype: doctype,
                idx: idx,
                name: name,
                tag: val,
              );
            },
          ),
        );
      }).toList();
    }

    return children;
  }

  _handleBack() {
    locator<NavigationService>().pop(true);
  }
}
