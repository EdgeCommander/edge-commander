var initializeDataTable, closeMessageBox;

initializeDataTable = function() {
  $('#example').DataTable();
};

closeMessageBox = function() {
  $('.message .close')
    .on('click', function() {
      $(this)
        .closest('.message')
        .transition('fade')
      ;
    })
  ;
}

window.initializeNVR = function() {
  closeMessageBox();
  return initializeDataTable();
};