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
        <div class="col-sm-8 sms_history_panel">
          <div class="m-portlet m-portlet--mobile" style="margin-bottom: 5px;">
            <div class="m-portlet__body" style="padding: 5px;" id="sms_history_content">
              <highcharts :options="chartOptions" style="min-width: 310px; height: 400px; margin: 0 auto"></highcharts>
            </div>
          </div>
        </div>
        <div class="col-sm-4 sim_log_datatable">
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
            <div class="m-portlet__body" style="padding: 0 15px">
              <v-horizontal-scroll />
                <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
                  <div class="table-responsive">
                    <vuetable ref="vuetable" 
                      api-url="/sims/data/json"
                      :fields="fields"
                      pagination-path=""
                      data-path="data"
                      :per-page="perPage"
                      :sort-order="sortOrder"
                      :append-params="moreParams"
                      @vuetable:pagination-data="onPaginationData"
                      @vuetable:initialized="onInitialized"
                      @vuetable:loading="showLoader"
                      @vuetable:loaded="hideLoader"
                      :css="css.table"
                    >
                      <template slot="number" slot-scope="props">
                        <router-link v-bind:to="get_url(props.rowData.number)" class="m-menu__link">
                        {{props.rowData.number}}
                        </router-link>
                      </template>
                    </vuetable>
                  </div>
                  <div style="height: 10px"></div>
                  <div class="">
                    <div class="pull-left">
                      <div class="field perPage-margin">
                      <label>Per Page:</label>
                        <select class="ui simple dropdown" v-model="perPage">
                            <option :value="60">60</option>
                            <option :value="100">100</option>
                            <option :value="500">500</option>
                            <option :value="1000">1000</option>
                        </select>
                      </div>
                      <vuetable-pagination-info ref="paginationInfo"></vuetable-pagination-info>
                    </div>
                    
                    <component :is="paginationComponent" ref="pagination" :css="css.pagination"
                      @vuetable-pagination:change-page="onChangePage"
                    ></component>
                    <div class="clearfix"></div>

                  </div>
                </div>
            </div>
          </div>
          <!--end:: Widgets/Sales States-->  
        </div>
      </div>
    </div>
</div>
</template>
<script>
import TableWrapper from "./TableWrapper.js";
import FieldsDef from "./FieldsDef.js";
import moment from "moment";
import {Chart} from 'highcharts-vue'

export default {
  components: {
    highcharts: Chart,
    TableWrapper
  },
  data(){
    return{
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 60,
      sortOrder: [
        {
          field: 'name',
          direction: 'asc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      fields: FieldsDef,
      total_sims: 0,
      total_nvrs: 0,
      total_routers: 0,
      total_sites: 0,
      logsDataTable: null,
      activity_logs: [],
      categories_dates: [],
      delivered_sms: [],
      received_sms: [],
      pending_sms: [],
      chartOptions: {
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
          categories: [],
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
          data: []
        }, {
          name: 'Received',
          data: []
        }, {
          name: 'Not Delivered',
          data: []
        }]
      }
    }
  },
  watch: {
    perPage(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetable.refresh();
      });
    },

    paginationComponent(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.pagination.setPaginationData(
          this.$refs.vuetable.tablePagination
        );
      });
    }
  },

  filters: {
    date_format(date){
     return moment(date).format('DD-MM-YYYY HH:mm:ss');
    }
  },
  methods: {
    convert_date_time_format(times){
      let date = times.split("-")
      return date[2] +"-"+ date[1]  +"-"+ date[0]
    },

    get_total_sims(){
      this.$http.get('/dashboard/total_sims').then(response => {
        this.total_sims = response.body.total_sims;
      });
    },

    get_total_nvrs(){
      this.$http.get('/dashboard/total_nvrs').then(response => {
        this.total_nvrs = response.body.total_nvrs;
      });
    },

    get_total_routers(){
      this.$http.get('/dashboard/total_routers').then(response => {
        this.total_routers = response.body.total_routers;
      });
    },

    get_total_sites(){
      this.$http.get('/dashboard/total_sites').then(response => {
          this.total_sites = response.body.total_sites;
      });
    },

    initializeLogsTable(){
    var from_date = moment().subtract(2, 'day').format('YYYY-MM-DD');
    var to_date = moment().format('YYYY-MM-DD');

    this.$http.get("/user_logs/", {
      params:{
        fromDate: from_date,
        toDate: to_date,
        sort: "inserted_at|desc",
        page: 1,
        per_page: 60
      }
    }).then(response => {
        this.activity_logs = response.body.data;
      });
    },

    get_sms_history(){
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
        this.chart_data(this.categories_dates, this.delivered_sms, this.received_sms, this.pending_sms)
      });
    },

    chart_data(categories_dates, delivered_sms, received_sms, pending_sms){
      this.chartOptions = {
        xAxis: {
          categories: categories_dates
        },
        series: [{
          name: 'Send',
          data: delivered_sms
        },
        {
          name: 'Received',
          data: received_sms
        },
        {
          name: 'Not Delivered',
          data: pending_sms
        }]
      }
    },

    onRefreshSimTable() {
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onPaginationData(tablePagination) {
      this.$refs.paginationInfo.setPaginationData(tablePagination);
      this.$refs.pagination.setPaginationData(tablePagination);
    },

    onChangePage(page) {
      this.$refs.vuetable.changePage(page);
    },

    onInitialized(fields) {
      this.vuetableFields = fields;
    },

    showLoader() {
      this.loading = "loading";
    },

    hideLoader() {
      this.loading = "";
    },

    get_url(number) {
      return "/sims/" + number
    }

  },
  beforeUpdate() {
    document.addEventListener("resize", this.setScrollBar());
  },
  mounted(){
    this.$nextTick(function() {
      window.addEventListener('resize', this.setScrollBar);
      this.setScrollBar()
    });
    this.$events.$on('refresh-sim-table', eventData => this.onRefreshSimTable(eventData))

    this.get_sms_history();
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
