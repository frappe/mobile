import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/image_render.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/model/config.dart';
import 'package:frappe_app/utils/dio_helper.dart';
import 'package:frappe_app/views/login/login_view.dart';
import 'package:html/parser.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:frappe_app/utils/enums.dart' as enums;
import 'frappe_button.dart';

class FormBuilderTextEditor<T> extends FormBuilderField<T> {
  FormBuilderTextEditor({
    required String name,
    required BuildContext context,
    Key? key,
    FormFieldValidator<T>? validator,
    T? initialValue,
    bool enabled = true,
    Color? color,
    bool fullHeight = false,
  }) : super(
          key: key,
          initialValue: initialValue,
          name: name,
          validator: validator,
          builder: (FormFieldState<dynamic> field) {
            final state = field as _FormBuilderTextEditorState<T>;
            return InkWell(
              onTap: !state.enabled
                  ? null
                  : () async {
                      var v = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return EditText(
                                  data: field.value as String,
                                );
                              },
                            ),
                          ) ??
                          null;

                      if (v != null) {
                        field.didChange(v);
                      }
                    },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      fullHeight ? MediaQuery.of(context).size.height : 200,
                  minHeight:
                      fullHeight ? MediaQuery.of(context).size.height : 100,
                  minWidth: double.infinity,
                ),
                child: Container(
                  color: color ?? Palette.fieldBgColor,
                  child: SingleChildScrollView(
                    child: field.value != null
                        ? Html(
                            data: field.value as String,
                            customRender: {
                              "img": (renderContext, child) {
                                var src = renderContext.tree.attributes['src'];
                                if (src != null) {
                                  if (!src.startsWith("http")) {
                                    src = Config().baseUrl! + src;
                                  }
                                  return Image.network(
                                    src,
                                    headers: {
                                      HttpHeaders.cookieHeader:
                                          DioHelper.cookies!,
                                    },
                                  );
                                }
                              },
                            },
                            customImageRenders: {
                              networkSourceMatcher(domains: [
                                Config().baseUrl!,
                              ]): networkImageRender(
                                headers: {
                                  HttpHeaders.cookieHeader: DioHelper.cookies!,
                                },
                                altWidget: (alt) => Text(alt ?? ""),
                                loadingWidget: () => Text("Loading..."),
                              ),
                              // for relative paths, prefix with a base url
                              (attr, _) =>
                                      attr["src"] != null &&
                                      !(attr["src"]!.startsWith("http") ||
                                          attr["src"]!.startsWith("https")):
                                  networkImageRender(
                                headers: {
                                  HttpHeaders.cookieHeader: DioHelper.cookies!,
                                },
                                mapUrl: (url) => Config().baseUrl! + url!,
                              ),
                              // Custom placeholder image for broken links
                              networkSourceMatcher(): networkImageRender(
                                  altWidget: (_) => FrappeLogo()),
                            },
                            onLinkTap: (url, _, __, ___) {
                              print("Opening $url...");
                            },
                            onImageTap: (src, _, __, ___) {
                              print(src);
                            },
                            onImageError: (exception, stackTrace) {
                              print(exception);
                            },
                          )
                        : Container(),
                  ),
                ),
              ),
            );
          },
        );

  @override
  _FormBuilderTextEditorState<T> createState() =>
      _FormBuilderTextEditorState<T>();
}

class _FormBuilderTextEditorState<T>
    extends FormBuilderFieldState<FormBuilderTextEditor<T>, T> {}

class EditText extends StatefulWidget {
  final String? data;

  EditText({
    required this.data,
  });

  @override
  _EditTextState createState() => _EditTextState();
}

class _EditTextState extends State<EditText> {
  final HtmlEditorController controller = HtmlEditorController();

  @override
  Widget build(BuildContext context) {
    String? html;
    if (widget.data != null) {
      final doc = parse(widget.data);
      doc.getElementsByTagName("img").forEach((element) {
        if (!element.attributes['src']!.startsWith("http")) {
          element.attributes['src'] =
              Config().baseUrl! + element.attributes['src']!;
        }
      });
      html = doc.outerHtml;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.8,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 8,
            ),
            child: FrappeFlatButton(
              onPressed: () async {
                var txt = await controller.getText();
                Navigator.of(context).pop(txt);
              },
              buttonType: enums.ButtonType.primary,
              title: "Update",
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            HtmlEditor(
              controller: controller,
              htmlEditorOptions: HtmlEditorOptions(
                shouldEnsureVisible: true,
                hint: '',
                initialText: html,
              ),
              htmlToolbarOptions: HtmlToolbarOptions(
                toolbarType: ToolbarType.nativeGrid,
                defaultToolbarButtons: [
                  StyleButtons(),
                  FontButtons(
                    strikethrough: false,
                    subscript: false,
                    superscript: false,
                  ),
                  ColorButtons(),
                  ListButtons(
                    listStyles: false,
                  ),
                  ParagraphButtons(
                    alignCenter: false,
                    alignJustify: false,
                    alignLeft: false,
                    alignRight: false,
                    textDirection: false,
                    caseConverter: false,
                    lineHeight: false,
                  ),
                  InsertButtons(
                    audio: false,
                    video: false,
                    hr: false,
                  ),
                ],
              ),
              otherOptions: OtherOptions(
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
