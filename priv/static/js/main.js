var initializeDataTable,
    closeMessageBox,
    replaceEntryWithAddButton,
    onNVRButton,
    formValidations,
    discardModal,
    saveModal,
    sendAJAXRequest,
    clearForm,
    NVRtable;

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
  $("#set_to_load").removeClass("loading");
  return false;
};

onSuccess = function(result, status, jqXHR) {
  $("#NVRaddModal").modal("hide");
  clearForm();
  $("#set_to_load").removeClass("loading");
  $.uiAlert({
    textHead: 'Congratulations!', // header
    text: 'NVR has been added.', // Text
    bgcolor: '#0D71BB', // background-color
    textcolor: '#fff', // color
    position: 'top-right',// position . top And bottom ||  left / center / right
    icon: 'checkmark box', // icon in semantic-UI
    time: 3, // time
  })
  NVRtable.ajax.reload();
  console.log(result);
  return true;
};

initializeDataTable = function() {
  NVRtable = $('#example').DataTable({
    ajax: {
      url: "/get_all_nvrs",
      dataSrc: function(data) {
        // console.log(d);
        // console.log(d.nvrs);
        return data.nvrs;
      },
      error: function(xhr, error, thrown) {
        if (xhr.responseJSON) {
          console.log(xhr.responseJSON.message);
        } else {
          console.log("Something went wrong, Please try again.");
        }
      }
    },
    "createdRow": function (row, data, rowIndex) {
        $.each($('td', row), function (colIndex) {
            if (colIndex === 8 || colIndex === 9) {
              console.log(colIndex);
              $(this).attr('data-id', data.id);
            }
        });
    },
    columns: [
      {
        orderable: false,
        data: null,
        defaultContent: ''
      },
      {
        data: function(row, type, set, meta) {
          return row.name;
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.ip;
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.port;
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.username;
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.password;
        }
      },
      {
        data: function(row, type, set, meta) {
          if (row.is_monitoring == true) {
            return "Yes";
          }
          return "No";
        }
      },
      {
        data: function(row, type, set, meta) {
          return "" + moment(row.created_at).format('MMMM Do YYYY, H:mm:ss') +"";
        }, sType: 'uk_datetime'
      },
      {
        orderable: false,
        data: function(row, type, set, meta) {
          return "<i class='write square icon'></i>"
        },
        className: 'center aligned editNVR'
      },
      {
        orderable: false,
        data: function(row, type, set, meta) {
          return "<i class='trash icon'></i>"
        },
        className: 'center aligned deleteNVR'
      },
    ],
    autoWidth: false,
    info: false,
    bPaginate: true,
    pageLength: 50,
    "language": {
      "emptyTable": "No data available"
    },
    order: [[7, "desc"]],
    drawCallback: function() {
      var api;
      api = this.api();
      $.each(api.rows({
        page: 'current'
      }).data(), function(i, data) {
        return $("table#example > tbody > tr:eq(" + i + ") td:eq(0)")
                .addClass("details-control")
                .css( "text-align", "center" )
                .css( "cursor", "pointer" )
                .html("<i class='plus icon'></i>");
      });
    }
  });
};

var deleteNVR;

deleteNVR = function() {
  $("#example").on("click", ".deleteNVR", function() {
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
  console.log(result);
  this.nvrRow.remove();
  $.uiAlert({
    textHead: 'Congratulations!', // header
    text: 'NVR has been deleted.', // Text
    bgcolor: '#0D71BB', // background-color
    textcolor: '#fff', // color
    position: 'top-right',// position . top And bottom ||  left / center / right
    icon: 'checkmark box', // icon in semantic-UI
    time: 3, // time
  })
  return true;
};

var showDetails, format;

format =  function(row) {
  console.log(row);
  if (!row || row.model === null) {
    return "No data available."
  }
  return "<table class='ui celled striped table' style='width: 60%;'>\
      <thead>\
        <tr>\
          <th colspan='2'>\
            Device Information\
          </th>\
        </tr>\
      </thead>\
      <tbody>\
        <tr>\
          <td>Firmware Version</td>\
          <td>"+ row.firmware_version +"</td>\
        </tr>\
        <tr>\
          <td>Model</td>\
          <td>"+ row.model +"</td>\
        </tr>\
        <tr>\
          <td>Device Name</td>\
          <td>"+ row.extra.device_name +"</td>\
        </tr>\
        <tr>\
          <td>Device Type</td>\
          <td>"+ row.extra.device_type +"</td>\
        </tr>\
        <tr>\
          <td>Device Id</td>\
          <td>"+ row.extra.device_id +"</td>\
        </tr>\
        <tr>\
          <td>Encorder Released Date</td>\
          <td>"+ row.extra.encoder_released_date +"</td>\
        </tr>\
        <tr>\
          <td>Encoder Version</td>\
          <td>"+ row.extra.encoder_version +"</td>\
        </tr>\
        <tr>\
          <td>Firmware Released Date</td>\
          <td>"+ row.extra.firmware_released_date +"</td>\
        </tr>\
        <tr>\
          <td>Mac Address</td>\
          <td>"+ row.extra.mac_address +"</td>\
        </tr>\
        <tr>\
          <td>Serial Number</td>\
          <td>"+ row.extra.serial_number +"</td>\
        </tr>\
      </tbody>\
    </table>"
};

showDetails = function() {
  $('#example tbody').on('click', 'td.details-control', function() {
    var row, tr;
    tr = $(this).closest('tr');
    row = NVRtable.row(tr);
    if (row.child.isShown()) {
      row.child.hide();
      tr.removeClass('shown');
      tr.find('td.details-control')
        .html("<i class='plus icon' aria-hidden='true'></i>");
    } else {
      row.child(format(row.data())).show();
      tr.addClass('shown');
      tr.find('td.details-control')
        .html("<i class='remove icon' aria-hidden='true'></i>");
    }
  });
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
      $(".modal").modal({
        closable: false,
      });
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
    $("#set_to_load").addClass("loading");
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
  showDetails();
  saveModal();
  deleteNVR();
};