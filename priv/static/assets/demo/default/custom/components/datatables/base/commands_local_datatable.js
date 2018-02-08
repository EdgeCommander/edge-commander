var commandsDataTable = null;

var DatatableDataCOMMAND = function() {
  commandsDataTable = $(".m_commands_datatable").mDatatable({
    data: {
      type: "remote",
      speedLoad: true,
      source: "/v1/rules",
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
      field: "actions",
      width: 60,
      title: "Actions",
      locked: {left: 'xl'},
      sortable: false,
      template: function(t) {
        return "<div class='editRULE cursor_to_pointer fa fa-edit' data-id='"+ t.id +"'></div> <div class='deleteRULE cursor_to_pointer fa fa-trash' data-id='"+ t.id +"'></div>";
      },
    },
    {
        field: "rule_name",
        title: "Rule Name",
        width: 250,
        sortable: !1,
        selector: !1,
    },
    {
        field: "active",
        title: "Active",
        width: 120,
        textAlign: "center",
        template: function(t) {
          if (t.active) {
            return "Yes";
          } else
          {
            return "No";
          }
        },
    },
    {
        field: "category",
        title: "Category",
        textAlign: "center",
        width: 150
    },
    {
        field: "recipients",
        title: "Recipients",
        textAlign: "center",
        width: 200,
        responsive: {
            visible: "lg"
        }
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
  i = commandsDataTable.getDataSourceQuery();
  $("#m_form_search").on("keyup", function(e) {
      commandsDataTable.search($(this).val().toLowerCase())
  }).val(i.generalSearch)
}

var startCOMMANDTable = function() {
  DatatableDataCOMMAND();
};


var onRULEButton = function() {
  $("#addRULE").on("click", function(){
    $('.add_rule_to_db').modal('show');
  });
};

var discardModal = function() {
  $("#discardModal").on("click", function() {
    $('ul#errorOnRULE').html("")
    clearForm();
    $("#ruleErrorDetails").addClass("hide_me");
  });
};

var clearForm = function() {
  $("#rule_name").val("");
  $('ul#errorOnRULE').html("");
  $("#set_to_load").removeClass("loading");
  $("#body-rule-dis *").prop('disabled', false);
  $("#ruleErrorDetails").addClass("hide_me");
};

var saveModal = function() {
  $("#saveModal").on("click", function() {
    $('ul#errorOnRULE').html("");
    $("#api-wait").removeClass("hide_me");
    $("#body-rule-dis *").prop('disabled',true);
    $("#ruleErrorDetails").addClass("hide_me");
    // $("#set_to_load").addClass("loading");
    var rule_name     = $("#rule_name").val(),
        user_id       = $("#user_id").val(),
        category      = $('#rule_category').find(":selected").val(),
        recipients    = $("#rule_recipients").val(),
        is_active = $('input[id=rule_is_active]:checked').length > 0;
    console.log($("#rule_category").val());
    var data = {};
        if (recipients != "") {
          data.recipients = recipients.split(",");
        } else
        {
          data.recipients = "";
        }
        data.rule_name = rule_name;
        data.category = category;
        data.active = is_active;
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
      url: "/v1/rules/new"
    };

    sendAJAXRequest(settings);
  });
};

var onError, onSuccess;

onError = function(jqXHR, status, error) {
  var cList = $('ul#errorOnRULE')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#ruleErrorDetails").removeClass("hide_me");
  $("#api-wait").addClass("hide_me");
  $("#body-rule-dis *").prop('disabled', false);
  $("#set_to_load").removeClass("loading");
  return false;
};

onSuccess = function(result, status, jqXHR) {
  $.notify({
    // options
    message: 'Rule has been added.'
  },{
    // settings
    type: 'info'
  });
  $(".modal-backdrop").remove();
  $("#m_modal_1").modal("hide");
  $("#api-wait").addClass("hide_me");
  commandsDataTable.load();
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

var deleteRULE;

deleteRULE = function() {
  $(document).on("click", ".deleteRULE", function() {
    var ruleRow, result;
    result = confirm("Are you sure to delete this Rule?");
    if (result === false) {
      return;
    }
    ruleRow = $(this).parents('tr');
    ruleID = $(this).attr('data-id');

    var data = {};
    data.id = ruleID;
    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onRULEDeleteError,
      success: onRULEDeleteSuccess,
      contentType: "application/x-www-form-urlencoded",
      context: {ruleRow: ruleRow},
      type: "DELETE",
      url: "/v1/rules/" + ruleID
    };

    sendAJAXRequest(settings);
  });
};

var onRULEDeleteError, onRULEDeleteSuccess;

onRULEDeleteError = function(jqXHR, status, error) {
  console.log(jqXHR.responseJSON);
  return false;
};

onRULEDeleteSuccess = function(result, status, jqXHR) {
  this.ruleRow.remove();
  $.notify({
    // options
    message: 'Rule has been deleted.'
  },{
    // settings
    type: 'info'
  });
  console.log(result);
  commandsDataTable.load();
  return true;
};

var onRULEEditButton;

onRULEEditButton = function() {
  $(document).on("click", ".editRULE", function(){

    var row = $(this).closest('tr');
    var data = commandsDataTable.jsonData[row.index()];
    console.log(row.index())

    $("#saveEditModal").attr('data-id', $(this).data("id"));
    $("#edit_rule_name").val(data.rule_name);
    $("#edit_rule_category").val(data.category);
    $("#edit_rule_recipients").val(data.recipients);
    if (data.active) {
      $('#edit_rule_is_active').prop('checked', true);
    }
    $('#edit_rule_to_db').modal('show');
  });
};


var updateROUTERdo;

updateROUTERdo = function(){
  $("#saveEditModal").on("click", function() {
    $("#body-rule-edit-dis *").prop('disabled', true);
    $('ul#errorOnEditRULE').html("");
    $("#api-wait").removeClass("hide_me");
    $("#ruleEditErrorDetails").addClass("hide_me");

    var ruleID = $(this).attr('data-id');
    var rule_name     = $("#edit_rule_name").val(),
        category      = $('#edit_rule_category').find(":selected").val(),
        recipients    = $("#edit_rule_recipients").val(),
        is_active = $('input[id=edit_rule_is_active]:checked').length > 0;

    var data = {};
        if (recipients != "") {
          data.recipients = recipients.split(",");
        } else
        {
          data.recipients = "";
        }
        data.rule_name = rule_name;
        data.category = category;
        data.active = is_active;
        data.id = ruleID;

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onEditError,
      success: onEditSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "PATCH",
      url: "/v1/rules/update"
    };

    sendAJAXRequest(settings);
  });
};

var onEditError, onEditSuccess;

onEditError = function(jqXHR, status, error) {
  $("#api-wait").addClass("hide_me");
  $("#body-rule-edit-dis *").prop('disabled', false);
  var cList = $('ul#errorOnEditRULE')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#ruleEditErrorDetails").removeClass("hide_me");
  return false;
};

onEditSuccess = function(result, status, jqXHR) {
  $.notify({
    // options
    message: 'Rule has been updated.'
  },{
    // settings
    type: 'info'
  });
  $("#api-wait").addClass("hide_me");
  editClearFrom();
  $("#edit_rule_to_db").modal("hide");
  commandsDataTable.load();
  console.log(result);
  return true;
};

var editClearFrom;

editClearFrom = function() {
  $("#edit_rule_name").val("");
  $('ul#errorOnEditRULE').html("");
  $("#body-rule-edit-dis *").prop('disabled', false);
  $("#ruleEditErrorDetails").addClass("hide_me");
}

var showHideColumns;

showHideColumns = function() {
  $(".rule-column").on("click", function(){
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

window.initializeCommands = function() {
  startCOMMANDTable();
  onSearching();
  onRULEButton();
  discardModal();
  saveModal();
  deleteRULE();
  onRULEEditButton();
  updateROUTERdo();
  showHideColumns();
};
