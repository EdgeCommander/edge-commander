<template>
  <div>
    <div class="m-content" style="position: relative; width: 100%">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0;">
          <div class="row battery_details" style="padding:10px">
            <div class="col-lg-3 col-md-6" style="padding-top: 10px">
              <span>Name:</span>
              <select v-model="battery_switch_id" @change="switch_battery()">
                <option v-for="battery in batteries_list" v-bind:value="battery.id">{{battery.name}}</option>
              </select>
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
            <div class="ui segment">
              <div class="ui active inverted dimmer" v-if="show_loading_one">
                <div class="ui text loader">Loading</div>
              </div>
              <highcharts :options="chartOneOptions" style="height:80vh"></highcharts>
            </div>
          </div>
          <div class="m-content">
            <div class="ui segment">
              <div class="ui active inverted dimmer" v-if="show_loading_two">
                <div class="ui text loader">Loading</div>
              </div>
              <highcharts :options="chartTwoOptions" style="height:80vh"></highcharts>
            </div>
          </div>
          <div class="m-content">
            <div class="ui segment">
              <div class="ui active inverted dimmer" v-if="show_loading_three">
                <div class="ui text loader">Loading</div>
              </div>
              <highcharts :options="chartThreeOptions" style="height:80vh"></highcharts>
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
      battery_switch_id: this.$route.params.id,
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 60,
      batteries_list: [],
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
      source_url: "",
      battery_name: "",
      show_loading_one: true,
      chartOneOptions: {
        chart: {
          type: 'area',
          zoomType: 'xy'
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
          },
          min: 0
        },
        tooltip: {
          valueSuffix: ' V'
        },
        series: [{
          name: 'Voltage',
          data: []
        }]
      },
      show_loading_two: true,
      chartTwoOptions: {
        chart: {
          type: 'line',
          zoomType: 'xy'
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
      show_loading_three: false,
      chartThreeOptions: {
        chart: {
          type: 'column',
          zoomType: 'xy'
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
    this.get_batteries();
  },

  methods: {
    switch_battery(){
      let battery_id =  this.battery_switch_id
      window.location = '/battery/' + battery_id;
    },
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
      this.show_loading_one = true
      this.show_loading_two = true
      this.$http.get('/daily_battery/data/' + battery_id + "/" + from_date + "/" + to_date).then(response => {
        let history = response.body.voltages_history
        this.time_list = this.convert_date_time_format(history.time_list)
        this.battery_voltages = history.battery_voltages;
        this.panel_voltages = history.panel_voltages;

        var listDate = [];
        var startDate = this.from_dateTime;
        var endDate = this.to_dateTime;
        var dateMove = new Date(startDate);
        var strDate = startDate;

        while (strDate < endDate){
          var strDate = dateMove.toISOString().slice(0,10)
          listDate.push(moment(strDate).format("DD-MM-YYYY"))
          dateMove.setDate(dateMove.getDate()+1)
        }

        let category_list = this.time_list
        let battery_voltages = this.battery_voltages
        let panel_voltages = this.panel_voltages

        let dates_list = []
        category_list.forEach(datetime => {
          let [date, time] = datetime.split(" ")
          dates_list.push(date)
        })

        listDate.forEach(date => {
          if(dates_list.indexOf(date) == -1) {
            category_list.push(date + " 00:00:00")
            battery_voltages.push(null)
            panel_voltages.push(null)
          }
        })

        let i = 0
        let data_set = []
        category_list.forEach(datetime => {
          let item = {
            datetime: datetime,
            voltage: battery_voltages[i],
            panel_voltages: panel_voltages[i]
          }
          data_set.push(item)
        i++
        })

        let capitalsList = data_set.sort(function(a,b){
          let [a_date, a_time] = a.datetime.split(" ")
          let [a_day, a_month, a_year] = a_date.split("-")
          let a_datetime = moment(a_year + "-" + a_month + "-" + a_day + " " + a_time)

          let [b_date, b_time] = b.datetime.split(" ")
          let [b_day, b_month, b_year] = b_date.split("-")
          let b_datetime = moment(b_year + "-" + b_month + "-" + b_day + " " + b_time)

          if (a_datetime > b_datetime) return 1
          if (a_datetime < b_datetime) return -1
        });

        let category_list_new = []
        let battery_voltages_new = []
        let panel_voltages_new = []
        capitalsList.forEach(data => {
          category_list_new.push(data.datetime)
          battery_voltages_new.push(data.voltage)
          panel_voltages_new.push(data.panel_voltages)
        })

        this.chart_one_data(category_list_new, battery_voltages_new);
        this.chart_two_data(category_list_new, battery_voltages_new, panel_voltages_new);
      });

      this.show_loading_three = true
      this.$http.get('/battery_voltages_summary/data/' + battery_id + "/" + from_date + "/" + to_date).then(response => {
        let history = response.body.records
        let i;
        let categories_dates = []
        let maximum_voltages = []
        let minimum_voltages = []
        history.forEach(data => {

          let min_value = data.min_value
          if(min_value == null){
            min_value = 0;
          }
          let max_value = data.max_value
          if(max_value == null){
            max_value = 0;
          }

          let string = data.date.split("-")
          let date = string[2] +"-"+ string[1]  +"-"+ string[0]

          categories_dates.push(date)
          maximum_voltages.push(max_value)
          minimum_voltages.push(min_value)
        })
        this.chart_three_data(categories_dates, maximum_voltages, minimum_voltages);
      });
    },

    chart_one_data(category_list, battery_voltages){
      this.show_loading_one = false
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
      this.show_loading_two = false
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
      this.show_loading_three = false
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

    get_batteries: function(){
      this.$http.get("/battery", {
      params:{
        sort: "name|desc",
        page: 1,
        per_page: 500
      }
      }).then(response => {
        this.batteries_list = response.body.data;
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
      return (value/1000).toFixed(2)
    }
  }
}
</script>

<style lang="scss">
</style>
