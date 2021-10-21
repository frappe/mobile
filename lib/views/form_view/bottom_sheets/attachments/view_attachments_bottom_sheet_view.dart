import 'dart:io' as io;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frappe_app/config/frappe_icons.dart';
import 'package:frappe_app/config/frappe_palette.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/get_doc_response.dart';
import 'package:frappe_app/utils/constants.dart';
import 'package:frappe_app/utils/enums.dart';

import 'package:frappe_app/utils/frappe_icon.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/views/base_view.dart';
import 'package:frappe_app/views/form_view/bottom_sheets/attachments/view_attachments_bottom_sheet_viewmodel.dart';

import 'package:frappe_app/widgets/frappe_bottom_sheet.dart';
import 'package:frappe_app/widgets/frappe_button.dart';
import 'package:open_file/open_file.dart';

import 'add_attachments_bottom_sheet_view.dart';

class ViewAttachmentsBottomSheetView extends StatelessWidget {
  final List<Attachments> attachments;
  final String doctype;
  final String name;

  const ViewAttachmentsBottomSheetView({
    required this.attachments,
    required this.doctype,
    required this.name,
  });

  _triggerFilePicker(Function addFiles) async {
    FilePickerResult? _files = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (_files != null) {
      var _frappeFiles = _files.files.map((file) {
        return FrappeFile(file: file, isPrivate: true);
      }).toList();
      addFiles(_frappeFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 3 - 80;
    final double itemWidth = size.width / 2;

    return BaseView<ViewAttachmenetsBottomSheetViewModel>(
      onModelReady: (model) {
        model.filesToUpload = [];
        model.doctype = doctype;
        model.name = name;
        model.allFilesPrivate = true;

        if (attachments.isEmpty) {
          _triggerFilePicker(model.addFilesToUpload);
        }
      },
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: 0.9,
        child: FrappeBottomSheet(
          title: 'Attachments',
          bottomBar: model.filesToUpload.isNotEmpty
              ? Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FrappeFlatButton(
                        buttonType: ButtonType.secondary,
                        title: model.allFilesPrivate
                            ? 'Set all public'
                            : 'Set all private',
                        onPressed: () {
                          model.toggleAllPrivate();
                        },
                      ),
                      FrappeFlatButton(
                        buttonType: ButtonType.primary,
                        title: 'Upload',
                        onPressed: () async {
                          var uploadedFiles = await model.uploadFiles();
                          Navigator.of(context).pop(uploadedFiles);
                        },
                      ),
                    ],
                  ),
                )
              : null,
          onActionButtonPress: () async {
            // showModalBottomSheet(
            //   context: context,
            //   isScrollControlled: true,
            //   builder: (context) => AddAttachmentsBottomSheetView(),
            // );

            try {
              await _triggerFilePicker(model.addFilesToUpload);
            } on PlatformException catch (e) {
              print("Unsupported operation" + e.toString());
            }
          },
          trailing: Row(
            children: [
              FrappeIcon(
                FrappeIcons.small_add,
                color: FrappePalette.blue[500],
                size: 16,
              ),
              Text(
                'Attach File',
                style: TextStyle(
                  color: FrappePalette.blue[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          body: model.filesToUpload.isEmpty
              ? ViewAttachedFiles(
                  itemWidth: itemWidth,
                  itemHeight: itemHeight,
                  attachments: attachments,
                  selectedFilter: model.selectedFilter,
                  changeTab: model.changeTab,
                )
              : ViewFilesToAttach(
                  filesToUpload: model.filesToUpload,
                  togglePrivate: (int idx) {
                    model.togglePrivate(idx);
                  },
                  removeFileToUpload: (int idx) {
                    model.removeFileToUpload(idx);
                  },
                ),
        ),
      ),
    );
  }
}

class ViewFilesToAttach extends StatelessWidget {
  final List<FrappeFile> filesToUpload;
  final Function removeFileToUpload;
  final Function togglePrivate;

  const ViewFilesToAttach({
    required this.filesToUpload,
    required this.removeFileToUpload,
    required this.togglePrivate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filesToUpload.length,
      itemBuilder: (context, idx) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Row(
            children: [
              FrappeIcon(
                FrappeIcons.small_file,
                size: 20,
              ),
              SizedBox(
                width: 12,
              ),
              Text(
                filesToUpload[idx].file.name,
              )
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  togglePrivate(idx);
                },
                icon: filesToUpload[idx].isPrivate
                    ? FrappeIcon(
                        FrappeIcons.lock,
                        size: 20,
                      )
                    : FrappeIcon(
                        FrappeIcons.unlock,
                        size: 20,
                      ),
              ),
              InkWell(
                onTap: () => removeFileToUpload(idx),
                child: Text(
                  'Remove',
                  style: TextStyle(
                    color: FrappePalette.red[600],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ViewAttachedFiles extends StatelessWidget {
  const ViewAttachedFiles({
    required this.itemWidth,
    required this.itemHeight,
    required this.attachments,
    required this.changeTab,
    required this.selectedFilter,
  });

  final double itemWidth;
  final double itemHeight;
  final List<Attachments> attachments;
  final Function changeTab;
  final AttachmentsFilter selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 10,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  changeTab(AttachmentsFilter.all);
                },
                child: Tab(
                  title: 'All',
                  selected: selectedFilter == AttachmentsFilter.all,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  changeTab(AttachmentsFilter.files);
                },
                child: Tab(
                  title: 'Files',
                  selected: selectedFilter == AttachmentsFilter.files,
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  changeTab(AttachmentsFilter.links);
                },
                child: Tab(
                  title: 'Links',
                  selected: selectedFilter == AttachmentsFilter.links,
                ),
              ),
            ),
          ],
        ),
      ),
      body: selectedFilter == AttachmentsFilter.all
          ? AttachmentsGrid(
              itemWidth: itemWidth,
              itemHeight: itemHeight,
              attachments: attachments,
            )
          : AttachmentsList(
              attachmentsFilter: selectedFilter,
              attachments: attachments,
            ),
    );
  }
}

class AttachmentsList extends StatelessWidget {
  final AttachmentsFilter attachmentsFilter;
  final List<Attachments> attachments;

  const AttachmentsList({
    required this.attachmentsFilter,
    required this.attachments,
  });

  bool isFile(Attachments attachment) {
    var ext = attachment.fileName.split('.').last;
    return Constants.imageExtensions.indexOf(ext) == -1 && !isLink(attachment);
  }

  bool isLink(Attachments attachment) {
    var scheme = Uri.parse(attachment.fileUrl).scheme;
    return attachment.fileName == '' && (scheme == 'http' || scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    List<Attachments> filteredAttachments;
    if (attachmentsFilter == AttachmentsFilter.files) {
      filteredAttachments = attachments.where((attachment) {
        return isFile(attachment);
      }).toList();
    } else {
      filteredAttachments = attachments.where((attachment) {
        return isLink(attachment);
      }).toList();
    }
    return ListView.builder(
      itemCount: filteredAttachments.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () async {
            var attachment = filteredAttachments[index];
            var downloadPath = await getDownloadPath();
            var fileUrlName = attachment.fileUrl.split('/').last;

            var filePath = "$downloadPath$fileUrlName";

            var fileExists = await io.File(filePath).exists();

            if (fileExists) {
              OpenFile.open(filePath);
            } else {
              downloadFile(attachment.fileUrl, downloadPath);
            }
          },
          title: Text(filteredAttachments[index].fileName),
          subtitle: Text('15 Sep, 2020'),
          leading: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: FrappePalette.grey[100],
            ),
            child: Center(
              child: Text(
                filteredAttachments[index].fileName.split('.').last,
              ),
            ),
          ),
        );
      },
    );
  }
}

class AttachmentsGrid extends StatelessWidget {
  const AttachmentsGrid({
    required this.itemWidth,
    required this.itemHeight,
    required this.attachments,
  });

  final double itemWidth;
  final double itemHeight;
  final List<Attachments> attachments;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: (itemWidth / itemHeight),
      ),
      itemCount: attachments.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var ext = attachments[index].fileName.split('.').last;
        var isImage = Constants.imageExtensions.indexOf(ext) != -1;

        return GestureDetector(
          onTap: () async {
            var attachment = attachments[index];
            var downloadPath = await getDownloadPath();
            var fileUrlName = attachment.fileUrl.split('/').last;

            var filePath = "$downloadPath$fileUrlName";

            try {
              var fileExists = await io.File(filePath).exists();
              if (fileExists) {
                OpenFile.open(filePath);
              } else {
                downloadFile(attachment.fileUrl, downloadPath);
              }
            } catch (e) {
              print(e);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  color: FrappePalette.grey[200],
                  height: itemHeight - 55,
                  child: Center(
                    child: Text(
                      ext != '' ? ext.toUpperCase() : 'LINK',
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    FrappeIcon(
                      isImage ? FrappeIcons.image_add : FrappeIcons.small_file,
                      size: 12,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Flexible(
                      child: Text(
                        attachments[index].fileName != ''
                            ? attachments[index].fileName
                            : attachments[index].fileUrl,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Tab extends StatelessWidget {
  final String title;
  final bool selected;

  const Tab({
    required this.title,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: selected ? FrappePalette.grey[600] : FrappePalette.grey[100],
        borderRadius: BorderRadius.circular(
          6,
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 13,
            color: selected ? Colors.white : FrappePalette.grey[800],
          ),
        ),
      ),
    );
  }
}
