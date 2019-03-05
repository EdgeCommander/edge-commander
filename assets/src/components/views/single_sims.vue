<template>
  <div id="single_sims">
    <div class="m-content">
        <div class="row">
          <div class="col-sm-12 ">
                <div class="m-portlet m-portlet--mobile" style="margin-bottom: 5px">
                  <div class="row battery_details" style="padding:10px">
                    <div class="col-lg-5 col-md-4" style="padding-top: 10px">
                      <span>Name:</span> {{sim_name}}
                    </div>
                   <div class="col-lg-3 col-md-4" style="padding-top: 10px">
                     <span>Number:</span> {{toNumber}}
                   </div>
                   <div class="col-lg-2 col-md-4" style="padding-top: 10px">
                     <span>Daily SMS Count:</span> <span id="dailySMSCount"></span>
                   </div>
                    <div class="col-lg-2 btn_back">
                      <router-link v-bind:to="'/sims'" class="btn btn-default">Back to Sims</router-link>
                    </div>
                  </div>
                </div>
            </div>
            <div class="col-sm-5 sim_graph_panel">
                <div class="m-portlet m-portlet--mobile">
                    <div class="m-portlet__body">
                        <div style="width:100%;" id="iam_canvas">
                            <canvas id="canvas"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-7 sim_log_datatable" >
                <div class="m-portlet m-portlet--mobile" id="sm_datatable_inner">
                    <div class="m-portlet__body">
                        <table id="sim-datatable" class="table table-striped  table-hover table-bordered  nowrap" cellspacing="0" width="100%">
                            <thead>
                                <tr>
                                    <th v-for="(item, index) in SimHeadings">{{item.column}}</th>
                                </tr>
                            </thead>
                        </table>
                    </div>
                </div>
            </div>
            <!--begin::Modal-->
            <div class="modal fade" id="m_modal_4" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <img src="../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                        <div class="modal-body">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="clear_chartsjs">
                      <span aria-hidden="true">
                      &times;
                      </span>
                            </button>
                            <div style="width:100%;" id="iam_canvas">
                                <canvas id="canvas"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!--end::Modal-->
        </div>
        <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
            <div class="m-portlet__body" style="padding: 10px;">
                <div class="m-portlet__body  m-portlet__body--no-padding">
                    <div style="margin: 10px 0">
                        <h3 class="pull-left">
                          SMS History <span style="font-size:12px">(Last 10 SMS) </span>
                        </h3>
                        <div class="pull-right">
                            <button type="button" class="btn btn-primary m-btn m-btn--icon" data-toggle="modal" data-target="#smsModal">
                              <span><i class="fa fa fa-paper-plane-o"></i><span>Send SMS</span></span>
                            </button>
                        </div>
                        <div class="clearfix"></div>
                    </div>
                    <table id="sms-datatable" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
                        <thead>
                            <tr>
                                <th v-for="(item, index) in SmsHeadings">{{item.column}}</th>
                            </tr>
                        </thead>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <!-- begin:: Modal -->
    <div class="modal fade" id="smsModal" ref="addmodal" style="padding: 0px;" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">
                        {{form_labels.send_title}} {{toNumber}}
                    </h5>
                    <div class="cancel">
                      <a href="#" id="discardModal" data-dismiss="modal" v-on:click="clearForm">X</a>
                    </div>
                </div>
                <div class="modal-body" id="body-sms-dis">
                    <img src="/images/loading.gif" id="api-wait" v-if="show_loading">
                    <div class="m-form m-form--fit m-form--label-align-left">
                      <input type="hidden" id="toNumber" v-model="toNumber">
                      <div class="form-group m-form__group row">
                        <label class="col-3 col-form-label">
                            {{form_labels.message}}
                        </label>
                        <div class="col-9" id="input_container">
                          <input type="hidden" id="user_id" v-model="user_id">
                          <select class="form-control m-input " id="smsMessage_text"  style="width: 95%;" multiple="multiple" data-tags="true" >
                                <option value="Disconnect">Disconnect</option>
                                <option value="Connect">Connect</option>
                                <option value="Restart">Restart</option>
                                <option value="Reconnect">Reconnect</option>
                                <option value="Status">Status</option>
                                <option value="VPN on">VPN on</option>
                                <option value="VPN on">VPN off</option>
                                <option value="Upgrade">Upgrade</option>
                                <option value="Internet on">Internet on</option>
                                <option value="Internet off">Internet off</option>
                                <option value="WLAN on">WLAN on</option>
                                <option value="WLAN off">WLAN off</option>
                                <option value="On">On</option>
                                <option value="Off">Off</option>
                                <option value="#01#">#01#</option>
                                <option value="#02#">#02#</option>
                                <option value="Reboot">Reboot</option>
                                <option value="Cellstatus">Cellstatus</option>
                              </select> &nbsp;
                              <span class="fa fa-info" tabindex="0" data-html="true" data-toggle="popover" data-trigger="focus"
   title="Commands help." style="cursor: pointer"
   data-content="<div>
    <strong>For Dovado Router</strong>
    <ul>
        <li><b>Disconnect:</b> Shut down modem connection.</li>
        <li><b>Connect:</b> Connect modem connection</li>
        <li><b>Restart:</b> Restarts the router</li>
        <li><b>Reconnect:</b> Reset connection and connect</li>
        <li><b>Status:</b> Reports current connection status of the router.</li>
        <li><b>Upgrade:</b> Upgrade to latest available firmware.</li>
        <li><b>VPN on and VPN off:</b> Turn on or off VPN access in manual mode.</li>
        <li><b>WLAN on and WLAN off:</b> Turn on or off WiFi. For 2.4 GHz use WLAN24 and WLAN5 for 5 GHz.</li>
        <li><b>Internet on and Internet off:</b> Turn on or off LAN access to Internet.</li>
    </ul>
    <strong>For Teltonika Router</strong>
    <ul>
        <li><b>Reboot:</b> Restarts the router</li>
        <li><b>Cellstatus:</b> Reports current connection status of the router.</li>
    </ul>
  </div>"></span>
                        </div>
                      </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal" v-on:click="sendSMS">{{form_labels.send_button}}</button>
                </div>
            </div>
        </div>
    </div>
    <!-- end:: Modal -->
  </div>
</template>

<script>
import * as jquery from 'jquery';
import datepicker from 'jquery-ui'
import Chart from 'chart.js'

import Vue from 'vue'
import moment from "moment";
import single_sims from './single_sims.vue';
import App from '../../App.vue'
const app = new Vue(App)

export default {
  name: 'single_sims',
  data: function(){
    return{
      dataTable: null,
      m_form_search: "",
      show_loading: false,
      sim_name: "",
      SimHeadings: [
      {column: "DateTime"},
      {column: "MB Allowance"},
      {column: "MB Used (Today)"},
      {column: "% Used"},
      ],
      SmsHeadings: [
        {column: "Send at"},
        {column: "Type"},
        {column: "Status"},
        {column: "Message"},
        {column: "Delivered at"}
      ],
      form_labels: {
        message: "Message",
        send_title: "SMS To",
        send_button: "Send"
      },
      smsMessage: "",
      toNumber: "",
      user_id: "",
      smsMessage_text: ""
    }
  },
  methods: {
    initializeSimsTable: function(){
      let simsDataTable = $('#sim-datatable').DataTable({
        ajax: {
          url: "/sims/data/" + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "",
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
            class: "text-left",
            data: function(row, type, set, meta) {
              return "" + moment(row.date_of_use).format('MMMM Do YYYY, H:mm:ss') +"";
            }
          },
          {
            class: "text-center",
            data: function(row, type, set, meta) {
              let allowance_value = row.allowance_in_number
              if (allowance_value == -1.0) {
                allowance_value = "Unlimited";
              }
              return allowance_value;
            }
          },
          {
            class: "text-center",
            data: function(row, type, set, meta) {
              let allowance_value = row.allowance_in_number
              let current_in_number = row.current_in_number
              if (allowance_value == -1.0) {
                current_in_number = "-";
              }
              return current_in_number;
            }
          },
          {
            class: "text-center",
            data: function(row, type, set, meta) {
              let allowance_value = row.allowance_in_number
              let percentage_used = row.percentage_used
              if (allowance_value == -1.0) {
                percentage_used = "-";
              }
              return percentage_used;
            }
          }
        ],
        autoWidth: true,
        info: false,
        bPaginate: false,
        lengthChange: false,
        order: [[ 3, "desc" ]],
        scrollX: true
      });
    },
    initializeSmsTable: function(){
      let simsDataTable = $('#sms-datatable').DataTable({
        ajax: {
          url: "/sims/sms/" + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "",
          dataSrc: function(data) {
            return data.single_sim_sms;
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
            class: "text-center",
            data: function(row, type, set, meta) {
              return "" + moment(row.inserted_at).format('DD/MM/YYYY HH:mm:ss') +"";
            }
          },
          {
            class: "text-center",
            data: function(row, type, set, meta) {
              if(row.type == "MO"){
                return "<span class='m-badge m-badge--metal m-badge--wide'>Incoming</span>";
              }else{
                return "<span class='m-badge m-badge--success m-badge--wide'>Outgoing</span>";
              }
            }
          },
          {
            class: "text-center",
            data: function(row, type, set, meta) {
              let status_value = row.status
              if(status_value == "accepted"){
                  status_value = "Not Delivered"
              }
              return "<span style='text-transform:capitalize'>"+status_value+"</sapn>"
            }
          },
          {
            class: "text-left",
            data: function(row, type, set, meta) {
              let str = row.text;
              return str.split("\n").join("<br/>");
            }
          },
          {
            class: "text-center",
            data: function(row, type, set, meta) {
              let delivery_datetime = row.delivery_datetime
              if(delivery_datetime != ""){
                return "" + moment(row.delivery_datetime).format('DD/MM/YYYY HH:mm:ss') +"";
              }else{
                return ""
              }
            }
          }
        ],
        autoWidth: false,
        info: false,
        bPaginate: false,
        lengthChange: false,
        ordering: false,
        scrollX: true
      });
      this.dataTable = simsDataTable;
    },
    setSimNumber: function(){
      let num = window.location.href.substring(window.location.href.lastIndexOf('/') + 1);
      this.toNumber = num;
      if(num.indexOf('+') == -1){
        this.toNumber = "+"+num;
      }
    },
    sendSMS: function() {
      this.show_loading = true;
      this.smsMessage_text = $(".custom-combobox-input").val();
      this.$http.post('/send_sms', {
        sms_message: this.smsMessage_text,
        sim_number:  this.toNumber,
        user_id: this.user_id
      }).then(function (response) {
        if (response.body.status != 0) {
          Vue.notify({group: 'notify', title: response.body.error_text, type: 'error'});
        }else{
          Vue.notify({group: 'notify', title: 'Your message has been sent.'});
        }
        $(this.$refs.addmodal).modal("hide");
        this.dataTable.ajax.reload();
        this.show_loading = false;
        this.clearForm();
      }).catch(function (error) {
        Vue.notify({group: 'notify', title: 'Something went wrong.',  type: 'error'});
        this.show_loading = false;
        this.clearForm();
      });
    },
    clearForm: function() {
      this.smsMessage = "";
      this.smsMessage_text = "";
      $(".custom-combobox-input").val("");
      $('.close').on('click', function() {$(this).parent().alert('close'); });
      setTimeout(function() {$(".alert-danger").alert('close')}, 6000);
    },
    onSendSMSFocus: function() {
      $('#smsModal').on('shown.bs.modal', function () {
        $('#smsMessage').focus();
      });
    },
    startMORRISChartJS: function () {
      let settingsForMorris;
      let id = window.location.href.substring(window.location.href.lastIndexOf('/') + 1);
      settingsForMorris = {
        cache: false,
        data: {sim_number: id},
        dataType: 'json',
        success: this.onMorrisSuccess,
        contentType: "application/x-www-form-urlencoded",
        type: "GET",
        url: "/chartjs/data/" + id
      };
      $.ajax(settingsForMorris);
    },
    addZero: function(i) {
      if (i < 10) {
        i = "0" + i;
      }
      return i;
    },
    getActualFullDate: function() {
      let d = new Date();
      let day = this.addZero(d.getDate());
      let month = this.addZero(d.getMonth()+1);
      let year = this.addZero(d.getFullYear());
      let h = this.addZero(d.getHours());
      let m = this.addZero(d.getMinutes());
      let s = this.addZero(d.getSeconds());
      return year + "-" + month + "-" + day;
    },
    dateExist: function(array, obj) {
      let i = array.length;
      while (i--) {
        if (array[i]["datetime"] == obj) {
          return true;
        }
      }
      return false;
    },
    getUsageValue: function(array, obj) {
      let i = array.length;
      while (i--) {
        if (array[i]["datetime"] == obj) {
          return array[i]["percentage_used"];
        }
      }
      return 0;
    },
    onMorrisSuccess: function (result, status, jqXHR) {

      let labelsZchartjs = [], dataZChartsJS = [];
      let todayDate = single_sims.methods.getActualFullDate()

      let dateExist =  single_sims.methods.dateExist(result.chartjs_data, todayDate);
      if(dateExist == false){
        let val = single_sims.methods.getUsageValue(result.chartjs_data, todayDate)
        let data = {percentage_used: val, datetime: todayDate}
        result.chartjs_data.push(data)
      }

      $.each(result.chartjs_data, function( index, element ) {
        labelsZchartjs.push(element.datetime);
        dataZChartsJS.push(element.percentage_used);
      });

      let chartColors = {
        red: 'rgb(255, 99, 132)',
        orange: 'rgb(255, 159, 64)',
        yellow: 'rgb(255, 205, 86)',
        green: 'rgb(75, 192, 192)',
        blue: 'rgb(54, 162, 235)',
        purple: 'rgb(153, 102, 255)',
        grey: 'rgb(231,233,237)'
      };

      let randomScalingFactor = function() {
        return (Math.random() > 0.5 ? 1.0 : -1.0) * Math.round(Math.random() * 100);
      }
      let config = {
        type: 'line',
        data: {
          labels: labelsZchartjs,
          datasets: [{
            label: "",
            fill: false,
            backgroundColor: chartColors.blue,
            borderColor: chartColors.blue,
            data: dataZChartsJS,
          }]
        },
        options: {
          legend: {
            labels: {
              boxWidth: 0,
              fontStyle: "bold",
              fontSize: 18
            }
          },
          responsive: true,
          tooltips: {
            bodyFontStyle: "bold",
            mode: 'label',
          },
          hover: {
            mode: 'nearest',
            intersect: true
          },
          scales: {
            xAxes: [{
              ticks: {
                  autoSkip : true,
                  callback: function(value, index, values) {
                    return new moment(value).format('YYYY-MM-DD');
                  }
              },
              display: true,
              fontStyle: "bold",
              scaleLabel: {
                fontStyle: "bold",
                display: false,
                labelString: 'Date & Time'
              }
            }],
            yAxes: [{
              ticks: {
                  min: 0,
                  max: 100,
                  stepSize: 20
              },
              display: true,
              fontStyle: "bold",
              scaleLabel: {
                fontStyle: "bold",
                display: true,
                labelString: '% Allowance Used'
              }
            }]
          }
        }
      };
      $("#api-wait").addClass("hide_me");
      let ctx = document.getElementById("canvas").getContext("2d");
      let ctx_div = document.getElementById("canvas");
      ctx_div.height = 200;
      window.myLine = new Chart(ctx, config);
      this.resizeTableDiv();
    },
    get_session: function(){
      this.$http.get('/get_porfile').then(response => {
        this.user_id = response.body.id;
      });
    },
    get_sim_name: function(){
      this.$http.get('/sims/name/'+ window.location.href.substring(window.location.href.lastIndexOf('/') + 1)).then(response => {
        this.sim_name = response.body.sim_name;
      });
    },
    resizeTableDiv: function() {
      let window_width = $(window).width();
      let objDiv = document.getElementById("iam_canvas");
      let convasHeight = objDiv.scrollHeight + 20;
      $("#sm_datatable_inner").css("min-height", convasHeight).css("max-height", convasHeight).css("overflow-y", "auto");
    },
    resizeSMSTable: function(){
      $('#double-scroll').doubleScroll();
      let table_width = $("#sms-datatable").width();
      $(".doubleScroll-scroll").width(table_width);
    },
    count_daily_sms: function(){
      $.get("/daily_sms_count/" + window.location.href.substring(window.location.href.lastIndexOf('/') + 1), function(data) {
        $("#dailySMSCount").html(data.result)
      });
    },
    select_menu_link: function(){
     $("li").removeClass(" m-menu__item--active");
     $(".sims").addClass(" m-menu__item--active");
    },
    messages_input_init: function(){
      $.widget( "custom.combobox", {
        _create: function() {
          this.wrapper = $( "<span>" )
            .addClass( "custom-combobox" )
            .insertAfter( this.element );
          this.element.hide();
          this._createAutocomplete();
          this._createShowAllButton();
        },
        _createAutocomplete: function() {
          var selected = this.element.children( ":selected" ),
            value = selected.val() ? selected.text() : "";
          this.input = $( "<input>" )
            .appendTo( this.wrapper )
            .val( value )
            .attr( "title", "" )
            .addClass( "custom-combobox-input ui-widget ui-widget-content ui-state-default ui-corner-left" )
            .autocomplete({
              delay: 0,
              minLength: 0,
              source: $.proxy( this, "_source" )
            })
            .tooltip({
              classes: {
                "ui-tooltip": "ui-state-highlight"
              }
            });
          this._on( this.input, {
            autocompleteselect: function( event, ui ) {
              ui.item.option.selected = true;
              this._trigger( "select", event, {
                item: ui.item.option
              });
            },
            autocompletechange: "_removeIfInvalid"
          });
        },
        _createShowAllButton: function() {
          var input = this.input,
            wasOpen = false;
          $( "<a>" )
            .attr( "tabIndex", -1 )
            .attr( "title", "Show All Items" )
            .tooltip()
            .appendTo( this.wrapper )
            .button({
              icons: {
                primary: "ui-icon-triangle-1-s"
              },
              text: false
            })
            .removeClass( "ui-corner-all" )
            .addClass( "custom-combobox-toggle ui-corner-right" )
            .on( "mousedown", function() {
              wasOpen = input.autocomplete( "widget" ).is( ":visible" );
            })
            .on( "click", function() {
              input.trigger( "focus" );
              if ( wasOpen ) {
                return;
              }
              input.autocomplete( "search", "" );
            });
        },
        _source: function( request, response ) {
          var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
          var aa = response( this.element.children( "option" ).map(function() {
            var text = $( this ).text();
            if ( this.value && ( !request.term || matcher.test(text) ) )
              return {
                label: text,
                value: text,
                option: this,
              };
          }) );
        },
        _removeIfInvalid: function( event, ui ) {
          if ( ui.item ) {
            return;
          }
          var value = this.input.val(),
            valueLowerCase = value.toLowerCase(),
            valid = false;
         this.selected = valid = true;
         console.log(this.element)
          this.element.val( value );
          this._delay(function() {
            this.input.tooltip( "close" ).attr( "title", "" );
          }, 2500 );
          this.input.autocomplete( "instance" ).term = "";
        },
        _destroy: function() {
          this.wrapper.remove();
          this.element.show();
        }
      });
      $( "#smsMessage_text" ).combobox();
      $('.ui-button').tooltip('disable');
    }
  }, // end of methods
  mounted(){
    this.initializeSimsTable();
    this.initializeSmsTable();
    this.onSendSMSFocus();
    this.startMORRISChartJS();
    this.count_daily_sms();
    this.get_session();
    this.get_sim_name();
    this.setSimNumber();
    this.resizeTableDiv();
    this.messages_input_init();
    window.addEventListener('resize', this.startMORRISChartJS);
    window.addEventListener('resize', this.resizeSMSTable);
    this.select_menu_link();
    jquery('[data-toggle="popover"]').popover({ trigger: "hover" });
  }
}

</script>
<style lang="scss">
</style>
