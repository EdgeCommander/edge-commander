var routerDataTable = null;

var DatatableDataROUTER = function() {
  routerDataTable = $(".m_router_datatable").mDatatable({
    data: {
      type: "remote",
      source: "/get_all_routers",
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
        return "<div class='editROUTER cursor_to_pointer fa fa-edit' data-id='"+ t.id +"'></div>";
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
        return "<div class='deleteROUTER cursor_to_pointer fa fa-trash' data-id='"+ t.id +"'></div>";
      },
    },
    {
        field: "name",
        title: "Name",
        width: 220,
        sortable: !1,
        selector: !1,
    },
    {
        field: "ip",
        title: "IP",
        width: 150
    },
    {
        field: "port",
        title: "HTTP Port",
        textAlign: "center",
        width: 150
    },
    {
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
        width: 230
      }
    ]
  });
};

onSearching = function() {
  i = routerDataTable.getDataSourceQuery();
  $("#m_form_search").on("keyup", function(e) {
      routerDataTable.search($(this).val().toLowerCase())
  }).val(i.generalSearch)
}

var startROUTERTable = function() {
  DatatableDataROUTER();
};


var onROUTERButton = function() {
  $("#addROUTER").on("click", function(){
    $('.add_router_to_db').modal('show');
  });
};

var discardModal = function() {
  $("#discardModal").on("click", function() {
    $('ul#errorOnROUTER').html("")
    clearForm();
    $("#routerErrorDetails").addClass("hide_me");
  });
};

var clearForm = function() {
  $("#router_name").val("");
  $("#router_ip").val("");
  $("#router_username").val("");
  $("#router_password").val("");
  $("#http_router_port").val("");
  $('ul#errorOnROUTER').html("");
  $("#set_to_load").removeClass("loading");
  $("#body-router-dis *").prop('disabled', false);
  $("#routerErrorDetails").addClass("hide_me");
};

var saveModal = function() {
  $("#saveModal").on("click", function() {
    $('ul#errorOnROUTER').html("");
    $("#api-wait").removeClass("hide_me");
    $("#body-router-dis *").prop('disabled',true);
    $("#routerErrorDetails").addClass("hide_me");
    // $("#set_to_load").addClass("loading");
    var name          = $("#router_name").val(),
        IP            = $("#router_ip").val(),
        username      = $("#router_username").val(),
        password      = $("#router_password").val(),
        http_router_port = $("#http_router_port").val(),
        user_id       = $("#user_id").val(),
        is_monitoring = $('input[id=router_is_monitoring]:checked').length > 0;

    var data = {};
        data.name = name;
        data.ip = IP;
        data.username = username;
        data.password = password;
        data.port = http_router_port;
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
      url: "/routers/new"
    };

    sendAJAXRequest(settings);
  });
};

var onError, onSuccess;

onError = function(jqXHR, status, error) {
  var cList = $('ul#errorOnROUTER')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#routerErrorDetails").removeClass("hide_me");
  $("#api-wait").addClass("hide_me");
  $("#body-router-dis *").prop('disabled', false);
  $("#set_to_load").removeClass("loading");
  return false;
};

onSuccess = function(result, status, jqXHR) {
  $.notify({
    // options
    message: 'Router has been added.'
  },{
    // settings
    type: 'info'
  });
  $(".modal-backdrop").remove();
  $("#m_modal_1").modal("hide");
  $("#api-wait").addClass("hide_me");
  routerDataTable.load();
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

var deleteROUTER;

deleteROUTER = function() {
  $(document).on("click", ".deleteROUTER", function() {
    var nvrRow, result;
    result = confirm("Are you sure to delete this Router?");
    if (result === false) {
      return;
    }
    routerRow = $(this).parents('tr');
    routerID = $(this).attr('data-id');

    var data = {};
    data.id = routerID;
    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onROUTERDeleteError,
      success: onROUTERDeleteSuccess,
      contentType: "application/x-www-form-urlencoded",
      context: {routerRow: routerRow},
      type: "DELETE",
      url: "/routers/delete"
    };

    sendAJAXRequest(settings);
  });
};

var onROUTERDeleteError, onROUTERDeleteSuccess;

onROUTERDeleteError = function(jqXHR, status, error) {
  console.log(jqXHR.responseJSON);
  return false;
};

onROUTERDeleteSuccess = function(result, status, jqXHR) {
  this.routerRow.remove();
  $.notify({
    // options
    message: 'Router has been deleted.'
  },{
    // settings
    type: 'info'
  });
  console.log(result);
  routerDataTable.load();
  return true;
};

var onROUTEREditButton;

onROUTEREditButton = function() {
  $(document).on("click", ".editROUTER", function(){

    var row = $(this).closest('tr');
    var data = routerDataTable.jsonData[row.index()];
    console.log(row.index())

    $("#saveEditModal").attr('data-id', $(this).data("id"));
    $("#edit_router_name").val(data.name);
    $("#edit_router_ip").val(data.ip);
    $("#edit_router_username").val(data.username);
    $("#edit_router_password").val(data.password);
    $("#edit_http_router_port").val(data.port);

    if (data.is_monitoring) {
      $('#edit_router_is_monitoring').prop('checked', true);
    }
    $('#edit_router_to_db').modal('show');
  });
};


var updateROUTERdo;

updateROUTERdo = function(){
  $("#saveEditModal").on("click", function() {
    $("#body-router-edit-dis *").prop('disabled', true);
    $('ul#errorOnEditROUTER').html("");
    $("#api-wait").removeClass("hide_me");
    $("#routerEditErrorDetails").addClass("hide_me");

    var routerID = $(this).attr('data-id');
    var name          = $("#edit_router_name").val(),
        IP            = $("#edit_router_ip").val(),
        username      = $("#edit_router_username").val(),
        password      = $("#edit_router_password").val(),
        http_router_port = $("#edit_http_router_port").val(),
        is_monitoring = $('input[id=edit_router_is_monitoring]:checked').length > 0;

    var data = {};
        data.name = name;
        data.ip = IP;
        data.username = username;
        data.password = password;
        data.port = http_router_port;
        data.is_monitoring = is_monitoring;
        data.id = routerID;

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onEditError,
      success: onEditSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "PATCH",
      url: "/routers/update"
    };

    sendAJAXRequest(settings);
  });
};

var onEditError, onEditSuccess;

onEditError = function(jqXHR, status, error) {
  $("#api-wait").addClass("hide_me");
  $("#body-router-edit-dis *").prop('disabled', false);
  var cList = $('ul#errorOnEditROUTER')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#routerEditErrorDetails").removeClass("hide_me");
  return false;
};

onEditSuccess = function(result, status, jqXHR) {
  $.notify({
    // options
    message: 'Router has been updated.'
  },{
    // settings
    type: 'info'
  });
  $("#api-wait").addClass("hide_me");
  editClearFrom();
  $("#edit_router_to_db").modal("hide");
  routerDataTable.load();
  console.log(result);
  return true;
};

var editClearFrom;

editClearFrom = function() {
  $("#edit_router_name").val("");
  $("#edit_router_ip").val("");
  $("#edit_router_username").val("");
  $("#edit_router_password").val("");
  $("#edit_http_router_port").val("");
  $('ul#errorOnEditROUTER').html("");
  $("#body-router-edit-dis *").prop('disabled', false);
  $("#routerEditErrorDetails").addClass("hide_me");
}

var showHideColumns;

showHideColumns = function() {
  $(".router-column").on("click", function(){
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

window.initializeRouters = function() {
  startROUTERTable();
  onSearching();
  onROUTERButton();
  discardModal();
  saveModal();
  deleteROUTER();
  onROUTEREditButton();
  updateROUTERdo();
  showHideColumns();
};
