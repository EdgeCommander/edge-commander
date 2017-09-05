var initializeDataTable,
    closeMessageBox,
    replaceEntryWithAddButton,
    onNVRButton,
    discardModal;

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
};

replaceEntryWithAddButton = function() {
  $(".dataTables_length").html("")
  var addNVRButton = $("#addNvr");
  $(".dataTables_length").html(addNVRButton);
  console.log("dd");
};

onNVRButton = function() {
  $("#addNvr")
    .on("click", function(){
      $('.ui.checkbox').checkbox();
      $('.tiny.modal').modal('show');
  });
};

discardModal = function() {
  $("#discardModal").on("click", function() {
    $("#NVRaddModal").modal("hide");
  });
};

window.initializeNVR = function() {
  initializeDataTable();
  closeMessageBox();
  replaceEntryWithAddButton();
  onNVRButton();
  discardModal();
};