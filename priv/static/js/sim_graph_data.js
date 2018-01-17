var startMORRISChartJS = function () {

    var settingsForMorris;
    settingsForMorris = {
      cache: false,
      data: {sim_number: window.location.href.substring(window.location.href.lastIndexOf('/') + 1) },
      dataType: 'json',
      error: onMorrisError,
      success: onMorrisSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "GET",
      url: "/create_chartjs_line_data"
    };

    $.ajax(settingsForMorris);

};

var onMorrisError, onMorrisSuccess;

onMorrisSuccess = function (result, status, jqXHR) {

  var labelsZchartjs = [], dataZChartsJS = [];
  $.each(result.chartjs_data, function( index, element ) {
    labelsZchartjs.push(element.datetime);
    dataZChartsJS.push(element.percentage_used);
    // element == this
  });

  var chartColors = {
    red: 'rgb(255, 99, 132)',
    orange: 'rgb(255, 159, 64)',
    yellow: 'rgb(255, 205, 86)',
    green: 'rgb(75, 192, 192)',
    blue: 'rgb(54, 162, 235)',
    purple: 'rgb(153, 102, 255)',
    grey: 'rgb(231,233,237)'
  };

  var randomScalingFactor = function() {
    return (Math.random() > 0.5 ? 1.0 : -1.0) * Math.round(Math.random() * 100);
  }
  var config = {
    type: 'line',
    data: {
      labels: labelsZchartjs,
      datasets: [{
        label: "",
        fill: false,
        backgroundColor: chartColors.blue,
        borderColor: chartColors.blue,
        data: dataZChartsJS,
      }]
    },
    options: {
      legend: {
        labels: {
          boxWidth: 0,
          fontStyle: "bold",
          fontSize: 20
        }
      },
      responsive: true,
      tooltips: {
        bodyFontStyle: "bold",
        mode: 'label',
      },
      hover: {
        mode: 'nearest',
        intersect: true
      },
      scales: {
        xAxes: [{
          ticks: {
              autoSkip : true,
              callback: function(value, index, values) {
                return new moment(value).format('YYYY-MM-DD');
              }
          },
          display: true,
          fontStyle: "bold",
          scaleLabel: {
            fontStyle: "bold",
            display: false,
            labelString: 'Date & Time'
          }
        }],
        yAxes: [{
          ticks: {
              min: 0,
              max: 100,
              stepSize: 20
          },
          display: true,
          fontStyle: "bold",
          scaleLabel: {
            fontStyle: "bold",
            display: true,
            labelString: '% Allowance Used'
          }
        }]
      }
    }
  };

  $("#api-wait").addClass("hide_me");
  var ctx = document.getElementById("canvas").getContext("2d");
  var ctx_div = document.getElementById("canvas");
  ctx_div.height = 200;
  window.myLine = new Chart(ctx, config);
  resizeTableDiv();
};

var dataTableSIMTAB = function() {
    var e = function() {
            a = $(".m_datatable").mDatatable({
                data: {
                  type: "remote",
                  source: "/get_single_sim_data/" + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "",
                  pageSize: 50,
                  serverPaging: false,
                  serverFiltering: false,
                  serverSorting: false
                },
                layout: {
                    theme: "default",
                    class: "",
                    scroll: !1,
                    footer: !1
                },
                sortable: !0,
                filterable: !1,
                pagination: false,
                columns: [
                {
                    field: "date_of_use",
                    title: "DateTime",
                    width: 195,
                    template: function(t) {
                      return "" + moment(t.date_of_use).format('MMMM Do YYYY, H:mm:ss') +"";
                    }
                }, {
                    field: "allowance_in_number",
                    title: "MB Allowance",
                    textAlign: "center",
                    width: 100
                }, {
                    field: "current_in_number",
                    title: "MB Used (Today)",
                    textAlign: "center",
                    width: 120
                }, {
                    field: "percentage_used",
                    title: "% Used",
                    textAlign: "center",
                    width: 80
                }
              ]
            }),
            i = a.getDataSourceQuery(),
            a.setDataSourceParam('sort', {field: "percentage_used", sort: "desc"});
        $("#m_form_search").on("keyup", function(e) {
            a.search($(this).val().toLowerCase())
        }).val(i.generalSearch)
    };
    return {
        init: function() {
            e()
        }
    }
}();


var startSIMTABDatatable = function() {
  dataTableSIMTAB.init();
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

var clearForm = function() {
  $("#smsMessage").val("");
  $("#set_to_load").removeClass("loading");
  $("#body-sms-dis *").prop('disabled', false);
  $("#smsErrorDetails").addClass("hide_me");
};

function sendSMS() {
  $(".send-sms-nexmo").on("click", function() {
  $('ul#errorOnNVR').html("");
    $("#api-wait").removeClass("hide_me");
    $("#body-sms-dis *").prop('disabled',true);
    $("#smsErrorDetails").addClass("hide_me");
    
    var sms_message  = $("#smsMessage").val(),
    to_number        = $("#toNumber").val()
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
  $("#smsModal").modal("hide");
  smsDataTable.load();
  $("#api-wait").addClass("hide_me");
  clearForm();
  return true;
};

var smsDataTable = function() {
  smsDataTable = $("#sim_sms_datatable").mDatatable({
      data: {
        type: "remote",
        speedLoad: true,
        source: "/get_single_sim_sms/" + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "",
        pageSize: 50,
        serverPaging: false,
        serverFiltering: false,
        serverSorting: false
      },
      layout: {
        theme: "default",
        class: "",
        scroll: !1,
        height: 300,
        footer: !1
      },
      sortable: 0,
      filterable: !1,
      pagination: false,
      columns: [
      {
        field: "inserted_at",
        title: "Date",
        width: 180,
        template: function(t) {
          return "" + moment(t.inserted_at).format('MMMM Do YYYY, H:mm:ss') +"";
        },
      },
      {
        field: "type",
        title: "Type",
        width: 80,
        template: function(data) {
          if(data.type == "MO"){
            return "<span class='m-badge m-badge--metal m-badge--wide'>Incommig</span>";
          }else{
            return "<span class='m-badge m-badge--success m-badge--wide'>Outgoing</span>";
          }
        }
      },
      {
        field: "status",
        title: "Status",
        width: 80,
        template: function(data) {
          return "<span style='text-transform:capitalize'>"+data.status+"</sapn>"
        }
      },
      {
        field: "text",
        title: "Message",
        width: 550,
        template: function(data) {
          str = data.text;
          return str.split("\n").join("<br/>");
        }
      }
      ]
    }),
     mApp.block("#sim_sms_datatable", {
      overlayColor: "#000000",
      type: "loader",
      state: "primary",
      message: "Please Wait..."
    })
};

var loadSmsDataTable = function() {
  smsDataTable.load();
};

var onSendSMSFocus = function() {
  $('#smsModal').on('shown.bs.modal', function () {
    $('#smsMessage').focus();
  })  
};

window.initializeSimTabs = function() {
  startMORRISChartJS();
  startSIMTABDatatable();
  sendSMS();
  smsDataTable();
  onSendSMSFocus();
};

var resizeTableDiv = function() {
  var objDiv = document.getElementById("iam_canvas");
  var convasHeight = objDiv.scrollHeight + 18;
  $("#sm_datatable_inner").css("min-height", convasHeight).css("max-height", convasHeight).css("overflow-y", "auto");
};

$(window).resize(function() {
  resizeTableDiv();
  initializeSimTabs();
});
