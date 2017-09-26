var nvrDataTable = null;

var DatatableDataNVR = function() {
  nvrDataTable = $(".m_nvr_datatable").mDatatable({
    data: {
      type: "remote",
      source: "/get_all_nvrs",
      pageSize: 50,
      serverPaging: false,
      serverFiltering: false,
      serverSorting: false
    },
    layout: {
      theme: "default",
      class: "",
      scroll: !1,
      height: 950,
      footer: !1
    },
    sortable: !0,
    filterable: !1,
    pagination: false,
    columns: [
    {
      field: "edit",
      title: "",
      width: 40,
      title: "#",
      locked: {left: 'xl'},
      sortable: false,
      template: function(t) {
        return "<div class='cursor_to_pointer fa fa-edit' data-id='"+ t.id +"'></div>";
      },
    },
    {
      field: "delete",
      title: "",
      width: 40,
      title: "#",
      locked: {left: 'xl'},
      sortable: false,
      template: function(t) {
        return "<div class='deleteNVR cursor_to_pointer fa fa-trash' data-id='"+ t.id +"'></div>";
      },
    },
    {
        field: "name",
        title: "Name",
        width: 150,
        sortable: !1,
        selector: !1,
    }, {
        field: "ip",
        title: "IP",
        width: 150
    }, {
        field: "username",
        title: "Username",
        textAlign: "center",
        width: 100,
        responsive: {
            visible: "lg"
        }
    }, {
        field: "password",
        title: "Password",
        textAlign: "center",
        width: 150
    }, {
        field: "model",
        title: "Model",
        textAlign: "center",
        width: 200
    }, {
        field: "firmware_version",
        title: "Firmware Version",
        textAlign: "center",
        width: 150
    }, {
        field: "is_monitoring",
        title: "Monitoring",
        textAlign: "center",
        width: 100,
        template: function(t) {
          if (t.is_monitoring) {
            return "Yes";
          } else{
            return "No";
          }
        },
    }, {
        field: "created_at",
        title: "Created At",
        textAlign: "center",
        template: function(t) {
          return "" + moment(t.created_at).format('MMMM Do YYYY, H:mm:ss') +"";
        },
        width: 200
      }
    ]
  });
};

onSearching = function() {
  i = nvrDataTable.getDataSourceQuery();
  $("#m_form_search").on("keyup", function(e) {
      nvrDataTable.search($(this).val().toLowerCase())
  }).val(i.generalSearch)
}


var get_NVR_data = function() {
  return $.ajax({
    url: "/get_all_nvrs",
    cache: false,
    dataType: 'json',
    contentType: "application/x-www-form-urlencoded",
    type: "GET",
  })
}

var startNVRTable = function() {
  DatatableDataNVR();
};


var onNVRButton = function() {
  $("#addNVR").on("click", function(){
    $('.add_nvr_to_db').modal('show');
  });
};

var discardModal = function() {
  $("#discardModal").on("click", function() {
    $("#NVRaddModal").modal("hide_me");
    $('ul#errorOnNVR').html("")
    clearForm();
    $("#nvrErrorDetails").addClass("hide_me");
  });
};

var clearForm = function() {
  $("#nvr_name").val("");
  $("#nvr_ip").val("");
  $("#nvr_username").val("");
  $("#nvr_password").val("");
  $("#nvr_port").val("");
  $('ul#errorOnNVR').html("");
  $("#set_to_load").removeClass("loading");
  $("#body-nvr-dis *").prop('disabled', false);
  $("#nvrErrorDetails").addClass("hide_me");
};

var saveModal = function() {
  $("#saveModal").on("click", function() {
    $('ul#errorOnNVR').html("");
    $("#api-wait").removeClass("hide_me");
    $("#body-nvr-dis *").prop('disabled',true);
    $("#nvrErrorDetails").addClass("hide_me");
    // $("#set_to_load").addClass("loading");
    var name          = $("#nvr_name").val(),
        IP            = $("#nvr_ip").val(),
        username      = $("#nvr_username").val(),
        password      = $("#nvr_password").val(),
        port          = $("#nvr_port").val(),
        user_id       = $("#user_id").val(),
        is_monitoring = $('input[id=nvr_is_monitoring]:checked').length > 0;

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

var onError, onSuccess;

onError = function(jqXHR, status, error) {
  var cList = $('ul#errorOnNVR')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#nvrErrorDetails").removeClass("hide_me");
  $("#api-wait").addClass("hide_me");
  $("#body-nvr-dis *").prop('disabled', false);
  $("#set_to_load").removeClass("loading");
  return false;
};

onSuccess = function(result, status, jqXHR) {
  $(".modal-backdrop").remove();
  $("#m_modal_1").modal("hide");
  $("#api-wait").addClass("hide_me");
  clearForm();
  console.log(result);
  return true;
};

var sendAJAXRequest = function(settings) {
  var headers, token, xhrRequestChangeMonth;
  token = $('meta[name="csrf-token"]');
  if (token.length > 0) {
    headers = {
      "X-CSRF-Token": token.attr("content")
    };
    settings.headers = headers;
  }
  return xhrRequestChangeMonth = jQuery.ajax(settings);
};

var deleteNVR;

deleteNVR = function() {
  $(".m_nvr_datatable").on("click", ".deleteNVR", function() {
    var nvrRow, result;
    result = confirm("Are you sure to delete this NVR?");
    if (result === false) {
      return;
    }
    nvrRow = $(this).parents('tr');
    nvrID = $(this).attr('data-id');

    var data = {};
    data.id = nvrID;
    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onNVRDeleteError,
      success: onNVRDeleteSuccess,
      contentType: "application/x-www-form-urlencoded",
      context: {nvrRow: nvrRow},
      type: "DELETE",
      url: "/nvrs/delete"
    };

    sendAJAXRequest(settings);
  });
};

var onNVRDeleteError, onNVRDeleteSuccess;

onNVRDeleteError = function(jqXHR, status, error) {
  console.log(jqXHR.responseJSON);
  return false;
};

onNVRDeleteSuccess = function(result, status, jqXHR) {
  this.nvrRow.remove();
  $.notify("NVR has been deleted.", "info");
  console.log(result);
  return true;
};

window.initializeNVR = function() {
  startNVRTable();
  onSearching();
  onNVRButton();
  discardModal();
  saveModal();
  deleteNVR();
};
