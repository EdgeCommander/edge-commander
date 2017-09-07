var initializeDataTable,
    closeMessageBox,
    replaceEntryWithAddButton,
    onNVRButton,
    formValidations,
    discardModal,
    saveModal,
    sendAJAXRequest,
    clearForm;

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

clearForm = function() {
  $("#nvr_name").val("");
  $("#nvr_ip").val("");
  $("#nvr_username").val("");
  $("#nvr_password").val("");
  $("#nvr_port").val("");
  $("#user_id").val("");
  $('ul#errorOnNVR').html("")
  $("#nvrErrorDetails").addClass("hide");
}

var onError, onSuccess;

onError = function(jqXHR, status, error) {
  var cList = $('ul#errorOnNVR')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    console.log(value);
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#nvrErrorDetails").removeClass("hide");
  return false;
};

onSuccess = function(result, status, jqXHR) {
  $("#NVRaddModal").modal("hide");
  clearForm();
  console.log(result);
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
    $('ul#errorOnNVR').html("")
    $("#nvrErrorDetails").addClass("hide");
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