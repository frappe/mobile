// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/model/config.dart';
import 'package:html/parser.dart';

class FormBuilderTextEditor<T> extends FormBuilderField<T> {
  final Function onTap;

  FormBuilderTextEditor({
    @required Key key,
    @required String name,
    @required this.onTap,
    FormFieldValidator<T> validator,
    T initialValue,
    bool enabled = true,
  }) : super(
          key: key,
          initialValue: initialValue,
          name: name,
          validator: validator,
          builder: (FormFieldState<T> field) {
            final state = field as _FormBuilderDropdownState<T>;

            var document = parse(field.value);
            var imgs = document.getElementsByTagName('img');

            imgs.forEach((img) {
              if (Uri.parse(img.attributes["src"]).hasAbsolutePath) {
                img.attributes["src"] =
                    "${Config().baseUrl}${img.attributes["src"]}";
              }
            });

            void changeValue(T value) {
              state.requestFocus();
              state.didChange(value);
            }

            return InkWell(
              // onTap: !enabled
              //     ? null
              //     : () async {
              //         onTap(field);
              //       },
              onTap: () {
                onTap(field);
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 80,
                  minWidth: double.infinity,
                ),
                child: Container(
                  color: Palette.fieldBgColor,
                  child: SingleChildScrollView(
                    child: Html(
                      data: document.outerHtml,
                    ),
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
