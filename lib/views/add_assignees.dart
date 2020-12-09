import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../app/locator.dart';
import '../config/palette.dart';
import '../form/controls/link_field.dart';
import '../utils/enums.dart';

import '../services/navigation_service.dart';
import '../services/backend_service.dart';

import '../widgets/card_list_tile.dart';
import '../widgets/frappe_button.dart';
import '../widgets/user_avatar.dart';

class AddAssignees extends StatefulWidget {
  final String doctype;
  final String name;

  const AddAssignees({
    Key key,
    @required this.doctype,
    @required this.name,
  }) : super(key: key);

  @override
  _AddAssigneesState createState() => _AddAssigneesState();
}

class _AddAssigneesState extends State<AddAssignees> {
  var newAssignees = [];
  String selectedUser;

  List<Widget> _generateChildren() {
    List<Widget> children = [];
    if (newAssignees.isNotEmpty) {
      children = newAssignees.asMap().entries.map<Widget>((entry) {
        var idx = entry.key;
        var val = entry.value;
        return CardListTile(
          color: Palette.newIndicatorColor,
          leading: UserAvatar(uid: val),
          title: Text(val),
          trailing: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              newAssignees.removeAt(idx);
              setState(() {});
            },
          ),
        );
      }).toList();
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 4,
            ),
            child: FrappeFlatButton(
              onPressed: newAssignees.length > 0
                  ? () async {
                      await BackendService.addAssignees(
                        widget.doctype,
                        widget.name,
                        newAssignees,
                      );
                      locator<NavigationService>().pop(true);
                    }
                  : null,
              title: "Assign",
              buttonType: ButtonType.primary,
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: FormBuilder(
              child: LinkField(
                key: UniqueKey(),
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.white,
                doctype: 'User',
                refDoctype: 'Issue',
                hint: 'Assign To',
                onSuggestionSelected: (item) {
                  newAssignees.add(item["value"]);
                  selectedUser = null;
                  setState(() {});
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
    );
  }
}
