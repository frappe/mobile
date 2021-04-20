// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Field for Dropdown button
class FormBuilderTextEditor<T> extends FormBuilderField<T> {
  final Function onTap;

  FormBuilderTextEditor({
    @required Key key,
    @required String name,
    @required this.onTap,
    FormFieldValidator<T> validator,
    T initialValue,
    bool enabled = true,
  }) : /*: assert(allowClear == true || clearIcon != null)*/ super(
          key: key,
          initialValue: initialValue,
          name: name,
          validator: validator,
          builder: (FormFieldState<T> field) {
            final state = field as _FormBuilderDropdownState<T>;

            void changeValue(T value) {
              state.requestFocus();
              state.didChange(value);
            }

            return InkWell(
              onTap: !enabled
                  ? null
                  : () async {
                      onTap(field);
                    },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 80,
                  minWidth: double.infinity,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    field.value.toString(),
                  ),
                ),
              ),
            );
          },
        );

  @override
  _FormBuilderDropdownState<T> createState() => _FormBuilderDropdownState<T>();
}

class _FormBuilderDropdownState<T>
    extends FormBuilderFieldState<FormBuilderTextEditor<T>, T> {}
