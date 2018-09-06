<template>
  <div>
    <!-- BEGIN: Subheader -->
    <div class="m-subheader " style="padding: 5px 30px 0 5px;">
        <div class="d-flex align-items-center">
            <div>
                <span class="m-subheader__daterange" id="m_dashboard_daterangepicker">
            <span class="m-subheader__daterange-label">
                <span class="m-subheader__daterange-title"></span>
                <span class="m-subheader__daterange-date m--font-brand"></span>
                </span>
                <a href="javascript:void(0)" class="btn btn-sm btn-brand m-btn m-btn--icon m-btn--icon-only m-btn--custom m-btn--pill">
                <i class="la la-angle-down"></i>
            </a>
                </span>
            </div>
        </div>
    </div>
    <!-- END: Subheader -->
    <div class="m-content">
        <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
            <div class="m-portlet__body">
                <div style="margin: 0 auto; width: 100%;padding: 10px" id="visavail_container">
                    <img src="/images/loading.gif" id="api-waiting" v-if="show_loading">
                    <p id="draw_report" class="margin-top-5"></p>
                </div>
            </div>
        </div>
    </div>
  </div>
</template>

<script>
module.exports = {
  name: 'status_report',
  data: function(){
    return{
      show_loading: false
    }
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
      module.exports.methods.startReport(result.data)
      return true;
    },
    startReport: function(logs) {
      let draw_report = document.getElementById('draw_report');
      var chart;
      var nvr_logs = logs;
      chart = visavailChart();
      chart.width($('.m-portlet__body').width() - 150)
      chart.dataHeight = 10
      draw_report.innerHTML = "";
      d3.select(draw_report).datum(logs).call(chart);
    },
    initializeReport: function(days) {
      this.show_loading = true;
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
          var clickedValues = $(this).data("range-key");

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
          module.exports.methods.initializeReport(history_days);
        });
      });
    }
  }, // end of methods
   mounted(){
    this.initializeReport(1);
    this.initializeDate();
   }
}
</script>

<style lang="scss">
</style>
