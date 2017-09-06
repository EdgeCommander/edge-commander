var initializeDataTable,
    closeMessageBox,
    replaceEntryWithAddButton,
    onNVRButton,
    formValidations,
    discardModal,
    saveModal,
    sendAJAXRequest;

sendAJAXRequest = function(settings) {
  var headers, token, xhrRequestChangeMonth;
  token = $('meta[name="csrf-token"]');
  if (token.size() > 0) {
    headers = {
      "X-CSRF-Token": token.attr("content")
    };
    settings.headers = headers;
  }
  return xhrRequestChangeMonth = jQuery.ajax(settings);
};

var onError, onSuccess;

onError = function(jqXHR, status, error) {
  // Notification.show(jqXHR.responseText);
  console.log(jqXHR.responseText);
  return false;
};

onSuccess = function(result, status, jqXHR) {
  // $('#modal-add-admin').modal('hide');
  console.log(result);
  // Notification.show("Admin has been added!");
  // clearForm();
  // addNewRow(result);
  return true;
};

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

saveModal = function() {
  $("#saveModal").on("click", function() {
    var name          = $("#nvr_name").val(),
        IP            = $("#nvr_ip").val(),
        username      = $("#nvr_username").val(),
        password      = $("#nvr_password").val(),
        port          = $("#nvr_port").val(),
        user_id       = $("#user_id").val(),
        is_monitoring = $("#is_monitoring").hasClass("checked");

    var data = {};
        data.name = name;
        data.ip = IP;
        data.username = username;
        data.password = password;
        data.port = port;
        data.is_monitoring = is_monitoring;
        data.user_id = user_id;

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onError,
      success: onSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "POST",
      url: "/nvrs/new"
    };

    sendAJAXRequest(settings);
  });
};

// formValidations = function() {
  
// }

window.initializeNVR = function() {
  initializeDataTable();
  closeMessageBox();
  replaceEntryWithAddButton();
  onNVRButton();
  discardModal();
  saveModal();
};