import 'package:frappe_app/app/locator.dart';
import 'package:frappe_app/model/common.dart';
import 'package:frappe_app/model/upload_file_response.dart';
import 'package:frappe_app/services/api/api.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/views/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ViewAttachmenetsBottomSheetViewModel extends BaseViewModel {
  AttachmentsFilter selectedFilter = AttachmentsFilter.all;
  late bool allFilesPrivate;
  late List<FrappeFile> filesToUpload;
  late String doctype;
  late String name;

  changeTab(AttachmentsFilter tab) {
    selectedFilter = tab;
    notifyListeners();
  }

  addFilesToUpload(List<FrappeFile> files) {
    filesToUpload.addAll(files);
    notifyListeners();
  }

  removeFileToUpload(int idx) {
    filesToUpload.removeAt(idx);
    notifyListeners();
  }

  togglePrivate(int idx) {
    filesToUpload[idx].isPrivate = !filesToUpload[idx].isPrivate;
    notifyListeners();
  }

  toggleAllPrivate() {
    allFilesPrivate = !allFilesPrivate;
    filesToUpload = filesToUpload.map((file) {
      file.isPrivate = allFilesPrivate;
      return file;
    }).toList();
    notifyListeners();
  }

  Future<List<UploadedFile>> uploadFiles() async {
    var uploadedFiles = await locator<Api>().uploadFiles(
      files: filesToUpload,
      doctype: doctype,
      name: name,
    );

    return uploadedFiles;
  }
}
