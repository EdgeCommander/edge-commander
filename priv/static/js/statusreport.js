var initializeReport, sendAJAXRequest, nvr_logs;

sendAJAXRequest = function(settings) {
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

var onErrorR, onSuccessR;

onErrorR = function(jqXHR, status, error) {
  return false;
};

onSuccessR = function(result, status, jqXHR) {
  console.log(result);
  startReport(result.data)
  return true;
};

var onResize, startReport;

startReport = function(logs) {
  console.log("starting")
  var chart;
  nvr_logs = logs;
  chart = visavailChart();
  chart.width($('.m-portlet__body').width() - 150)
  chart.dataHeight = 10
  // chart.width($('#visavail_container').width() - 200);
  $('#draw_report').text('');
  d3.select('#draw_report').datum(logs).call(chart);
};


$(window).resize(function() {
  startReport(nvr_logs);
});

initializeReport = function() {

  var data = {};
  var settings;

  settings = {
    cache: false,
    data: data,
    dataType: 'json',
    error: onErrorR,
    success: onSuccessR,
    contentType: "application/x-www-form-urlencoded",
    type: "GET",
    url: "/update_status_report"
  };

  sendAJAXRequest(settings);
}

var startDropDown;

startDropDown = function() {
  $('.dropdown').dropdown();
}

var onLoadStartReport = function () {
  
};

window.initializeStatusReport = function() {
  initializeReport();
  onResize();
};