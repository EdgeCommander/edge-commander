var sitesDataTable = null;

var DatatableDataSites = function() {
  sitesDataTable = $(".m_sites_datatable").mDatatable({
    data: {
      type: "remote",
      speedLoad: true,
      source: "/get_all_sites",
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
        return "<div class='editSite cursor_to_pointer fa fa-edit' data-id='"+ t.id +"'></div> <div class='deleteSite cursor_to_pointer fa fa-trash' data-id='"+ t.id +"'></div>";
      },
    },
    {
        field: "name",
        title: "Name",
        width: 180,
        sortable: !1,
        selector: !1,
    },
    {
        field: "location",
        title: "Location",
        textAlign: "center",
        width: 180
    },
    {
        field: "sim_number",
        title: "Sim Number",
        textAlign: "center",
        width: 150,
        responsive: {
            visible: "lg"
        }
    },
    {
        field: "router_name",
        title: "Router Name",
        textAlign: "left",
        width: 220
    },
    {
        field: "nvr_name",
        title: "NVR Name",
        textAlign: "left",
        width: 230
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
  i = sitesDataTable.getDataSourceQuery();
  $("#m_form_search").on("keyup", function(e) {
      sitesDataTable.search($(this).val().toLowerCase())
  }).val(i.generalSearch)
}

var startSitesTable = function() {
  DatatableDataSites();
};


var onSiteButton = function() {
  $("#addSite").on("click", function(){
    $('.add_site_to_db').modal('show');
  });
};

var discardModal = function() {
  $("#discardModal").on("click", function() {
    $('ul#errorOnSite').html("")
    clearForm();
    $("#siteErrorDetails").addClass("hide_me");
  });
};

var clearForm = function() {
  $("#name").val("");
  $("#location").val("");
  $("#notes").val("");
  $('ul#errorOnSite').html("");
  $("#set_to_load").removeClass("loading");
  $("#body-site-dis *").prop('disabled', false);
  $("#siteErrorDetails").addClass("hide_me");
};

var saveModal = function() {
  $("#saveModal").on("click", function() {
    $('ul#errorOnSite').html("");
    $("#api-wait").removeClass("hide_me");
    $("#body-site-dis *").prop('disabled',true);
    $("#siteErrorDetails").addClass("hide_me");

    var name        = $("#name").val(),
        location    = $("#location").val(),
        sim_number  = $('#sim_number').find(":selected").val(),
        router_id   = $('#router_id').find(":selected").val(),
        nvr_id      = $('#nvr_id').find(":selected").val(),
        notes        = $("#notes").val(),
        user_id     = $("#user_id").val();

    var data = {};
        data.name = name;
        data.location = location;
        data.sim_number = sim_number;
        data.router_id = router_id;
        data.nvr_id = nvr_id;
        data.notes = notes;
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
      url: "/sites/new"
    };
    sendAJAXRequest(settings);
  });
};

var onError, onSuccess;

onError = function(jqXHR, status, error) {
  var cList = $('ul#errorOnSite')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#siteErrorDetails").removeClass("hide_me");
  $("#api-wait").addClass("hide_me");
  $("#body-site-dis *").prop('disabled', false);
  $("#set_to_load").removeClass("loading");
  return false;
};

onSuccess = function(result, status, jqXHR) {
  $.notify({
    // options
    message: 'Site has been added.'
  },{
    // settings
    type: 'info'
  });
  $(".modal-backdrop").remove();
  $("#m_modal_1").modal("hide");
  $("#api-wait").addClass("hide_me");
  sitesDataTable.load();
  clearForm();
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

var deleteSite;

deleteSite = function() {
  $(document).on("click", ".deleteSite", function() {
    var ruleRow, result;
    result = confirm("Are you sure to delete this Site?");
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
      error: onSiteDeleteError,
      success: onSiteDeleteSuccess,
      contentType: "application/x-www-form-urlencoded",
      context: {ruleRow: ruleRow},
      type: "DELETE",
      url: "/sites/delete"
    };

    sendAJAXRequest(settings);
  });
};

var onSiteDeleteError, onSiteDeleteSuccess;

onSiteDeleteError = function(jqXHR, status, error) {
  console.log(jqXHR.responseJSON);
  return false;
};

onSiteDeleteSuccess = function(result, status, jqXHR) {
  this.ruleRow.remove();
  $.notify({
    // options
    message: 'Site has been deleted.'
  },{
    // settings
    type: 'info'
  });
  sitesDataTable.load();
  return true;
};

var onSiteEditButton;

onSiteEditButton = function() {
  $(document).on("click", ".editSite", function(){
    var row = $(this).closest('tr');
    var data = sitesDataTable.jsonData[row.index()];
    console.log(row.index())
    $("#saveEditModal").attr('data-id', $(this).data("id"));

    router_id = 
      $('#edit_router_id option').filter(function () { 
        return $(this).html() == data.router_name; 
      }).val();

    nvr_id = 
      $('#edit_nvr_id option').filter(function () { 
        return $(this).html() == data.nvr_name; 
      }).val();

    $("#edit_name").val(data.name);
    $("#edit_location").val(data.location);
    $("#edit_sim_number").val(data.sim_number);
    $("#edit_router_id").val(router_id);
    $("#edit_nvr_id").val(nvr_id);
    $("#edit_notes").val(data.notes);
    $('#edit_site_to_db').modal('show');
  });
};

var updateSitedo;

updateSitedo = function(){
  $("#saveEditModal").on("click", function() {
    $("#body-site-edit-dis *").prop('disabled', true);
    $('ul#errorOnEditSite').html("");
    $("#api-wait").removeClass("hide_me");
    $("#siteEditErrorDetails").addClass("hide_me");

    var siteID = $(this).attr('data-id');

    var name        = $("#edit_name").val(),
        location    = $("#edit_location").val(),
        sim_number  = $('#edit_sim_number').find(":selected").val(),
        router_id   = $('#edit_router_id').find(":selected").val(),
        nvr_id      = $('#edit_nvr_id').find(":selected").val(),
        notes       = $("#edit_notes").val()

    var data = {};
        data.name = name;
        data.location = location;
        data.sim_number = sim_number;
        data.router_id = router_id;
        data.nvr_id = nvr_id;
        data.notes = notes;
        data.id = siteID;

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onEditError,
      success: onEditSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "PATCH",
      url: "/sites/update"
    };

    sendAJAXRequest(settings);
  });
};

var onEditError, onEditSuccess;

onEditError = function(jqXHR, status, error) {
  $("#api-wait").addClass("hide_me");
  $("#body-site-edit-dis *").prop('disabled', false);
  var cList = $('ul#errorOnEditSite')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#siteEditErrorDetails").removeClass("hide_me");
  return false;
};

onEditSuccess = function(result, status, jqXHR) {
  $.notify({
    // options
    message: 'Site has been updated.'
  },{
    // settings
    type: 'info'
  });
  $("#api-wait").addClass("hide_me");
  editClearFrom();
  $("#edit_site_to_db").modal("hide");
  sitesDataTable.load();
  return true;
};

var editClearFrom;

editClearFrom = function() {
  $("#edit_rule_name").val("");
  $('ul#errorOnEditSite').html("");
  $("#body-site-edit-dis *").prop('disabled', false);
  $("#siteEditErrorDetails").addClass("hide_me");
}

var showHideColumns;

showHideColumns = function() {
  $(".site-column").on("click", function(){
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

window.initializeSites = function() {
  startSitesTable();
  onSearching();
  onSiteButton();
  discardModal();
  saveModal();
  deleteSite();
  onSiteEditButton();
  updateSitedo();
  showHideColumns();
};