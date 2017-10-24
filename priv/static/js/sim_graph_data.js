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
                    height: 950,
                    footer: !1
                },
                sortable: !0,
                filterable: !1,
                pagination: false,
                columns: [
                {
                    field: "date_of_use",
                    title: "DateTime",
                    width: 250,
                    template: function(t) {
                      console.log(t);
                      return "" + moment(t.date_of_use).format('MMMM Do YYYY, H:mm:ss') +"";
                    }
                }, {
                    field: "allowance_in_number",
                    title: "MB Allowance",
                    textAlign: "center",
                    width: 200
                }, {
                    field: "current_in_number",
                    title: "MB Used (Today)",
                    textAlign: "center",
                    width: 200
                }, {
                    field: "percentage_used",
                    title: "% Used",
                    textAlign: "center",
                    width: 200
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


var startSIMTABDatatable = function() {
  dataTableSIMTAB.init();
};



window.initializeSimTabs = function() {
  console.log("helll");
  startMORRISChartJS();
  startSIMTABDatatable();
};