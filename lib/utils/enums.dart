enum DocInfoItemType {
  assignees,
  attachments,
  reviews,
  tags,
  shared,
}

enum AttachmentsFilter { all, files, links }

enum EventType {
  comment,
  email,
  docVersion,
}

enum Order {
  asc,
  desc,
}

enum ViewType {
  filter,
  list,
  form,
  newForm,
}

enum ButtonType {
  primary,
  secondary,
}

enum ConnectivityStatus {
  wiFi,
  cellular,
  offline,
}

enum ViewState {
  idle,
  busy,
}
