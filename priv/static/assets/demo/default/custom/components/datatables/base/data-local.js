
var DatatableDataLocalDemo = function() {
    var e = function() {
            a = $(".m_datatable").mDatatable({
                data: {
                  type: "remote",
                  source: "/get_sims_data",
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
                    sortable: !1,
                    selector: !1,
                    template: function(t) {
                      return '<span data-toggle="modal" data-target="#m_modal_4" style="color: blue;text-decoration: underline;cursor: pointer;" href="#" id="show-morris-graph" data-id="' + t.number + '">' + t.number  + '</span>'
                    }
                }, {
                    field: "name",
                    title: "Name",
                    width: 200
                }, {
                    field: "allowance",
                    title: "Allowance",
                    textAlign: "center",
                    responsive: {
                        visible: "lg"
                    }
                }, {
                    field: "volume_used_today",
                    title: "Volume Used Today",
                    textAlign: "center",
                    width: 200
                }, {
                    field: "volume_used_yesterday",
                    title: "Volume Used Yesterday",
                    textAlign: "center",
                    width: 200,
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
                  textAlign: "center",
                  template: function(t) {
                    var days_left = (t.allowance_in_number - t.current_in_number) / (t.current_in_number - t.yesterday_in_number)
                    return Math.round(days_left * 100) / 100;
                  }
                }
              ]
            }),
            i = a.getDataSourceQuery();
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
    settingsForMorris = {
      cache: false,
      data: {sim_number: $(this).data("id")},
      dataType: 'json',
      error: onMorrisError,
      success: onMorrisSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "GET",
      url: "/create_chartjs_line_data"
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

window.initializeSIMs = function() {
  startSIMDatatable();
  startMORRISChartJS();
  clearCHARThtml();
  showHideColumns();
};
