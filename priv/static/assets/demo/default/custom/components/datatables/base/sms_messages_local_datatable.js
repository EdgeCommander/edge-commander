var smsDataTable = null;

$( "#m_sms_datepicker_from" ).datepicker({autoclose:true, format:"yyyy-mm-dd"}).datepicker("setDate", new Date(new Date().getTime() - (48 * 60 * 60 * 1000)));
$( "#m_sms_datepicker_to" ).datepicker({autoclose:true, format:"yyyy-mm-dd"}).datepicker("setDate", new Date());

  var from_date = $("#m_sms_datepicker_from").val(),
    to_date = $("#m_sms_datepicker_to").val();

var DatatableDataSms = function() {
  smsDataTable = $(".sms_messages_datatable").mDatatable({
    data: {
      type: "remote",
      speedLoad: true,
      source: "/get_all_sms/" + from_date + "/" + to_date,
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
    sortable: 1,
    filterable: !1,
    pagination: false,
    columns: [
    {
      field: "from",
      title: "From",
      width: 95,
      textAlign: "left",
      sortable: !1,
      selector: !1,
    },
    {
      field: "to",
      title: "To",
      textAlign: "left",
      width: 95
    },
    {
      field: "message_id",
      title: "Message ID",
      textAlign: "left",
      width: 180,
      responsive: {
        hidden: 'lg'
      }
    },
    {
      field: "type",
      title: "Type",
      textAlign: "left",
      width: 80,
      template: function(data) {
        if(data.type == "MO"){
          return "<span class='m-badge m-badge--metal m-badge--wide'>Incoming</span>";
        }else{
          return "<span class='m-badge m-badge--success m-badge--wide'>Outgoing</span>";
        }
      }
    },
    {
      field: "text",
      title: "Text Message",
      textAlign: "left",
      width: 1010
    },
    {
      field: "status",
      title: "Status",
      textAlign: "left",
      width: 80,
      template: function(data) {
        status = data.status;
        if(status == "Received"){
          return "<span class='m-badge m-badge--metal m-badge--wide' style='text-transform:capitalize'>"+status+"</span>"
        }else if(status == "delivered"){
          return "<span class='m-badge m-badge--success m-badge--wide' style='text-transform:capitalize'>"+status+"</span>"
        }else{
          return "<span class='m-badge m-badge--info m-badge--wide' style='text-transform:capitalize'>"+status+"</span>"
        }
      }
    },
    {
      field: "inserted_at",
      title: "Message Date",
      textAlign: "left",
      width: 200,
      template: function(t) {
        return "" + moment(t.inserted_at).format('MMMM Do YYYY, H:mm:ss') +"";
      }
    }
    ]
  });
};

onSearching = function() {
  i = smsDataTable.getDataSourceQuery();
  $("#m_form_search").on("keyup", function(e) {
      smsDataTable.search($(this).val().toLowerCase())
  }).val(i.generalSearch)
}

var startSmsTable = function() {
  DatatableDataSms();
};

var onSmsButton = function() {
  $("#sendSms").on("click", function(){
    $('.add_sms_to_db').modal('show');
  });
};

var discardModal = function() {
  $("#discardModal").on("click", function() {
    $('ul#errorOnSite').html("")
    clearForm();
    $("#smsErrorDetails").addClass("hide_me");
  });
};

var clearForm = function() {
  $("#smsMessage").val("");
  $('ul#errorOnSite').html("");
  $("#set_to_load").removeClass("loading");
  $("#body-sms-dis *").prop('disabled', false);
  $("#smsErrorDetails").addClass("hide_me");
};

function sendSMS() {
  $("#send-sms-nexmo").on("click", function() {
  $('ul#errorOnSms').html("");
    $("#api-wait").removeClass("hide_me");
    $("#smsErrorDetails").addClass("hide_me");

    var sms_message  = $("#smsMessage").val(),
    to_number        = $("#toNumber").val(),
    user_id          = $("#user_id").val()

    var data = {};
    data.sms_message = sms_message;
    data.to_number = to_number;
    data.user_id = user_id;

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onSMSError,
      success: onSMSSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "POST",
      url: "/send_sms"
    };
    sendAJAXRequest(settings);
  });
};

var onSMSError, onSMSSuccess;

onSMSError = function(jqXHR, status, error) {
    $.notify({
      // options
      message: "Something went wrong."
    },{
      // settings
      type: 'danger'
    });
  $("#smsErrorDetails").removeClass("hide_me");
  $("#api-wait").addClass("hide_me");
  $("#body-sms-dis *").prop('disabled', false);
  $("#set_to_load").removeClass("loading");
  return false;
};

onSMSSuccess = function(result, status, jqXHR) {
  if (result.status != 0) {
    $.notify({
      // options
      message: result.error_text
    },{
      // settings
      type: 'danger'
    });
  } else
  {
    $.notify({
      // options
      message: "Your message has been sent."
    },{
      // settings
      type: 'info'
    });
  }
  $(".modal-backdrop").remove();
  $(".add_sms_to_db").modal("hide");
  smsDataTable.load();
  $("#api-wait").addClass("hide_me");
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

var showHideColumns;

showHideColumns = function() {
  $(".sms-column").on("click", function(){
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

autoLoadSmsTable = function() {
  smsDataTable.load();
}
var onSendSMSFocus = function() {
  $('.add_sms_to_db').on('shown.bs.modal', function () {
    $('#smsMessage').focus();
  })  
};

var DateFilterInitialize = function() {
  $('#m_sms_datepicker_from, #m_sms_datepicker_to').datepicker({
    autoclose: true,
    format: "yyyy-mm-dd"
  }).on('changeDate', function(e) {
    var from_date = $("#m_sms_datepicker_from").val(),
        to_date = $("#m_sms_datepicker_to").val();

    var loadSMS = smsDataTable;
    loadSMS.data().options.data.source = "/get_all_sms/" + from_date + "/" + to_date;
    loadSMS.load();
  });
}

window.initializeSmsMessages = function() {
  DateFilterInitialize();
  startSmsTable();
  onSearching();
  onSmsButton();
  discardModal();
  sendSMS();
  showHideColumns();
  onSendSMSFocus();
};