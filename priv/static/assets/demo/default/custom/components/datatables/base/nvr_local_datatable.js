var nvrDataTable = null;

var DatatableDataNVR = function() {
  nvrDataTable = $(".m_nvr_datatable").mDatatable({
    data: {
      type: "remote",
      source: "/nvrs",
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
      field: "reboot",
      width: 60,
      title: "",
      textAlign: "center",
      locked: {left: 'xl'},
      sortable: false,
      template: function(t) {
        return "<button class='btn btn-default rebootNVR cursor_to_pointer' data-id='"+ t.id +"' style='font-size:12px;padding: 5px;'>Reboot</button>";
      }
    },
    {
      field: "actions",
      width: 60,
      title: "Actions",
      textAlign: "center",
      locked: {left: 'xl'},
      sortable: false,
      template: function(t) {
        return "<div class='editNVR cursor_to_pointer fa fa-edit' data-id='"+ t.id +"' title='Edit'></div> <div class='deleteNVR cursor_to_pointer fa fa-trash' data-id='"+ t.id +"' title='Delete'></div>";
      }
    },
    {
        field: "name",
        title: "Name",
        width: 230,
        sortable: !1,
        selector: !1,
        template: function(t) {
          url = t.ip + ":" + t.port
          return "<span style='float:left'>"+t.name+"</span><a href='"+url+"' target='_blanck'><span class='fa fa-external-link' style='float:right'></span></a>"
        }
    },
    {
        field: "ip",
        title: "IP",
        width: 230
    },
    {
        field: "port",
        title: "HTTP Port",
        textAlign: "center",
        width: 150,
        responsive: {
          hidden: 'lg'
        }
    },
    {
        field: "vh_port",
        title: "VH Port",
        textAlign: "center",
        width: 150,
        responsive: {
          hidden: 'lg'
        }
    },
    {
        field: "sdk_port",
        title: "SDK Port",
        textAlign: "center",
        width: 150,
        responsive: {
          hidden: 'lg'
        }
    },
    {
        field: "rtsp_port",
        title: "RTSP Port",
        textAlign: "center",
        width: 150,
        responsive: {
          hidden: 'lg'
        }
    },
    {
        field: "username",
        title: "Username",
        textAlign: "center",
        width: 100,
        responsive: {
            hidden: "lg"
        }
    }, {
        field: "password",
        title: "Password",
        textAlign: "center",
        width: 150,
        responsive: {
          hidden: 'lg'
        }
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
        field: "encoder_released_date",
        title: "Encoder Released Date",
        textAlign: "center",
        width: 180,
        responsive: {
          hidden: 'lg'
        }
    }, {
        field: "encoder_version",
        title: "Encoder Version",
        textAlign: "center",
        width: 150,
        responsive: {
          hidden: 'lg'
        }
    }, {
        field: "firmware_released_date",
        title: "Firmware Released Date",
        textAlign: "center",
        width: 180,
        responsive: {
          hidden: 'lg'
        }
    }, {
        field: "serial_number",
        title: "Serial Number",
        textAlign: "left",
        width: 400,
        responsive: {
          hidden: 'lg'
        }
    }, {
        field: "mac_address",
        title: "Mac Address",
        textAlign: "center",
        width: 150,
        responsive: {
          hidden: 'lg'
        }
    }, {
        field: "nvr_status",
        title: "Status",
        textAlign: "center",
        width: 250,
        template: function(data) {
          if(data.nvr_status == false){
            reason  = data.reason;
            if(reason == ''){
              reason = "no reason found.";
            }
            return "<span style='color:#d9534d'>Offline</span> <span>(" + reason + ")</span>";
          }else{
            return "<span style='color:#5cb85c'>Online</span>";
          }
        }
    }, {
        field: "is_monitoring",
        title: "Monitoring",
        textAlign: "center",
        responsive: {
          hidden: 'lg'
        },
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
        responsive: {
          hidden: 'lg'
        },
        template: function(t) {
          return "" + moment(t.created_at).format('MMMM Do YYYY, H:mm:ss') +"";
        },
        width: 250
      }
    ]
  });
};

onSearching = function() {
  i = nvrDataTable.getDataSourceQuery();
  $("#m_form_search").on("keyup", function(e) {
      nvrDataTable.search($(this).val().toLowerCase())
  }).val(i.generalSearch)
};

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
  $("#http_nvr_port").val("");
  $("#sdk_nvr_port").val("");
  $("#vh_nvr_port").val("");
  $("#rtsp_nvr_port").val("");
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
        http_nvr_port = $("#http_nvr_port").val(),
        sdk_nvr_port  = $("#sdk_nvr_port").val(),
        vh_nvr_port   = $("#vh_nvr_port").val(),
        rtsp_nvr_port = $("#rtsp_nvr_port").val(),
        user_id       = $("#user_id").val(),
        is_monitoring = $('input[id=nvr_is_monitoring]:checked').length > 0;

    var data = {};
        data.name = name;
        data.ip = IP;
        data.username = username;
        data.password = password;
        data.port = http_nvr_port;
        data.sdk_port = sdk_nvr_port;
        data.vh_port = vh_nvr_port;
        data.rtsp_port = rtsp_nvr_port;
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
      url: "/nvrs"
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
  $.notify({
    // options
    message: 'NVR has been added.'
  },{
    // settings
    type: 'info'
  });
  $(".modal-backdrop").remove();
  $("#m_modal_1").modal("hide");
  $("#api-wait").addClass("hide_me");
  nvrDataTable.load();
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
  $(document).on("click", ".deleteNVR", function() {
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
      url: "/nvrs/" + nvrID
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
  $.notify({
    // options
    message: 'NVR has been deleted.'
  },{
    // settings
    type: 'info'
  });
  console.log(result);
  nvrDataTable.load();
  return true;
};



var rebootNVR;

rebootNVR = function() {
  $(document).on("click", ".rebootNVR", function() {
    var nvrRow, result;
    result = confirm("Are you sure to reboot this NVR?");
    if (result === false) {
      return;
    }
    nvrRow = $(this).parents('tr');
    nvrID = $(this).attr('data-id');

    var data = {};
    data.id = nvrID;
    var settings;

    mApp.block(".m_nvr_datatable", {
      overlayColor: "#000000",
      type: "loader",
      state: "primary",
      message: "Please Wait..."
    });

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onNVRRebootError,
      success: onNVRRebootSuccess,
      contentType: "application/x-www-form-urlencoded",
      context: {nvrRow: nvrRow},
      type: "GET",
      url: "/nvrs/" + nvrID
    };

    sendAJAXRequest(settings);
  });
};

var onNVRRebootError, onNVRRebootSuccess;

onNVRRebootError = function(jqXHR, status, error) {
    mApp.unblock(".m_nvr_datatable", {
      overlayColor: "#000000",
      type: "loader",
      state: "primary",
      message: "Please Wait..."
    });
   $.notify({
      message: jqXHR.responseJSON.message
    },{
      type: 'danger'
    });
  return false;
};

onNVRRebootSuccess = function(result, status, jqXHR) {
  mApp.unblock(".m_nvr_datatable", {
    overlayColor: "#000000",
    type: "loader",
    state: "primary",
    message: "Please Wait..."
  });
  if (result.status != 201) {
    $.notify({
      message: result.message
    },{
      type: 'danger'
    });
  } else
  {
    $.notify({
      message: "Nvr has been reboot successfully."
    },{
      type: 'info'
    });
  }
  return true;
};

var onNVREditButton;

onNVREditButton = function() {
  $(document).on("click", ".editNVR", function(){

    var row = $(this).closest('tr');
    var data = nvrDataTable.jsonData[row.index()];
    console.log(row.index())

    $("#saveEditModal").attr('data-id', $(this).data("id"));
    $("#edit_nvr_name").val(data.name);
    $("#edit_nvr_ip").val(data.ip);
    $("#edit_nvr_username").val(data.username);
    $("#edit_nvr_password").val(data.password);
    $("#edit_http_nvr_port").val(data.port);
    $("#edit_vh_nvr_port").val(data.vh_port);
    $("#edit_sdk_nvr_port").val(data.sdk_port);
    $("#edit_rtsp_nvr_port").val(data.rtsp_port);

    if (data.is_monitoring) {
      $('#edit_nvr_is_monitoring').prop('checked', true);
    }
    $('#edit_nvr_to_db').modal('show');
  });
};


var updateNVRdo;

updateNVRdo = function(){
  $("#saveEditModal").on("click", function() {
    $("#body-nvr-edit-dis *").prop('disabled', true);
    $('ul#errorOnEditNVR').html("");
    $("#api-wait").removeClass("hide_me");
    $("#nvrEditErrorDetails").addClass("hide_me");

    var nvrID = $(this).attr('data-id');
    var name          = $("#edit_nvr_name").val(),
        IP            = $("#edit_nvr_ip").val(),
        username      = $("#edit_nvr_username").val(),
        password      = $("#edit_nvr_password").val(),
        http_nvr_port = $("#edit_http_nvr_port").val(),
        sdk_nvr_port  = $("#edit_sdk_nvr_port").val(),
        vh_nvr_port   = $("#edit_vh_nvr_port").val(),
        rtsp_nvr_port = $("#edit_rtsp_nvr_port").val(),
        is_monitoring = $('input[id=edit_nvr_is_monitoring]:checked').length > 0;

    var data = {};
        data.name = name;
        data.ip = IP;
        data.username = username;
        data.password = password;
        data.port = http_nvr_port;
        data.sdk_port = sdk_nvr_port;
        data.vh_port = vh_nvr_port;
        data.rtsp_port = rtsp_nvr_port;
        data.is_monitoring = is_monitoring;
        data.id = nvrID;

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onEditError,
      success: onEditSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "PATCH",
      url: "/nvrs/" + nvrID
    };

    sendAJAXRequest(settings);
  });
};

var onEditError, onEditSuccess;

onEditError = function(jqXHR, status, error) {
  $("#api-wait").addClass("hide_me");
  $("#body-nvr-edit-dis *").prop('disabled', false);
  var cList = $('ul#errorOnEditNVR')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#nvrEditErrorDetails").removeClass("hide_me");
  return false;
};

onEditSuccess = function(result, status, jqXHR) {
  $.notify({
    // options
    message: 'NVR has been updated.'
  },{
    // settings
    type: 'info'
  });
  $("#api-wait").addClass("hide_me");
  editClearFrom();
  $("#edit_nvr_to_db").modal("hide");
  nvrDataTable.load();
  console.log(result);
  return true;
};

var editClearFrom;

editClearFrom = function() {
  $("#edit_nvr_name").val("");
  $("#edit_nvr_ip").val("");
  $("#edit_nvr_username").val("");
  $("#edit_nvr_password").val("");
  $("#edit_http_nvr_port").val("");
  $("#edit_sdk_nvr_port").val("");
  $("#edit_vh_nvr_port").val("");
  $("#edit_rtsp_nvr_port").val("");
  $('ul#errorOnEditNVR').html("");
  $("#body-nvr-edit-dis *").prop('disabled', false);
  $("#nvrEditErrorDetails").addClass("hide_me");
}

var showHideColumns;

showHideColumns = function() {
  $(".nvr-column").on("click", function(){
    console.log($(this).attr("data-field"));
    var ColToHide = $(this).attr("data-field");
    if(this.checked){
      $("th[data-field='" + ColToHide + "']").show();
      $("td[data-field='" + ColToHide + "']").show();
    }else{
      $("th[data-field='" + ColToHide + "']").hide();
      $("td[data-field='" + ColToHide + "']").hide();
    }
  });
};

window.initializeNVR = function() {
  startNVRTable();
  onSearching();
  onNVRButton();
  discardModal();
  saveModal();
  deleteNVR();
  rebootNVR();
  onNVREditButton();
  updateNVRdo();
  showHideColumns();
};
