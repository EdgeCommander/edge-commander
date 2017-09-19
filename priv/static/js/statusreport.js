var initializeReport, sendAJAXRequest, nvr_logs;

sendAJAXRequest = function(settings) {
  var headers, token, xhrRequestChangeMonth;
  token = $('meta[name="csrf-token"]');
  if (token.size() > 0) {
    headers = {
      "X-CSRF-Token": token.attr("content")
    };
    settings.headers = headers;
  }
  return xhrRequestChangeMonth = jQuery.ajax(settings);
};

var onError, onSuccess;

onError = function(jqXHR, status, error) {
  return false;
};

onSuccess = function(result, status, jqXHR) {
  console.log(result);
  startReport(result.data)
  return true;
};

var onResize, startReport;

startReport = function(logs) {
  console.log("starting")
  var chart;
  nvr_logs = logs;
  chart = visavailChart().width(900);
  // chart.width($('#visavail_container').width() - 500);
  $('#draw_report').text('');
  d3.select('#draw_report').datum(logs).call(chart);
};

onResize = function() {
  return $(window).resize(function() {
    return startReport(nvr_logs);
  });
};

initializeReport = function() {
  console.log("ddddgdgg");
  $(".start_report").on("change", function(){

    var data = {};
    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onError,
      success: onSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "GET",
      url: "/update_status_report"
    };

    sendAJAXRequest(settings);
  });
}

var startDropDown;

startDropDown = function() {
  $('.dropdown').dropdown();
}

var onLoadStartReport = function () {
  
};

window.initializeStatusReport = function() {
  initializeReport();
  startDropDown();
  onResize();
};