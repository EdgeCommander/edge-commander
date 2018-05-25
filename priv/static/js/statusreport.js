var vm = new Vue({
  el: '#status_rpt_main',
  data: {
    show_loading: false
  },
  methods: {
    sendAJAXRequest: function(settings) {
      var headers, token, xhrRequestChangeMonth;
      token = $('meta[name="csrf-token"]');
      if (token.length > 0) {
        headers = {
        "X-CSRF-Token": token.attr("content")
        };
        settings.headers = headers;
      }
      return xhrRequestChangeMonth = jQuery.ajax(settings);
    },
    onErrorR: function(jqXHR, status, error) {
      return false;
    },
    onSuccessR: function(result, status, jqXHR) {
      this.show_loading = false;
      this.startReport(result.data)
      return true;
    },
    startReport: function(logs) {
      var chart;
      nvr_logs = logs;
      chart = visavailChart();
      chart.width($('.m-portlet__body').width() - 150)
      chart.dataHeight = 10
      $('#draw_report').text('');
      d3.select('#draw_report').datum(logs).call(chart);
    },
    initializeReport: function(days) {

      var data = {};
      data.history_days = days
      var settings;

      settings = {
        cache: false,
        data: data,
        dataType: 'json',
        error: this.onErrorR,
        success: this.onSuccessR,
        contentType: "application/x-www-form-urlencoded",
        type: "GET",
        url: "update_status_report"
      };

      this.sendAJAXRequest(settings);
    },
    initializeDate: function(){
      $( document ).ready(function() {
        $(".ranges ul li").on("click", function() {
          this.show_loading = true;
          clickedValues = $(this).data("range-key");

          var history_days;

          switch (clickedValues) {
          case "Today":
              history_days = 1
              break
          case "Yesterday":
              history_days = 2
              break
          case "Last 7 Days":
              history_days = 7
              break
          case "Last 30 Days":
              history_days = 30
              break
          default:
              history_days = 1
          }

          vm.initializeReport(history_days);
        });
      });
    },
    resizeWindow: function(){
      $(window).resize(function() {
        vm.startReport(nvr_logs);
      });
    }
  }, // end of methods
   mounted(){
    this.initializeReport(1);
    this.initializeDate();
    this.resizeWindow();
   }
});
