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
                            <input type="text" class="form-control m-input m-input--solid" id="m_sms_datepicker_from">
                        </div>
                        </div>
                    </div>
                    <div class="col-sm-5">
                         <div class="form-group m-form__group row">
                        <label class="col-sm-2 col-form-label">
                            To:
                        </label>
                        <div class="col-sm-10">
                            <input type="text" class="form-control m-input m-input--solid" id="m_sms_datepicker_to">
                        </div>
                        </div>
                    </div>
                    <div class="col-sm-2 battery_column_hide_button">
                      <div href="javascript:void(0)" class="btn btn-default grey" v-on:click="onHideShowButton">
                        <i class="fa fa-columns"></i>
                      </div>
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
              <table id="status-datatable" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
                  <thead>
                      <tr>
                          <th v-for="(item, index) in headings" style="vertical-align: middle;">{{item.column}} </br> {{item.unit}}</th>
                      </tr>
                  </thead>
              </table>
            </div>
          </div>
        </div>
      </div>
       <div class="tab-pane" id="m_tabs_1_2" role="tabpanel">
          <div class="m-content" style="padding-top:0">
              <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
                <div class="m-portlet__body" style="padding: 10px;" id="graph_one_loading">
                     <div id="battery_graph_one" style="height:80vh"></div>
                </div>
              </div>
          </div>
          <div class="m-content">
              <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
                <div class="m-portlet__body" style="padding: 10px;" id="graph_two_loading">
                     <div id="battery_graph_two" style="height:80vh"></div>
                </div>
              </div>
          </div>
          <div class="m-content">
              <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
                <div class="m-portlet__body" style="padding: 10px;" id="graph_three_loading">
                     <div id="battery_graph_three" style="height:80vh"></div>
                </div>
              </div>
          </div>
      </div>
    </div>
    <!-- begin::modal -->
    <div class="modal fade toggle-datatable-columns" ref="hideShow" style="padding: 0px;" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
      <div class="modal-dialog modal-sm" role="document">
          <div class="modal-content" style="padding: 0px;">
              <div class="modal-header">
                  <h5 class="modal-title" id="exampleModalLabel">
                      {{form_labels.hide_show_title}}
                  </h5>
                  <div class="cancel">
                    <a href="#" id="discardModal" data-dismiss="modal">X</a>
                  </div>
              </div>
              <div class="modal-body" id="body-sim-dis">
                  <div class="form-group">
                    <div class="column-checkbox" v-for="(item, index) in headings">
                        <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;"><input type="checkbox" class="rule-column" v-bind:data-id="item.id" v-on:change="showHideColumns(item.id)"><span></span> {{item.column}}</label>
                    </div>
                  </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{{form_labels.hide_show_button}}</button>
              </div>
          </div>
      </div>
    </div>
  </div>
</template>

<script>
import * as jquery from 'jquery';
import datepicker from 'jquery-ui'

import Vue from 'vue'
import moment from "moment";
import Highcharts from "highcharts";
import single_battery from './single_battery.vue'
import App from '../../App.vue'
const app = new Vue(App)

export default {
  name: 'single_battery',
  data: function(){
    return{
      dataTable: null,
      show_loading: false,
      show_add_errors: false,
      show_edit_errors: false,
      show_edit_messages: "",
      show_add_messages: "",
      battery_voltages: [],
      time_list: null,
      panel_voltages: [],
      categories_dates: [],
      maximum_voltages: [],
      minimum_voltages: [],
      source_url: "",
      battery_name: "",
      headings: [
        {column: "Reading DateTime", id: "datetime", unit: ""},
        {column: "Battery voltage", id: "voltage", unit: "V"},
        {column: "Battery current", id: "i_value", unit: "A"},
        {column: "Panel voltage", id: "vpv_value", unit: "V"},
        {column: "Panel power", id: "ppv_value", unit: "W"},
        {column: "Serial#", id: "serial_no", unit: ""},
        {column: "State of operation", id: "cs_value", unit: ""},
        {column: "Error code", id: "err_value", unit: ""},
        {column: "Load current", id: "il_value", unit: "A"},
        {column: "MPPT", id: "mppt_value", unit: ""},
        {column: "Load", id: "load_value", unit: ""},
        {column: "Yield total", id: "h19_value", unit: "Wh"},
        {column: "Yield today", id: "h20_value", unit: "Wh"},
        {column: "Maximum power today", id: "h21_value", unit: "W"},
        {column: "Yield yesterday", id: "h22_value", unit: "Wh"},
        {column: "Maximum power yesterday", id: "h23_value", unit: "W"},
        {column: "Consumed amphours", id: "consumed_amphours"},
        {column: "Soc", id: "soc_value"},
        {column: "Time To Go", id: "time_to_go"},
        {column: "Alarm", id: "alarm"},
        {column: "Relay", id: "relay"},
        {column: "Deepest Discharge", id: "h1_value"},
        {column: "Last Discharge", id: "h2_value"},
        {column: "Average Discharge", id: "h3_value"},
        {column: "Charge Cycles", id: "h4_value"},
        {column: "Full Discharges", id: "h5_value"},
        {column: "Total Drawn", id: "h6_value", unit: "A"},
        {column: "Minimum Voltage", id: "h7_value"},
        {column: "Maximum Voltage", id: "h8_value"},
        {column: "Time Since Last Full Charge", id: "h9_value"},
        {column: "Automatic Syncs", id: "h10_value"},
        {column: "Low Voltage Alarms", id: "h11_value"}
      ],
      form_labels: {
        hide_show_title: "Show/Hide Columns",
        hide_show_button: "OK"
      }
    }
  },
  methods: {
    date_format: function(id){
      let string = $("#" + id).val().split("-")
      return string[2] +"-"+ string[1]  +"-"+ string[0]
    },
    initializeTable: function(){
      $( "#m_sms_datepicker_from").datepicker({autoclose:true, dateFormat:"dd-mm-yy"}).datepicker("setDate", new Date(new Date().getTime() - (48 * 60 * 60 * 1000)));
      $( "#m_sms_datepicker_to" ).datepicker({autoclose:true, dateFormat:"dd-mm-yy"}).datepicker("setDate", new Date());

      let from_date = this.date_format("m_sms_datepicker_from");
      let to_date = this.date_format("m_sms_datepicker_to");

      let statusDataTable = $('#status-datatable').DataTable({
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
      url: "/battery/data/" + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "/" + from_date + "/" + to_date,
        dataSrc: function(data) {
          return data.records;
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
        class: "text-center datetime",
        data: function(row, type, set, meta) {
          return moment(row.datetime).format('DD-MM-YYYY HH:mm:ss');
        }
      },
      {
        class: "text-center voltage",
        data: function(row, type, set, meta) {
          return row.voltage/1000;
        }
      },
      {
        class: "text-center i_value",
        data: function(row, type, set, meta) {
          return row.i_value/1000;
        }
      },
      {
        class: "text-center vpv_value",
        data: function(row, type, set, meta) {
          return row.vpv_value/1000;
        }
      },
      {
        class: "text-center ppv_value",
        data: function(row, type, set, meta) {
          return row.ppv_value;
        }
      },
      {
        class: "text-center serial_no",
        data: function(row, type, set, meta) {
          return row.serial_no;
        }
      },
      {
        class: "text-center cs_value",
        data: function(row, type, set, meta) {
          return row.cs_value;
        }
      },
      {
        class: "text-center err_value",
        data: function(row, type, set, meta) {
          return row.err_value;
        }
      },
      {
        class: "text-center il_value",
        data: function(row, type, set, meta) {
          return row.il_value/1000;
        }
      },
      {
        class: "text-center mppt_value",
        data: function(row, type, set, meta) {
          return row.mppt_value;
        }
      },
      {
        class: "text-center load_value",
        data: function(row, type, set, meta) {
          return row.load_value;
        }
      },
      {
        class: "text-center h19_value",
        data: function(row, type, set, meta) {
          return row.h19_value*1000;
        }
      },
      {
        class: "text-center h20_value",
        data: function(row, type, set, meta) {
          return row.h20_value*1000;
        }
      },
      {
        class: "text-center h21_value",
        data: function(row, type, set, meta) {
          return row.h21_value;
        }
      },
      {
        class: "text-center h22_value",
        data: function(row, type, set, meta) {
          return row.h22_value*1000;
        }
      },
      {
        class: "text-center h23_value",
        data: function(row, type, set, meta) {
          return row.h23_value;
        }
      },
      {
        class: "text-center consumed_amphours",
        data: function(row, type, set, meta) {
          return row.consumed_amphours;
        }
      },
      {
        class: "text-center soc_value",
        data: function(row, type, set, meta) {
          return row.soc_value;
        }
      },
      {
        class: "text-center time_to_go",
        data: function(row, type, set, meta) {
          return row.time_to_go;
        }
      },
      {
        class: "text-center alarm",
        data: function(row, type, set, meta) {
          return row.alarm;
        }
      },
      {
        class: "text-center relay",
        data: function(row, type, set, meta) {
          return row.relay;
        }
      },
      {
        class: "text-center h1_value",
        data: function(row, type, set, meta) {
          return row.h1_value;
        }
      },
      {
        class: "text-center h2_value",
        data: function(row, type, set, meta) {
          return row.h2_value;
        }
      },
      {
        class: "text-center h3_value",
        data: function(row, type, set, meta) {
          return row.h3_value;
        }
      },
      {
        class: "text-center h4_value",
        data: function(row, type, set, meta) {
          return row.h4_value;
        }
      },
      {
        class: "text-center h5_value",
        data: function(row, type, set, meta) {
          return row.h5_value;
        }
      },
      {
        class: "text-center h6_value",
        data: function(row, type, set, meta) {
          return row.h6_value;
        }
      },
      {
        class: "text-center h7_value",
        data: function(row, type, set, meta) {
          return row.h7_value;
        }
      },
      {
        class: "text-center h8_value",
        data: function(row, type, set, meta) {
          return row.h8_value;
        }
      },
      {
        class: "text-center h9_value",
        data: function(row, type, set, meta) {
          return row.h9_value;
        }
      },
      {
        class: "text-center h10_value",
        data: function(row, type, set, meta) {
          return row.h10_value;
        }
      },
      {
        class: "text-center h11_value",
        data: function(row, type, set, meta) {
          return row.h11_value;
        }
      }
      ],
      info: false,
      bPaginate: false,
      lengthChange: false,
      scrollX: true,
      colReorder: true,
      stateSave:  true,
      order: [[ 0, "desc" ]]
    });
      return this.dataTable = statusDataTable;
   },
   showHideColumns: function(id){
    let column = this.dataTable.columns("." +id);
    if(column.visible()[0] == true){
      column.visible(false);
    }else{
      column.visible(true);
    }
   },
   onHideShowButton: function(){
    jquery(this.$refs.hideShow).modal("show");
   },
   initHideShow: function(){
    $(".rule-column").each(function(){
      let that = $(this).attr("data-id");
      let statusDataTable = $('#status-datatable').DataTable();
      let column = statusDataTable.columns("." +that);
      if(column.visible()[0] == true){
        $(this).prop('checked', true);
      }else{
        $(this).prop('checked', false);
      }
    });
   },
   get_session: function(){
    this.$http.get('/get_porfile').then(response => {
      this.user_id = response.body.id;
    });
   },
   active_menu_link: function(){
    $("li").removeClass(" m-menu__item--active");
    $(".batteries").addClass(" m-menu__item--active");
    $("#m_aside_left").removeClass("m-aside-left--on");
    $("body").removeClass("m-aside-left--on");
    $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
   },
   convert_date_time_format: function(times){
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
   init_graphs_data: function(){
      $( "#m_sms_datepicker_from").datepicker({autoclose:true, dateFormat:"dd-mm-yy"}).datepicker("setDate", new Date(new Date().getTime() - (48 * 60 * 60 * 1000)));
      $( "#m_sms_datepicker_to" ).datepicker({autoclose:true, dateFormat:"dd-mm-yy"}).datepicker("setDate", new Date());

      let from_date = this.date_format("m_sms_datepicker_from");
      let to_date = this.date_format("m_sms_datepicker_to");

      this.$http.get('/daily_battery/data/' + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "/" + from_date + "/" + to_date).then(response => {
        let history = response.body.voltages_history
        this.time_list = this.convert_date_time_format(history.time_list)
        this.battery_voltages = history.battery_voltages;
        this.panel_voltages = history.panel_voltages;
        this.graph_one(this.time_list, this.battery_voltages);
        this.graph_two(this.time_list, this.battery_voltages, this.panel_voltages);
      });

      this.$http.get('/battery_voltages_summary/data/' + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "/" + from_date + "/" + to_date).then(response => {
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
          this.graph_three(this.categories_dates, this.maximum_voltages, this.minimum_voltages);
      });
   },
   on_date_change: function() {
      let table_data = this.dataTable;
      let time_list = this.time_list;
      let battery_voltages = this.battery_voltages;
      let panel_voltages = this.panel_voltages;

      $('#m_sms_datepicker_from, #m_sms_datepicker_to').change(function(){
          let from_date = single_battery.methods.date_format("m_sms_datepicker_from");
          let to_date = single_battery.methods.date_format("m_sms_datepicker_to");
          let new_url = "/battery/data/" + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "/" + from_date + "/" + to_date
          table_data.ajax.url(new_url).load();

          $.get('/daily_battery/data/' + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "/" + from_date + "/" + to_date, function( data ) {
            let history = data.voltages_history
            time_list = single_battery.methods.convert_date_time_format(history.time_list)
            battery_voltages = history.battery_voltages;
            panel_voltages = history.panel_voltages;
            single_battery.methods.graph_one(time_list, battery_voltages);
            single_battery.methods.graph_two(time_list, battery_voltages, panel_voltages);
          });
         
          $.get('/battery_voltages_summary/data/' + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "/" + from_date + "/" + to_date, function( data ) {
            let history = data.records
            let category_dates = [];
            let maximum_voltages = [];
            let minimum_voltages = [];
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
              category_dates.push(date);
              maximum_voltages.push(max_value);
              minimum_voltages.push(min_value);
            }
            single_battery.methods.graph_three(category_dates, maximum_voltages, minimum_voltages);
          });
      });
   },
   graph_one: function(time_list, battery_voltages){
      Highcharts.setOptions({
        lang: {
          thousandsSep: ','
        }
      });

      Highcharts.chart('battery_graph_one', {
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
          categories: time_list,
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
          valueSuffix: ' V'
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
                [0, "#7cb5ec"],
                [1, Highcharts.Color("#7cb5ec").setOpacity(0).get('rgba')]
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
        series: [{
          name: 'Voltage',
          data: battery_voltages
        }]
      });
   },
   graph_two: function(time_list, battery_voltages, panel_voltages){
      Highcharts.setOptions({
        lang: {
          thousandsSep: ','
        }
      });

      Highcharts.chart('battery_graph_two', {
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
          categories: time_list,
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
                [0, Highcharts.getOptions().colors[0]],
                [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
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
        series: [{
          name: 'Battery Voltage',
          data: battery_voltages
        },
        {
          name: 'Panel Voltage',
          data: panel_voltages
        }]
      });
   },
   graph_three: function(categories_dates, maximum_voltages, minimum_voltages){
      Highcharts.setOptions({
        lang: {
          thousandsSep: ','
        }
      });

      Highcharts.chart('battery_graph_three', {
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
          categories: categories_dates,
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
          data: maximum_voltages
        }, {
          name: 'Minimum Voltage',
          data: minimum_voltages
        }]
      });
   },
   get_single_battery: function(){
      this.$http.get('/battery/data/'+ window.location.href.substring(window.location.href.lastIndexOf('/') + 1)).then(response => {
        this.battery_name = response.body.name;
        this.source_url = response.body.source_url;
      });
    }
  }, // end of methods
   mounted(){
    this.initializeTable();
    this.init_graphs_data();
    this.on_date_change();
    this.get_session();
    this.initHideShow();
    this.active_menu_link();
    this.get_single_battery();
    this.graph_one(this.time_list, this.battery_voltages);
    this.graph_two(this.time_list, this.battery_voltages, this.panel_voltages);
    this.graph_three(this.categories_dates, this.maximum_voltages, this.minimum_voltages);
   }
}
</script>

<style lang="scss">
</style>
