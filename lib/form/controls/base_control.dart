class Control {
  int toggle(bool show) {
    return show ? 0 : 1;
    // refresh();
  }

  getModelValue(Map doc, String fieldname) {
    return doc[fieldname];
  }

  refresh() {}
}
