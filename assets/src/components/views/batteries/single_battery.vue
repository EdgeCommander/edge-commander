<template>
  <div>
    <div class="m-content" style="position: relative; width: 100%">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0;">
          <div class="row battery_details" style="padding:10px">
            <div class="col-lg-3 col-md-6" style="padding-top: 10px">
              <span>Name:</span> {{battery_name}}
            </div>
           <div class="col-lg-6 col-md-6" style="padding-top: 10px">
             <span>Source URL:</span> {{source_url}}
           </div>
            <div class="col-lg-3 btn_back">
              <router-link v-bind:to="'/batteries'" class="btn btn-default">Back to batteries</router-link>
            </div>
          </div>
       </div>
    </div>
    <div class="m-content"  style="padding-bottom: 0">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" style="padding: 10px;">
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right">
            <div class="row align-items-center">
              <div class="col-md-4">
                <div class="form-group m-form__group row align-items-center">
                  <div class="col-md-12">
                    <div class="m-input-icon m-input-icon--left tabs_panel">
                      <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item">
                            <a class="nav-link  active show" data-toggle="tab" href="#m_tabs_1_1">Table</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-toggle="tab" href="#m_tabs_1_2" >Graph</a>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
                <div class="col-md-8 order-1 order-md-2">
                  <div class="row">
                    <div class="col-sm-5">
                         <div class="form-group m-form__group row">
                        <label class="col-sm-2 col-form-label">
                            From:
                        </label>
                        <div class="col-sm-10">
                           <date-picker v-model="from_dateTime" ref="datepicker" @change="handleChange" lang="en" date  value-type="format"></date-picker>
                        </div>
                        </div>
                    </div>
                    <div class="col-sm-5">
                         <div class="form-group m-form__group row">
                        <label class="col-sm-2 col-form-label">
                            To:
                        </label>
                        <div class="col-sm-10">
                         <date-picker v-model="to_dateTime" ref="datepicker" @change="handleChange" lang="en" date  value-type="format"></date-picker>
                        </div>
                        </div>
                    </div>
                    <div class="col-sm-2 battery_column_hide_button">
                         <v-show-hide :vuetableFields="vuetableFields" />
                    </div>
                  </div>
              </div>
            </div>
          </div>
          <!--end: Search Form -->
          <div>
          </div>
        </div>
      </div>
    </div>
    <div class="tab-content">
      <div class="tab-pane  active show" id="m_tabs_1_1" role="tabpanel">
        <div class="m-content" style="padding-top:0">
          <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
            <div class="m-portlet__body" style="padding: 10px;">
              <v-horizontal-scroll />
            <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
              <div class="table-responsive">
                <vuetable ref="vuetable" 
                  api-url="/batteries/reading"
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
        </div>
      </div>
       <div class="tab-pane" id="m_tabs_1_2" role="tabpanel">
          <div class="m-content" style="padding-top:0">
              <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
                <div class="m-portlet__body" style="padding: 10px;" id="graph_one_loading">
                    <highcharts :options="chartOneOptions" style="height:80vh"></highcharts>
                </div>
              </div>
          </div>
          <div class="m-content">
              <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
                <div class="m-portlet__body" style="padding: 10px;" id="graph_two_loading">
                    <highcharts :options="chartTwoOptions" style="height:80vh"></highcharts>
                </div>
              </div>
          </div>
          <div class="m-content">
              <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
                <div class="m-portlet__body" style="padding: 10px;" id="graph_three_loading">
                      <highcharts :options="chartThreeOptions" style="height:80vh"></highcharts>
                </div>
              </div>
          </div>
      </div>
    </div>
  </div>
</template>

<script>
import FieldsDef from "./DataFieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import moment from "moment";
import DatePicker from 'vue2-datepicker'
import {Chart} from 'highcharts-vue'

export default {
  components: {
    TableWrapper,
    DatePicker,
    highcharts: Chart
  },
  data() {
    return {
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 60,
      sortOrder: [
        {
          field: 'datetime',
          direction: 'desc',
        }
      ],
      battery_id: this.$route.params.id,
      css: TableWrapper,
      moreParams: {
        battery_id: this.$route.params.id,
        fromDate: moment().subtract(2, "days").format("YYYY-MM-DD"),
        toDate: moment().format("YYYY-MM-DD")
      },
      fields: FieldsDef,
      dateParams: {},
      lang: {
        days: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        months: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        pickers: [],
        placeholder: {
          dateRange: 'Select Date Range'
        }
      },
      from_dateTime: moment().subtract(2, "days").format("YYYY-MM-DD"),
      to_dateTime: moment().format("YYYY-MM-DD"),
      categories_dates: [],
      maximum_voltages: [],
      minimum_voltages: [],
      battery_voltages: [],
      time_list: null,
      panel_voltages: [],
      categories_dates: [],
      source_url: "",
      battery_name: "",
      chartOneOptions: {
        chart: {
          type: 'area',
          zoomType: 'x'
        },
        credits: {
          enabled: false
        },
        title: {
          text: 'Battery Voltage'
        },
        subtitle: {
          text: 'Time Vs. Voltage'
        },
        xAxis: {
          categories: [],
          labels: {
            style: {
              fontSize: '12px',
              fontFamily: 'proxima-nova,helvetica,arial,sans-seri',
              whiteSpace: 'nowrap',
              paddingLeft: '10px',
              paddingRight: '10px',
              paddingTop: '10px',
              paddingBottom: '10px',
            }
          }
        },
        plotOptions: {
          area: {
            fillColor: {
              linearGradient: {
                x1: 0,
                y1: 0,
                x2: 0,
                y2: 1
              },
              stops: [
                [0, '#fff'],
                [1, '#7cb5ec']
              ]
            },
            marker: {
              radius: 2
            },
            lineWidth: 1,
            states: {
              hover: {
                lineWidth: 1
              }
            },
            threshold: null
          }
        },
        yAxis: {
          title: {
            text: 'Voltages'
          }
        },
        tooltip: {
          valueSuffix: ' V'
        },
        series: [{
          name: 'Voltage',
          data: []
        }]
      },
      chartTwoOptions: {
        chart: {
          type: 'line',
          zoomType: 'x'
        },
        credits: {
          enabled: false
        },
        title: {
          text: 'Voltage Summary'
        },
        subtitle: {
          text: 'Battery Vs. Solar panel'
        },
        xAxis: {
          categories: [],
          labels: {
            style: {
              fontSize: '12px',
              fontFamily: 'proxima-nova,helvetica,arial,sans-seri',
              whiteSpace: 'nowrap',
              paddingLeft: '10px',
              paddingRight: '10px',
              paddingTop: '10px',
              paddingBottom: '10px',
            }
          }
        },
        yAxis: {
          title: {
            text: 'Voltages'
          }
        },
        tooltip: {
          valueSuffix: ' V',
          shared: true
        },
        series: [{
          name: 'Battery Voltage',
          data: []
        },
        {
          name: 'Panel Voltage',
          data: []
        }]
      },
      chartThreeOptions: {
        chart: {
          type: 'column'
        },
        colors: ['#363636', '#47bcfa', '#9c2a3d'],
        credits: {
          enabled: false
        },
        title: {
          text: 'Battery Voltages Summary'
        },
        subtitle: {
          text: 'Date wise'
        },
        xAxis: {
          categories: [],
          crosshair: true,
        },
        yAxis: {
          title: {
            text: 'Voltages'
          }
        },
        tooltip: {
          valueSuffix: ' V',
          shared: true
        },
        series: [{
          name: 'Maximum Voltage',
          data: []
        }, {
          name: 'Minimum Voltage',
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

  beforeUpdate() {
    document.addEventListener("resize", this.setScrollBar());
  },

  mounted() {
    this.$nextTick(function() {
      window.addEventListener('resize', this.setScrollBar);
      this.setScrollBar()
    });
    this.init_graphs_data(this.from_dateTime, this.to_dateTime, this.battery_id)
    this.get_single_battery();
  },

  methods: {
    convert_date_time_format(times){
      let times_array = []
      for (let i = 0; i < times.length; i++) {
        let times_data = times[i].split(" ")
        let time = times_data[1]
        let date = times_data[0].split("-")
        let full_date_time = date[2] +"-"+ date[1]  +"-"+ date[0] + " " + times_data[1]
        times_array.push(full_date_time)
      }
      return times_array
    },

    init_graphs_data(from_date, to_date, battery_id){
      this.$http.get('/daily_battery/data/' + battery_id + "/" + from_date + "/" + to_date).then(response => {
        let history = response.body.voltages_history
        this.time_list = this.convert_date_time_format(history.time_list)
        this.battery_voltages = history.battery_voltages;
        this.panel_voltages = history.panel_voltages;
        this.chart_one_data(this.time_list, this.battery_voltages);
        this.chart_two_data(this.time_list, this.battery_voltages, this.panel_voltages);
      });

      this.$http.get('/battery_voltages_summary/data/' + battery_id + "/" + from_date + "/" + to_date).then(response => {
        let history = response.body.records
        let i;
        for (i = 0; i < history.length; i++) {
          let min_value = history[i].min_value
          if(min_value == null){
            min_value = 0;
          }
          let max_value = history[i].max_value
          if(max_value == null){
            max_value = 0;
          }

          let string = history[i].date.split("-")
          let date = string[2] +"-"+ string[1]  +"-"+ string[0]

          this.categories_dates.push(date);
          this.maximum_voltages.push(max_value);
          this.minimum_voltages.push(min_value);
        }
        this.chart_three_data(this.categories_dates, this.maximum_voltages, this.minimum_voltages);
      });
    },

    chart_one_data(category_list, battery_voltages){
      this.chartOneOptions = {
        xAxis: {
          categories: category_list
        },
        series: [{
          name: 'Voltage',
          data: battery_voltages
        }]
      }
    },

    chart_two_data(category_list, battery_voltages, panel_voltages){
      this.chartTwoOptions = {
        xAxis: {
          categories: category_list
        },
        series: [{
          name: 'Battery Voltage',
          data: battery_voltages
        },
        {
          name: 'Panel Voltage',
          data: panel_voltages
        }]
      }
    },

    chart_three_data(categories_dates, maximum_voltages, minimum_voltages){
      this.chartThreeOptions = {
        xAxis: {
          categories: categories_dates
        },
        series: [{
          name: 'Maximum Voltage',
          data: maximum_voltages
        },
        {
          name: 'Minimum Voltage',
          data: minimum_voltages
        }]
      }
    },

    get_single_battery: function(){
      this.$http.get('/battery/data/'+ this.battery_id).then(response => {
        this.battery_name = response.body.name;
        this.source_url = response.body.source_url;
      });
    },

    handleChange(val) {
      this.moreParams = {
        battery_id: this.$route.params.id,
        "fromDate": this.from_dateTime,
        "toDate": this.to_dateTime,
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
      this.init_graphs_data(this.from_dateTime, this.to_dateTime, this.battery_id)
    },

    onFilterSet (filters) {
      this.moreParams = {
        "search": filters.search
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onRefreshTable() {
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onAdded () {
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

    formatDateTime (value, fmt) {
      return (value == null)
      ? ''
      : moment(value, 'YYYY-MM-DD HH:mm:ss').format(fmt)
    },

    multiply_value(value){
      return value*1000
    },

    divide_value(value){
      return value/1000
    }
  }
}
</script>

<style lang="scss">
</style>
