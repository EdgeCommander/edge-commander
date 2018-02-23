
var DatatableDataLocalDemo = function() {
    var e = function() {
            a = $(".m_datatable").mDatatable({
                data: {
                  type: "remote",
                  source: "/sims",
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
                    field: "number",
                    title: "Number",
                    width: 150,
                    sortable: "desc",
                    selector: !1,
                    template: function(t) {
                      return '<a style="color: blue;text-decoration: underline;cursor: pointer;" href="/sims/' + t.number + '" id="show-morris-graph" data-id="' + t.number + '">' + t.number  + '</a>'
                    }
                }, {
                    field: "name",
                    title: "Name",
                    width: 250
                }, {
                    field: "allowance_in_number",
                    title: "MB Allowance",
                    textAlign: "center",
                    responsive: {
                        visible: "lg"
                    }
                }, {
                    field: "current_in_number",
                    title: " MB Used (Today)",
                    textAlign: "center",
                    width: 150
                }, {
                    field: "yesterday_in_number",
                    title: "MB Used (Yest.)",
                    textAlign: "center",
                    width: 150,
                    responsive: {
                        visible: "lg"
                    }
                },
                {
                  field: "percentage_used",
                  title: "% Used",
                  textAlign: "center"
                },
                {
                  field: "remaining_days",
                  title: "Remaning Days",
                  width: 115,
                  textAlign: "center",
                  template: function(t) {
                    var days_left = (t.allowance_in_number - t.current_in_number) / (t.current_in_number - t.yesterday_in_number)
                    return Math.round(days_left * 100) / 100;
                  }
                },
                {
                  field: "date_of_use",
                  title: "Last Reading",
                  textAlign: "center",
                  width: 195,
                  template: function(t) {
                    return "" + moment(t.date_of_use).format('MMMM Do YYYY, H:mm:ss') +"";
                  }
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


var startSIMDatatable = function() {
  DatatableDataLocalDemo.init();
};

var clearCHARThtml = function() {
  $("#clear_chartsjs").on("click", function () {
    $("#iam_canvas").html("");
    $("#iam_canvas").html("<canvas id='canvas'></canvas>");
  });  
}

var startMORRISChartJS = function () {
  $("#child_data_local").on("click", "#show-morris-graph", function(){
    $("#api-wait").removeClass("hide_me");
    var settingsForMorris;
    var id = $(this).data("id");
    settingsForMorris = {
      cache: false,
      data: {sim_number: id},
      dataType: 'json',
      error: onMorrisError,
      success: onMorrisSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "GET",
      url: "/chartjs/data/" + id
    };

    $.ajax(settingsForMorris);

  });  
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
        label: " % Allowance Used",
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
              stepSize: 10
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
  window.myLine = new Chart(ctx, config);
};

var showHideColumns;

showHideColumns = function() {
  $(".sims-column").on("click", function(){
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

var onSIMButton = function() {
  $("#addSIM").on("click", function(){
    $('.add_sim_to_db').modal('show');
    clearForm();
  });
};

var clearForm = function() {
  $("#number").val("");
  $("#name").val("");
  $('ul#errorOnSIM').html("");
  $("#body-sim-dis *").prop('disabled', false);
  $("#simErrorDetails").addClass("hide_me");
};

var saveModal = function() {
  $("#saveModal").on("click", function() {
    $('ul#errorOnSIM').html("");
    $("#api-wait").removeClass("hide_me");
    $("#body-sim-dis *").prop('disabled',true);
    $("#simErrorDetails").addClass("hide_me");

    var sim_provider  = $('#sim_provider').find(":selected").val(),
        number        = $("#number").val(),
        name          = $("#name").val()

    var data = {};
        data.sim_provider = sim_provider;
        data.number = number;
        data.name = name;
        data.addon = "Unknown";
        data.allowance = "0";
        data.volume_used = "0";

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onError,
      success: onSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "POST",
      url: "/sims"
    };

    sendAJAXRequest(settings);
  });
};

var onError, onSuccess;

onError = function(jqXHR, status, error) {
  var cList = $('ul#errorOnSIM')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#simErrorDetails").removeClass("hide_me");
  $("#api-wait").addClass("hide_me");
  $("#body-sim-dis *").prop('disabled', false);
  return false;
};

onSuccess = function(result, status, jqXHR) {
  $.notify({
    // options
    message: 'SIM has been added.'
  },{
    // settings
    type: 'info'
  });
  $(".modal-backdrop").remove();
  $("#m_modal_1").modal("hide");
  $("#api-wait").addClass("hide_me");
  a.load();
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

window.initializeSIMs = function() {
  startSIMDatatable();
  startMORRISChartJS();
  clearCHARThtml();
  showHideColumns();
  onSIMButton();
  saveModal();
};
