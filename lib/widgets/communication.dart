import 'package:flutter/material.dart';
import 'package:support_app/widgets/comment_input.dart';
import 'package:support_app/widgets/timeline.dart';

class Communication extends StatefulWidget {
  final Map docInfo;
  final String name;
  final String doctype;
  final Function callback;

  const Communication({this.docInfo, this.doctype, this.name, this.callback});

  @override
  _CommunicationState createState() => _CommunicationState();
}

class _CommunicationState extends State<Communication> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CommentInput(
                doctype: widget.doctype,
                name: widget.name,
                authorEmail: "Administrator", //TODO: remove hardcoded
                callback: widget.callback,
              ),
              Timeline(widget.docInfo, widget.callback),
            ]),
      ),
    );
  }
}

// class EditorPage extends StatefulWidget {
//   @override
//   EditorPageState createState() => EditorPageState();
// }

// class EditorPageState extends State<EditorPage> {
//   /// Allows to control the editor and the document.
//   ZefyrController _controller;

//   /// Zefyr editor like any other input field requires a focus node.
//   FocusNode _focusNode;

//   @override
//   void initState() {
//     super.initState();
//     // Here we must load the document and pass it to Zefyr controller.
//     final document = _loadDocument();
//     _controller = ZefyrController(document);
//     _focusNode = FocusNode();
//   }

//   void _saveDocument(BuildContext context) {
//     Delta _delta = _controller.document.toDelta();
//     String html =
//         markdown.markdownToHtml(notusMarkdown.encode(_delta).toString());
//     print(html);
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Note that the editor requires special `ZefyrScaffold` widget to be
//     // one of its parents.
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Editor page"),
//         actions: <Widget>[
//           Builder(
//             builder: (context) => IconButton(
//               icon: Icon(Icons.save),
//               onPressed: () => _saveDocument(context),
//             ),
//           )
//         ],
//       ),
//       body: ZefyrScaffold(
//         child: ZefyrEditor(
//           padding: EdgeInsets.all(16),
//           controller: _controller,
//           focusNode: _focusNode,
//         ),
//       ),
//     );
//   }

//   /// Loads the document to be edited in Zefyr.
//   NotusDocument _loadDocument() {
//     // For simplicity we hardcode a simple document with one line of text
//     // saying "Zefyr Quick Start".
//     // (Note that delta must always end with newline.)
//     final Delta delta = Delta()..insert("\n");
//     return NotusDocument.fromDelta(delta);
//   }
// }