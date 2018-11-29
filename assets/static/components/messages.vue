<template>
  <div id="loading_content">
    <div class="m-content">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" style="padding: 10px;">
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right m--margin-bottom-10">
            <div class="row align-items-center">
              <div class="col-xl-9 order-3 order-xl-1">
                <div class="form-group m-form__group row align-items-center">
                  <div class="col-md-4">
                    <div class="m-input-icon m-input-icon--left">
                      <input type="text" class="form-control m-input m-input--solid" placeholder="Search..." id="m_form_search" v-model="m_form_search" v-on:keyup="search()">
                      <span class="m-input-icon__icon m-input-icon__icon--left">
                        <span>
                          <i class="la la-search"></i>
                        </span>
                      </span>
                    </div>
                  </div>
                  <div class="col-md-8">
                    <div class="row">
                        <div class="col-sm-6">
                             <div class="form-group m-form__group row">
                            <label class="col-lg-2 col-form-label">
                                From:
                            </label>
                            <div class="col-lg-10">
                                <input type="text" class="form-control m-input m-input--solid" id="m_sms_datepicker_from">
                            </div>
                            </div>
                        </div>
                        <div class="col-sm-6">
                             <div class="form-group m-form__group row">
                            <label class="col-lg-1 col-form-label">
                                To:
                            </label>
                            <div class="col-lg-10">
                                <input type="text" class="form-control m-input m-input--solid" id="m_sms_datepicker_to">
                            </div>
                            </div>
                        </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-xl-3 order-1 order-xl-3 m--align-right">
                  <a href="javascript:void(0)" id="sendSms" class="btn btn-primary m-btn m-btn--icon" v-on:click="onSmsButton">
                      <span>
                          <i class="fa fa-plus-square"></i>
                          <span>
                              {{form_labels.add_sms_button}}
                          </span>
                      </span>
                  </a>
                  <div href="javascript:void(0)" class="btn btn-default grey" v-on:click="onSmsHideShowButton">
                    <i class="fa fa-columns"></i>
                  </div>
              </div>
            </div>
          </div>
          <!--end: Search Form -->
          <table id="sms-datatable" class="table table-striped  table-hover table-bordered datatable display nowrap" cellspacing="0" width="100%">
            <thead>
                <tr>
                    <th v-for="(item, index) in headings">{{item.column}}</th>
                </tr>
            </thead>
          </table>
        </div>
      </div>
    </div>
    <div class="modal fade toggle-datatable-columns" ref="hideShow" style="padding: 0px;" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
      <div class="modal-dialog modal-sm" role="document">
          <div class="modal-content" style="padding: 0px;">
              <div class="modal-header">
                  <h5 class="modal-title" id="exampleModalLabel">
                      {{form_labels.hide_show_title}}
                  </h5>
                  <div class="cancel">
                    <a href="#" id="discardModal" data-dismiss="modal" v-on:click="clearForm">X</a>
                  </div>
              </div>
              <div class="modal-body" id="body-sim-dis">
                  <div class="form-group">
                    <div class="column-checkbox" v-for="(item, index) in headings">
                        <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;"><input type="checkbox" class="sms-column" v-bind:data-id="item.id" v-bind:checked = "item.visible" v-on:change="showHideColumns(item.id)" ><span></span> {{item.column}}</label>
                    </div>
                  </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{{form_labels.hide_show_button}}</button>
              </div>
          </div>
      </div>
    </div>
    <div class="modal fade add_sms_to_db" ref="addmodal" style="padding: 0px;" id="m_modal_1" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
        <div class="modal-dialog" role="document">
            <div class="modal-content" style="padding: 0px;">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">
                        {{form_labels.add_title}}
                    </h5>
                    <div class="cancel">
                        <a href="#" id="discardModal" data-dismiss="modal" v-on:click="clearForm">X</a>
                    </div>
                </div>
                <div class="modal-body" id="body-sms-dis">
                    <img src="/images/loading.gif" id="api-wait" class="hide_me">
                    <div class="m-form m-form--fit m-form--label-align-left">
                        <input type="hidden" id="user_id" v-model="user_id">
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.sim}}
                            </label>
                            <div class="col-9">
                                <select class="form-control m-input" id="toNumber" v-model="toNumber" >
                                  <option v-bind:value="sim.number" v-for="sim in sims_list">{{sim.number}} {{sim.name}} </option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.message}}
                            </label>
                            <div class="col-9" id="input_container">
                              <select class="js-example-basic-single form-control m-input " id="smsMessage_text"  style="width: 95%;" multiple="multiple" data-tags="true" >
                                <optgroup label="For Dovado Router">
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
                              </optgroup>
                              <optgroup label="For Teltonika Router">
                                <option value="Reboot">Reboot</option>
                                <option value="Cellstatus">Cellstatus</option>
                              </optgroup>
                              </select>
                              &nbsp;
                              <span class="fa fa-info" tabindex="0" data-html="true" data-toggle="popover" data-trigger="focus"
   title="Commands help." style="cursor: pointer"
   data-content="<div>
    <ul>
        <li><b>Disconnect:</b> Shut down modem connection.</li>
        <li><b>Connect:</b> Connect modem connection</li>
        <li><b>Restart / Reboot:</b> Restarts the router</li>
        <li><b>Reconnect:</b> Reset connection and connect</li>
        <li><b>Status / Cellstatus:</b> Reports current connection status of the router.</li>
        <li><b>Upgrade:</b> Upgrade to latest available firmware.</li>
        <li><b>VPN on and VPN off:</b> Turn on or off VPN access in manual mode.</li>
        <li><b>WLAN on and WLAN off:</b> Turn on or off WiFi. For 2.4 GHz use WLAN24 and WLAN5 for 5 GHz.</li>
        <li><b>Internet on and Internet off:</b> Turn on or off LAN access to Internet.</li>
    </ul>
  </div>"></span>
                            </div>
                        </div>
                    </div>
                    <!--end::Form-->
                </div>
                <div class="modal-footer" style="padding: 11px;">
                    <button id="send-sms-nexmo" type="button" class="btn btn-default" data-dismiss="modal" v-on:click="sendSMS">
                        {{form_labels.submit_button}}
                    </button>
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
  name: 'messages',
  data: function(){
    return{
      dataTable: null,
      table_records: "",
      m_form_search: "",
      show_loading: false,
      sims_list: "",
      headings: [
        {column: "Send at", visible: "checked", id: "inserted_at"},
        {column: "From", visible: "checked", id: "from"},
        {column: "From: Name", visible: "checked", id: "from_name"},
        {column: "To", visible: "checked", id: "to"},
        {column: "To: Name", visible: "checked", id: "to_name"},
        {column: "Message ID", id: "message_id"},
        {column: "Type", visible: "checked", id: "type"},
        {column: "Text Message", visible: "checked", id: "text_message"},
        {column: "Delivered at", visible: "checked", id: "delivered_at"},
        {column: "Status", visible: "checked", id: "status"},
      ],
      form_labels: {
        sim: "SIM",
        message: "Message",
        submit_button: "Send",
        add_title: "Send SMS",
        hide_show_title: "Show/Hide Columns",
        add_sms_button: "Send SMS",
        hide_show_button: "OK"
      },
      smsMessage: "",
      toNumber: "",
      user_id: "",
      smsMessage_text: "",
    }
  },
  methods: {
    initializeTable: function(){
      $( "#m_sms_datepicker_from").datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date(new Date().getTime() - (48 * 60 * 60 * 1000)));
      $( "#m_sms_datepicker_to" ).datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date());

      let from_date = $("#m_sms_datepicker_from").val(),
      to_date = $("#m_sms_datepicker_to").val();

      let smsDataTable = $('#sms-datatable').DataTable({
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
        url: "/get_all_sms/" + from_date + "/" + to_date,
          dataSrc: function(data) {
            return data.sms_messages;
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
          class: "text-center inserted_at",
          data: function(row, type, set, meta) {
            return moment(row.inserted_at).format('DD/MM/YYYY HH:mm:ss');
          },
        },
        {
          class: "from",
          data: function(row, type, set, meta) {
            return row.from;
          }
        },
        {
          class: "from_name",
          data: function(row, type, set, meta) {
            return row.from_name;
          }
        },
        {
          class: "to",
          data: function(row, type, set, meta) {
            return row.to;
          }
        },
        {
          class: "to_name",
          data: function(row, type, set, meta) {
            return row.to_name;
          }
        },
        {
          class: "message_id",
          visible: false,
          data: function(row, type, set, meta) {
            return row.message_id;
          }
        },
        {
          class: "type",
          data: function(row, type, set, meta) {
            if(row.type == "MO"){
              return "<span class='m-badge m-badge--metal m-badge--wide'>Incoming</span>";
            }else{
              return "<span class='m-badge m-badge--success m-badge--wide'>Outgoing</span>";
            }
          }
        },
        {
          class: "text_message",
          data: function(row, type, set, meta) {
            return row.text;
          }
        },
        {
          class: "text-left delivered_at",
          data: function(row, type, set, meta) {
            let delivery_datetime = row.delivery_datetime
            if(delivery_datetime != ""){
              return "" + moment(row.delivery_datetime).format('DD/MM/YYYY HH:mm:ss') +"";
            }else{
              return ""
            }
          }
        },
        {
          class: "text-center status",
          data: function(row, type, set, meta) {
            status = row.status;
            if(status == "Received"){
              return '<span title="Received"><svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 18 18" width="18" height="18"><path fill="#4FC3F7" d="M17.394 5.035l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-.427-.388a.381.381 0 0 0-.578.038l-.451.576a.497.497 0 0 0 .043.645l1.575 1.51a.38.38 0 0 0 .577-.039l7.483-9.602a.436.436 0 0 0-.076-.609zm-4.892 0l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-2.614-2.556a.435.435 0 0 0-.614.007l-.505.516a.435.435 0 0 0 .007.614l3.887 3.8a.38.38 0 0 0 .577-.039l7.483-9.602a.435.435 0 0 0-.075-.609z"></path></svg></span>'
            }else if(status == "delivered"){
              return '<span title="Delivered"><svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 18 18" width="18" height="18"><path fill="#4FC3F7" d="M17.394 5.035l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-.427-.388a.381.381 0 0 0-.578.038l-.451.576a.497.497 0 0 0 .043.645l1.575 1.51a.38.38 0 0 0 .577-.039l7.483-9.602a.436.436 0 0 0-.076-.609zm-4.892 0l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-2.614-2.556a.435.435 0 0 0-.614.007l-.505.516a.435.435 0 0 0 .007.614l3.887 3.8a.38.38 0 0 0 .577-.039l7.483-9.602a.435.435 0 0 0-.075-.609z"></path></svg></span>'
            }else if(status == "Failed"){
              return "<span title='Failed' style='color:#b51010;font-size:16px;font-weight:bold'>&#10005;</span>"
            }else if(status == "accepted"){
              return '<span title="Not Delivered"><svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 15" width="18" height="18"><path fill="#92A58C" d="M10.91 3.316l-.478-.372a.365.365 0 0 0-.51.063L4.566 9.879a.32.32 0 0 1-.484.033L1.891 7.769a.366.366 0 0 0-.515.006l-.423.433a.364.364 0 0 0 .006.514l3.258 3.185c.143.14.361.125.484-.033l6.272-8.048a.365.365 0 0 0-.063-.51z"></path></svg></span>'
            }else{
              return "<span title='Pending'><i class='fa fa-clock-o' style='color:gray;font-size:16px'></i></span>"
            }
          },
        }
        ],
        autoWidth: true,
        info: false,
        bPaginate: false,
        lengthChange: false,
        scrollX: true,
        colReorder: true,
        sort: true,
        order: [[ 0, "desc" ]],
      });
      this.dataTable = smsDataTable;
    },
    search: function(){
      this.dataTable.search(this.m_form_search).draw();
    },
    showHideColumns: function(id){
      let column = this.dataTable.columns("." +id);
      if(column.visible()[0] == true){
        column.visible(false);
      }else{
        column.visible(true);
      }
      this.dataTable.draw();
    },
    sendSMS: function(){
      this.smsMessage_text = document.getElementById("smsMessage_text").value;
      this.show_loading = true;
      this.$http.post('/send_sms', {
        sms_message: this.smsMessage_text,
        sim_number:  this.toNumber,
        user_id: this.user_id
      }).then(function (response) {
        if (response.body.status != 0) {
          app.$notify({group: 'notify', title: response.body.error_text, type: 'error'});
        }else{
          app.$notify({group: 'notify', title: 'Your message has been sent.'});
        }
        $(this.$refs.addmodal).modal("hide");
        this.dataTable.ajax.reload();
        this.show_loading = false;
        this.clearForm();
      }).catch(function (error) {
        app.$notify({group: 'notify', title: 'Something went wrong.', type: 'error'});
        this.show_loading = false;
        this.clearForm();
      });
    },
    clearForm: function() {
      this.smsMessage = "";
      this.toNumber = "";
      this.smsMessage_text = "";
    },
    dateFilterInitialize: function() {
      let table_data = this.dataTable;
      $('#m_sms_datepicker_from, #m_sms_datepicker_to').change(function(){
        let from_date = $("#m_sms_datepicker_from").val(),
          to_date = $("#m_sms_datepicker_to").val();
          let new_url = "/get_all_sms/" + from_date + "/" + to_date
          table_data.ajax.url(new_url).load();
      });
    },
    onSendSMSFocus: function() {
      $(this.$refs.addmodal).on('shown.bs.modal', function () {
        $('#smsMessage').focus();
      });
    },
    onSmsButton: function() {
      $(this.$refs.addmodal).modal('show');
    },
    onSmsHideShowButton: function() {
      $(this.$refs.hideShow).modal("show");
    },
    init_select: function(){
      $('.js-example-basic-single').select2({
        closeOnSelect: true,
        maximumSelectionLength: 1,
        placeholder: "Choose or type",
      });
    },
    get_session: function(){
      this.$http.get('/get_porfile').then(response => {
        this.user_id = response.body.id;
      });
    },
    get_sims: function(){
      this.$http.get('/sims/data/json').then(response => {
        this.sims_list = response.body.logs;
      });
    },
    active_menu_link: function(){
      $("li").removeClass(" m-menu__item--active");
      $(".messages").addClass(" m-menu__item--active");
      $("#m_aside_left").removeClass("m-aside-left--on");
      $("body").removeClass("m-aside-left--on");
      $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
    }
  }, // end of methods
   mounted(){
    this.initializeTable();
    this.init_select();
    this.dateFilterInitialize();
    this.onSendSMSFocus();
    this.get_session();
    this.get_sims();
    this.search();
    this.active_menu_link();
    $('[data-toggle="popover"]').popover({ trigger: "hover" });
   }
}
</script>

<style lang="scss">
</style>
