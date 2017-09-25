
var DatatableDataNVR = function() {
    var e = function(src) {
          var a = $(".m_nvr_datatable").mDatatable({
                data: {
                    type: "local",
                    source: src,
                    pageSize: 50
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
                      console.log(t);
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
                      console.log(t);
                      return "" + moment(t.created_at).format('MMMM Do YYYY, H:mm:ss') +"";
                    },
                    width: 200
                }
              ]
            }),
            i = a.getDataSourceQuery();
        $("#m_form_search").on("keyup", function(e) {
            console.log($(this).val().toLowerCase());
            a.search($(this).val().toLowerCase())
        }).val(i.generalSearch)
    };
    return {
        init: function(logs) {
          console.log('test');
            e(logs)
        }
    }
}();

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
  $.when(get_NVR_data()).done(function(data){
    DatatableDataNVR.init(data.nvrs);
    console.log(data.nvrs);
  });
};

// $.when(get_NVR_data()).done(function(data){
//   DatatableDataNVR.init(data.nvrs);
//   console.log(data.nvrs);
// });


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

    console.log(data);
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
  startNVRTable();
  $(".modal-backdrop").remove();
  $("#m_modal_1").modal("hide");
  $("#api-wait").addClass("hide_me");
  clearForm();
  $("#set_to_load").removeClass("loading");
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

window.initializeNVR = function() {
  startNVRTable();
  onNVRButton();
  discardModal();
  saveModal();
};