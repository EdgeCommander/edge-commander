<template>
  <div>
    <div class="m-content">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" style="padding: 10px;">
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right m--margin-bottom-10">
            <div class="row align-items-center">
              <div class="col-md-6">
                <div class="form-group m-form__group row align-items-center">
                  <div class="col-md-12">
                    <div class="m-input-icon m-input-icon--left">
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
                <div class="col-md-6 order-1 order-md-2 m--align-right">
                  <div class="row">
                    <div class="col-sm-5">
                         <div class="form-group m-form__group row">
                        <label class="col-lg-2 col-form-label">
                            From:
                        </label>
                        <div class="col-lg-10">
                            <input type="text" class="form-control m-input m-input--solid" id="m_sms_datepicker_from">
                        </div>
                        </div>
                    </div>
                    <div class="col-sm-5">
                         <div class="form-group m-form__group row">
                        <label class="col-lg-2 col-form-label">
                            To:
                        </label>
                        <div class="col-lg-10">
                            <input type="text" class="form-control m-input m-input--solid" id="m_sms_datepicker_to">
                        </div>
                        </div>
                    </div>
                    <div class="col-sm-2">
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
          <div class="tab-content">
                <div class="tab-pane  active show" id="m_tabs_1_1" role="tabpanel">
                  <table id="status-datatable" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
                      <thead>
                          <tr>
                              <th v-for="(item, index) in headings" style="vertical-align: middle;">{{item.column}} </br> {{item.unit}}</th>
                          </tr>
                      </thead>
                  </table>
              </div>
               <div class="tab-pane" id="m_tabs_1_2" role="tabpanel">
                  <div id="voltages_graph_content">
                    <div id="voltages_graph" style="height:80vh"></div>
                  </div>
              </div>
          </div>
        </div>
      </div>

    </div>
    <div class="m-content">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" style="padding: 10px;">
          <div id="voltages_graph_other" style="height:80vh"></div>
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
import Vue from 'vue'
import App from './App.vue'
const app = new Vue(App)

module.exports = {
  name: 'battery_status',
  data: function(){
    return{
      dataTable: null,
      m_form_search: "",
      show_loading: false,
      show_add_errors: false,
      show_edit_errors: false,
      show_edit_messages: "",
      show_add_messages: "",
      battery_voltages: [],
      time_list: null,
      status_date_list: null,
      panel_voltages: [],
      headings: [
        {column: "Reading DateTime", id: "datetime", unit: ""},
        {column: "Battery voltage", id: "voltage", unit: "mV"},
        {column: "Battery current", id: "i_value", unit: "mA"},
        {column: "Panel voltage", id: "vpv_value", unit: "mV"},
        {column: "Panel power", id: "ppv_value", unit: "W"},
        {column: "Serial#", id: "serial_no", unit: ""},
        {column: "State of operation", id: "cs_value", unit: ""},
        {column: "Error code", id: "err_value", unit: ""},
        {column: "Yield total", id: "h19_value", unit: "0.01 kWh"},
        {column: "Yield today", id: "h20_value", unit: "0.01 kWh"},
        {column: "Maximum power today", id: "h21_value", unit: "W"},
        {column: "Yield yesterday", id: "h22_value", unit: "0.01 kWh"},
        {column: "Maximum power yesterday", id: "h23_value", unit: "W"}
      ],
      form_labels: {
        hide_show_title: "Show/Hide Columns",
        hide_show_button: "OK"
      }
    }
  },
  methods: {
    initializeTable: function(){
      $( "#m_sms_datepicker_from").datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date(new Date().getTime() - (48 * 60 * 60 * 1000)));
      $( "#m_sms_datepicker_to" ).datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date());

      let from_date = $("#m_sms_datepicker_from").val(),
      to_date = $("#m_sms_datepicker_to").val();

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
      url: "/battery/data/" + from_date + "/" + to_date,
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
          return row.datetime;
        }
      },
      {
        class: "text-center voltage",
        data: function(row, type, set, meta) {
          return row.voltage;
        }
      },
      {
        class: "text-center i_value",
        data: function(row, type, set, meta) {
          return row.i_value;
        }
      },
      {
        class: "text-center vpv_value",
        data: function(row, type, set, meta) {
          return row.vpv_value;
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
        class: "text-center h19_value",
        data: function(row, type, set, meta) {
          return row.h19_value;
        }
      },
      {
        class: "text-center h20_value",
        data: function(row, type, set, meta) {
          return row.h20_value;
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
          return row.h22_value;
        }
      },
      {
        class: "text-center h23_value",
        data: function(row, type, set, meta) {
          return row.h23_value;
        }
      },
      ],
      autoWidth: true,
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
   search: function(){
      this.dataTable.search(this.m_form_search).draw();
   },
   showHideColumns: function(id){
    var column = this.dataTable.columns("." +id);
    if(column.visible()[0] == true){
      column.visible(false);
    }else{
      column.visible(true);
    }
   },
   onHideShowButton: function(){
    $(this.$refs.hideShow).modal("show");
   },
    initHideShow: function(){
      $(".rule-column").each(function(){
        var that = $(this).attr("data-id");
        let statusDataTable = $('#status-datatable').DataTable();
        var column = statusDataTable.columns("." +that);
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
    $(".status").addClass(" m-menu__item--active");
    $("#m_aside_left").removeClass("m-aside-left--on");
    $("body").removeClass("m-aside-left--on");
    $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
   },
   dateFilterInitialize: function() {
      let table_data = this.dataTable;
      let time_list = this.time_list;
      let battery_voltages = this.battery_voltages;
      let panel_voltages = this.panel_voltages;
      let status_date_list = this.status_date_list;
      $('#m_sms_datepicker_from, #m_sms_datepicker_to').change(function(){
       let from_date = $("#m_sms_datepicker_from").val(),
        to_date = $("#m_sms_datepicker_to").val();
          let new_url = "/battery/data/" + from_date + "/" + to_date
          table_data.ajax.url(new_url).load();

          $.get('/daily_battery/data/' + from_date + "/" + to_date, function( data ) {
          let history = data.voltages_history
          time_list = history.time_list
          battery_voltages = history.battery_voltages;
          status_date_list = history.date;
          panel_voltages = history.panel_voltages;

          mApp.block("#voltages_graph_content", {
            overlayColor: "#000000",
            type: "loader",
            state: "success",
            message: "Loading..."
          })
          Highcharts.setOptions({
            lang: {
              thousandsSep: ','
            }
          });
          Highcharts.chart('voltages_graph', {
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
              valueSuffix: ' mV'
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
              name: 'Voltage',
              data: battery_voltages
            }]
          });
          Highcharts.chart('voltages_graph_other', {
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
              valueSuffix: ' mV',
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
          mApp.unblock("#voltages_graph_content")
        });
      });
    },
    battery_voltages_graph: function(){

      mApp.block("#voltages_graph_content", {
        overlayColor: "#000000",
        type: "loader",
        state: "success",
        message: "Loading..."
      })
      Highcharts.setOptions({
        lang: {
          thousandsSep: ','
        }
      });
      Highcharts.chart('voltages_graph', {
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
          categories: this.time_list,
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
          valueSuffix: ' mV'
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
          name: 'Voltage',
          data: this.battery_voltages
        }]
      });
      Highcharts.chart('voltages_graph_other', {
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
          categories: this.time_list,
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
          valueSuffix: ' mV',
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
          data: this.battery_voltages
        },
        {
          name: 'Panel Voltage',
          data: this.panel_voltages
        }]
      });
    },
    get_voltages_history: function(){
      $( "#m_sms_datepicker_from").datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date(new Date().getTime() - (48 * 60 * 60 * 1000)));
      $( "#m_sms_datepicker_to" ).datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date());

      let from_date = $("#m_sms_datepicker_from").val(),
      to_date = $("#m_sms_datepicker_to").val();

      this.$http.get('/daily_battery/data/' + from_date + "/" + to_date).then(response => {
         let history = response.body.voltages_history
         this.time_list = history.time_list
         this.battery_voltages = history.battery_voltages;
         this.status_date_list = history.date;
         this.panel_voltages = history.panel_voltages;
         this.battery_voltages_graph();
         mApp.unblock("#voltages_graph_content")
      });
    }
  }, // end of methods
   mounted(){
    this.initializeTable();
    this.get_voltages_history();
    this.dateFilterInitialize();
    this.search();
    this.get_session();
    this.initHideShow();
    this.active_menu_link();
    this.battery_voltages_graph();

   }
}
</script>

<style lang="scss">
</style>
