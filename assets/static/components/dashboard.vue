<template>
  <div id="dashboard_main">
    <div class="m-content">
      <div class="row">
        <div class="col-sm-12">
          <div class="m-portlet m-portlet--mobile" style="margin-bottom: 5px;">
            <div class="m-portlet__body" style="padding: 5px;">
                <div class="row m-row--no-padding m-row--col-separator-xl">
              <div class="col-md-12 col-lg-6 col-xl-3">
                <!--begin::Total Profit-->
                <div class="m-widget24">           
                    <div class="m-widget24__item">
                        <h4 class="m-widget24__title">
                            Total SIMs
                        </h4><br>
                        <span class="m-widget24__desc">
                            SIMs for routers
                        </span>
                        <span class="m-widget24__stats m--font-brand">
                            {{total_sims}}
                        </span>
                    </div>              
                </div>
                <!--end::Total Profit-->
              </div>
              <div class="col-md-12 col-lg-6 col-xl-3">
                <!--begin::New Feedbacks-->
                <div class="m-widget24">
                   <div class="m-widget24__item">
                        <h4 class="m-widget24__title">
                            NVR
                        </h4><br>
                        <span class="m-widget24__desc">
                            All NVRs
                        </span>
                        <span class="m-widget24__stats m--font-info">
                            {{total_nvrs}}
                        </span>   
                    </div>    
                </div>
                <!--end::New Feedbacks--> 
              </div>
              <div class="col-md-12 col-lg-6 col-xl-3">
                <!--begin::New Orders-->
                <div class="m-widget24">
                  <div class="m-widget24__item">
                        <h4 class="m-widget24__title">
                            Total Routers
                        </h4><br>
                        <span class="m-widget24__desc">
                            Routers count
                        </span>
                        <span class="m-widget24__stats m--font-danger">
                            {{total_routers}}
                        </span>   
                    </div>    
                </div>
                <!--end::New Orders--> 
              </div>
              <div class="col-md-12 col-lg-6 col-xl-3">
                <!--begin::New Users-->
                <div class="m-widget24">
                   <div class="m-widget24__item">
                        <h4 class="m-widget24__title">
                            Total Sites
                        </h4><br>
                        <span class="m-widget24__desc">
                            Place of deployment
                        </span>
                        <span class="m-widget24__stats m--font-success">
                            {{total_sites}}
                        </span>   
                    </div>    
                </div>
                <!--end::New Users--> 
              </div>
            </div>
            </div>
          </div>
        </div>
        <div class="col-sm-8" style="padding-right: 5px">
          <div class="m-portlet m-portlet--mobile" style="margin-bottom: 5px;">
            <div class="m-portlet__body" style="padding: 5px;" id="sms_history_content">
              <div id="container" style="min-width: 310px; height: 400px; margin: 0 auto"></div>
            </div>
          </div>
        </div>
        <div class="col-sm-4 sim_log_datatable" style="padding-left: 0">
                <div class="m-portlet m-portlet--mobile" id="activity_content" style="min-height: 410px;max-height: 410px; overflow-y: auto;">
                  <div class="m-portlet__head">
              <div class="m-portlet__head-caption">
                <div class="m-portlet__head-title">
                  <h3 class="m-portlet__head-text">
                    Recent User Activity
                  </h3>
                </div>
              </div>
            </div>
              <div class="m-portlet__body">
                  <div class="m-demo__preview">
                    <div class="m-list-timeline">
                        <div class="m-list-timeline__items">
                            <div class="m-list-timeline__item" v-for="log in activity_logs">
                              <span class="m-list-timeline__badge m-list-timeline__badge--success" v-if="log.event === 'Login'"></span>
                              <span class="m-list-timeline__badge m-list-timeline__badge--danger" v-else-if="log.event === 'Logout'"></span>
                              <span class="m-list-timeline__badge m-list-timeline__badge--brand" v-else-if="log.event.includes('Site') == true"></span>
                              <span class="m-list-timeline__badge m-list-timeline__badge--warning" v-else-if="log.event.includes('SMS') == true"></span>
                              <span class="m-list-timeline__badge m-list-timeline__badge--info" v-else-if="log.event.includes('SIM') == true || log.event.includes('Sim') == true"></span>
                              <span class="m-list-timeline__badge " v-else></span>
                              <span class="m-list-timeline__text" v-html="log.event"></span>
                              <span class="m-list-timeline__time">{{log.inserted_at | date_format}} </span>
                            </div>
                        </div>
                    </div>
                  </div>
              </div>
            </div>
        </div>
        <div class="col-sm-12" >
          <!--begin:: Widgets/Sales States-->
          <div class="m-portlet m-portlet--full-height ">
            <div class="m-portlet__head">
              <div class="m-portlet__head-caption">
                <div class="m-portlet__head-title">
                  <h3 class="m-portlet__head-text">
                    Quick SIMs Overview
                  </h3>
                </div>
              </div>
            </div>
            <div class="m-portlet__body" style="padding: 15px">
              <table  class="table table-striped  table-hover table-bordered datatable display nowrap" cellspacing="0" width="100%" id="sms_summary">
                  <thead>
                    <tr>
                      <th>Number</th>
                      <th>Name</th>
                      <th>Last SMS DateTime</th>
                      <th>Last SMS</th>
                      <th>Bill Date</th>
                      <th>SMS since Last bill</th>
                    </tr>
                  </thead>
              </table>
            </div>
          </div>
          <!--end:: Widgets/Sales States-->  
        </div>
      </div>
    </div>
</div>
</template>
<script>
module.exports = {
  name: 'dashboard',
  data: function(){
    return{
      total_sims: 0,
      total_nvrs: 0,
      total_routers: 0,
      total_sites: 0,
      logsDataTable: null,
      activity_logs: [],
      categories_dates: [],
      delivered_sms: [],
      received_sms: [],
      pending_sms: []
    }
  },
  filters: {
    date_format: function(date){
     return moment(date).format('DD-MM-YYYY HH:mm:ss');
    }
  },
  methods: {
    initializeTable: function(){

      $.fn.dataTable.moment("DD-MM-YYYY HH:mm:ss");
      let simsDataTable = $('#sms_summary').DataTable({
      fnInitComplete: function(){
          // Enable TFOOT scoll bars
          $('.dataTables_scrollFoot').css('overflow', 'auto');
          $('.dataTables_scrollHead').css('overflow', 'auto');
          // Sync TFOOT scrolling with TBODY
          $('.dataTables_scrollFoot').on('scroll', function () {
            $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
          });
          $('.dataTables_scrollHead').on('scroll', function () {
            $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
          });
      },
      ajax: {
      url: "/sims/data/json",
        dataSrc: function(data) {
          return data.logs;
        },
        error: function(xhr, error, thrown) {
          if (xhr.responseJSON) {
            console.log(xhr.responseJSON.message);
          } else {
            console.log("Something went wrong, Please try again.");
          }
        }
      },
      columns: [
      {
        class: "text-left number",
        data: function(row, type, set, meta) {
          return row.number
        }
      },
      {
        class: "text-left name",
        data: function(row, type, set, meta) {
          return row.name;
        }
      },
      {
        class: "text-center last_sms_date",
        data: function(row, type, set, meta) {
          let last_sms_date = row.last_sms_date
          if(last_sms_date != "-"){
            last_sms_date = moment(row.last_log_reading_at).format('DD-MM-YYYY HH:mm:ss');
          }
          return last_sms_date;
        }
      },
      {
        class: "last_sms",
        data: function(row, type, set, meta) {
          return row.last_sms;
        }
      },
      {
        class: "text-center last_bill_date",
        data: function(row, type, set, meta) {
          let last_bill_date;
          last_bill_date = row.last_bill_date
          if(last_bill_date != "-"){
            last_bill_date = moment(row.last_bill_date).format('DD-MM-YYYY');
          }
          return last_bill_date;
        }
      },
      {
        class: "text-center sms_since_last_bill",
        data: function(row, type, set, meta) {
          return row.sms_since_last_bill;
        }
      }
      ],
      info: false,
      bPaginate: false,
      lengthChange: false,
      order: [[ 2, "desc" ]],
      scrollX: true,
      scrollY: false
    });
    return this.dataTable = simsDataTable;
    this.dataTable.search("");
   },
   convert_date_time_format: function(times){
    let date = times.split("-")
    return date[2] +"-"+ date[1]  +"-"+ date[0]
   },
   init_chart: function(){
    mApp.block("#sms_history_content", {
      overlayColor: "#000000",
      type: "loader",
      state: "success",
      message: "Loading..."
    })
      Highcharts.chart('container', {
        chart: {
          type: 'column'
        },
        colors: ['#363636', '#47bcfa', '#9c2a3d'],
        credits: {
          enabled: false
        },
        title: {
          text: 'Last Week SMS Overview'
        },
        subtitle: {
            text: ''
        },
        xAxis: {
          categories: this.categories_dates,
          crosshair: true
        },
        yAxis: {
          min: 0,
          title: {
            text: 'Messages to router'
          }
        },
        plotOptions: {
          column: {
            pointPadding: 0.2,
            borderWidth: 0
          }
        },
        series: [{
          name: 'Send',
          data: this.delivered_sms
        }, {
          name: 'Received',
          data: this.received_sms
        }, {
          name: 'Not Delivered',
          data: this.pending_sms
        }]
      });
    },
    initializeLogsTable: function(){
      mApp.block("#activity_content", {
        overlayColor: "#000000",
        type: "loader",
        state: "success",
        message: "Loading..."
      })
     var from_date = $.datepicker.formatDate('yy-mm-dd', new Date(new Date().getTime() - (168 * 60 * 60 * 1000)));
     var to_date = $.datepicker.formatDate('yy-mm-dd', new Date());
      this.$http.get("/user_logs/" + from_date + "/" + to_date).then(response => {
        this.activity_logs = response.body.activity_logs;
        mApp.unblock("#activity_content")
      });
    },
    get_total_sims: function(){
      this.$http.get('/dashboard/total_sims').then(response => {
        this.total_sims = response.body.total_sims;
      });
    },
    get_total_nvrs: function(){
      this.$http.get('/dashboard/total_nvrs').then(response => {
        this.total_nvrs = response.body.total_nvrs;
      });
    },
    get_total_routers: function(){
      this.$http.get('/dashboard/total_routers').then(response => {
        this.total_routers = response.body.total_routers;
      });
    },
    get_total_sites: function(){
      this.$http.get('/dashboard/total_sites').then(response => {
          this.total_sites = response.body.total_sites;
      });
    },
    get_sms_history: function(){
      this.$http.get('/dashboard/weekly_sms_overview').then(response => {
       let history = response.body.sms_history
        var i;
        for (i = 0; i < history.length; i++) {
          let dates = this.convert_date_time_format(history[i].date)
          this.categories_dates.push(dates);
          this.delivered_sms.push(history[i].delivered_sms);
          this.received_sms.push(history[i].received_sms);
          this.pending_sms.push(history[i].pending_sms);
        }
          this.init_chart();
          mApp.unblock("#sms_history_content")
      });
    },
    active_menu_link: function(){
      $("li").removeClass(" m-menu__item--active");
      $(".dashboard").addClass(" m-menu__item--active");
      $("#m_aside_left").removeClass("m-aside-left--on");
      $("body").removeClass("m-aside-left--on");
      $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
    }
  },
  mounted(){
    this.get_sms_history();
    this.init_chart();
    this.active_menu_link();
    this.initializeTable();
    this.get_total_sims();
    this.get_total_nvrs();
    this.get_total_routers();
    this.get_total_sites();
    this.initializeLogsTable();
  }
}
</script>

<style lang="scss">
</style>
