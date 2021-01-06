import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frappe_app/datamodels/doctype_response.dart';

import 'base_control.dart';
import 'base_input.dart';

class FormBuilderBarcode extends StatefulWidget {
  final DoctypeField doctypeField;
  final Map doc;
  final bool readOnly;
  final InputDecoration decoration;
  final ValueTransformer valueTransformer;
  final ValueChanged onChanged;
  final FormFieldSetter onSaved;

  FormBuilderBarcode({
    Key key,
    @required this.doctypeField,
    this.doc,
    this.readOnly = false,
    this.decoration = const InputDecoration(),
    this.valueTransformer,
    this.onChanged,
    this.onSaved,
  }) : super(key: key);

  @override
  _FormBuilderBarcodeState createState() => _FormBuilderBarcodeState();
}

class _FormBuilderBarcodeState extends State<FormBuilderBarcode>
    with Control, ControlInput {
  bool _readOnly = false;
  String _initialValue;
  final GlobalKey<FormFieldState> _fieldKey = GlobalKey<FormFieldState>();
  FormBuilderState _formState;
  String _savedValue;
  TextEditingController _textEditingController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    _savedValue = widget.doc[widget.doctypeField.fieldname];
    _formState = FormBuilder.of(context);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _fieldKey.currentState.didChange(
          Barcode.code128().toSvg(
            _textEditingController.text,
            height: 82,
            width: 156,
          ),
        );
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _readOnly = _formState?.readOnly == true || widget.readOnly;
    _readOnly = true;

    return FormField<String>(
      key: _fieldKey,
      enabled: !_readOnly,
      initialValue: _initialValue,
      onSaved: (val) {
        if (_savedValue != null && val == null) return;
        var transformed;
        if (widget.valueTransformer != null) {
          transformed = widget.valueTransformer(val);
        } else {}
        setState(() {
          _savedValue = transformed ?? val;
        });
        widget.onSaved?.call(transformed ?? val);
      },
      builder: (FormFieldState<dynamic> field) {
        // return Column(
        //   children: [
        //     TextField(
        //       controller: _textEditingController,
        //       textInputAction: TextInputAction.done,
        //       focusNode: _focusNode,
        //       readOnly: _readOnly,
        //       onEditingComplete: () {
        //         setState(() async {
        //           var bSvg = Barcode.code128().toSvg(
        //             _textEditingController.text,
        //             height: 82,
        //             width: 156,
        //           );

        //           field.didChange(
        //             bSvg,
        //           );
        //         });
        //       },
        //       decoration: Palette.formFieldDecoration(
        //         true,
        //         "label",
        //         _readOnly
        //             ? Container()
        //             : IconButton(
        //                 icon: Icon(
        //                   Icons.clear,
        //                 ),
        //                 onPressed: () {
        //                   setState(() {
        //                     _textEditingController.clear();
        //                   });
        //                 },
        //               ),
        //       ),
        //     ),
        //     SizedBox(
        //       height: 10,
        //     ),
        //     _textEditingController.text.isNotEmpty
        //         ? BarcodeWidget(
        //             data: _textEditingController.text,
        //             height: 82,
        //             width: 156,
        //             barcode: Barcode.code128(),
        //           )
        //         : Container(
        //             width: 156,
        //             height: 82,
        //           )
        //   ],
        // );

        return Center(
          child: SvgPicture.string(
            widget.doc[widget.doctypeField.fieldname],
          ),
        );
      },
    );
  }
}
