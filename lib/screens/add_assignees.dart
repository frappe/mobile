import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/form/controls/link_field.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/widgets/card_list_tile.dart';
import 'package:frappe_app/widgets/frappe_button.dart';
import 'package:frappe_app/widgets/user_avatar.dart';

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
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);
  }

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
                      await backendService.addAssignees(
                        widget.doctype,
                        widget.name,
                        newAssignees,
                      );
                      Navigator.of(context).pop(true);
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
                prefixIcon: Icon(Icons.search),
                fillColor: Colors.white,
                doctype: 'User',
                refDoctype: 'Issue',
                hint: 'Assign To',
                onSuggestionSelected: (item) {
                  if (item != "") {
                    newAssignees.add(item["value"]);
                    setState(() {});
                  }
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
