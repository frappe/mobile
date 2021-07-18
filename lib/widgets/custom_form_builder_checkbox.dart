// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frappe_app/widgets/custom_check_box.dart';

class CustomFormBuilderCheckbox extends StatefulWidget {
  final String attribute;
  final List<FormFieldValidator> validators;
  final bool initialValue;
  final bool readOnly;
  final InputDecoration decoration;
  final ValueChanged onChanged;
  final ValueTransformer valueTransformer;
  final bool leadingInput;

  final Widget label;

  final Color activeColor;
  final Color checkColor;
  final MaterialTapTargetSize materialTapTargetSize;
  final bool tristate;
  final FormFieldSetter onSaved;
  final EdgeInsets contentPadding;
  final Color focusColor;
  final Color hoverColor;
  final FocusNode focusNode;
  final bool autoFocus;
  final MouseCursor mouseCursor;
  final VisualDensity visualDensity;

  CustomFormBuilderCheckbox({
    Key key,
    @required this.attribute,
    @required this.label,
    this.initialValue,
    this.validators = const [],
    this.readOnly = false,
    this.decoration = const InputDecoration(),
    this.onChanged,
    this.valueTransformer,
    this.leadingInput = false,
    this.activeColor,
    this.checkColor,
    this.materialTapTargetSize,
    this.tristate = false,
    this.onSaved,
    this.contentPadding = const EdgeInsets.all(0.0),
    this.focusColor,
    this.hoverColor,
    this.focusNode,
    this.autoFocus = false,
    this.mouseCursor,
    this.visualDensity,
  }) : super(key: key);

  @override
  _CustomFormBuilderCheckboxState createState() =>
      _CustomFormBuilderCheckboxState();
}

class _CustomFormBuilderCheckboxState extends State<CustomFormBuilderCheckbox> {
  bool _readOnly = false;
  final GlobalKey<FormFieldState> _fieldKey = GlobalKey<FormFieldState>();
  FormBuilderState _formState;
  bool _initialValue;

  @override
  void initState() {
    _formState = FormBuilder.of(context);
    _initialValue = widget.initialValue ??
        ((_formState?.initialValue?.containsKey(widget.attribute) ?? false)
            ? _formState.initialValue[widget.attribute]
            : null);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _checkbox(FormFieldState<dynamic> field) {
    return SizedBox(
      width: 24.0,
      child: CustomCheckbox(
        value: (field.value == null && !widget.tristate) ? false : field.value,
        activeColor: widget.activeColor,
        checkColor: widget.checkColor,
        materialTapTargetSize: widget.materialTapTargetSize,
        tristate: widget.tristate,
        onChanged: _readOnly
            ? null
            : (bool value) {
                FocusScope.of(context).requestFocus(FocusNode());
                field.didChange(value);
                widget.onChanged?.call(value);
              },
        focusColor: widget.focusColor,
        hoverColor: widget.hoverColor,
        focusNode: widget.focusNode,
        autofocus: widget.autoFocus,
        mouseCursor: widget.mouseCursor,
        visualDensity: widget.visualDensity,
      ),
    );
  }

  Widget _leading(FormFieldState<dynamic> field) {
    if (widget.leadingInput) return _checkbox(field);
    return null;
  }

  Widget _trailing(FormFieldState<dynamic> field) {
    if (!widget.leadingInput) return _checkbox(field);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO

    return FormField(
      key: _fieldKey,
      enabled: !_readOnly,
      initialValue: _initialValue,
      onSaved: (val) {
        var transformed;
        if (widget.valueTransformer != null) {
          transformed = widget.valueTransformer(val);
        } else {}
        widget.onSaved?.call(transformed ?? val);
      },
      builder: (FormFieldState<dynamic> field) {
        return InputDecorator(
          decoration: widget.decoration.copyWith(
            enabled: !_readOnly,
            errorText: field.errorText,
          ),
          child: GestureDetector(
            onTap: _readOnly
                ? null
                : () {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final newValue = !(field.value ?? false);
                    field.didChange(newValue);
                    widget.onChanged?.call(newValue);
                  },
            child: Row(children: [
              _leading(field),
              SizedBox(
                width: 8,
              ),
              widget.label,
            ]),
          ),
        );
      },
    );
  }
}
