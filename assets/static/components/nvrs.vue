<template>
  <div>
  <div class="m-content">
    <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
      <div class="m-portlet__body" style="padding: 10px;">
        <!--begin: Search Form -->
        <div class="m-form m-form--label-align-right m--margin-bottom-10">
          <div class="row align-items-center">
            <div class="col-md-8 order-2 order-md-1">
              <div class="form-group m-form__group row align-items-center">
                <div class="col-md-5">
                  <div class="m-input-icon m-input-icon--left">
                    <input type="text" class="form-control m-input m-input--solid" placeholder="Search..." id="m_form_search" v-model="m_form_search" v-on:keyup="search()">
                    <span class="m-input-icon__icon m-input-icon__icon--left">
                      <span>
                        <i class="la la-search"></i>
                      </span>
                    </span>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-md-4 order-1 order-md-2 m--align-right">
                <a href="javascript:void(0)" class="btn btn-primary m-btn m-btn--icon" v-on:click="onNVRButton">
                    <span>
                        <i class="fa fa-plus-square"></i>
                        <span>
                           {{form_labels.add_nvr_button}}
                        </span>
                    </span>
                </a>
                <div href="javascript:void(0)" class="btn btn-default grey" v-on:click="onNVRHideShowButton">
                  <i class="fa fa-columns"></i>
                </div>
            </div>
          </div>
        </div>
        <!--end: Search Form -->
          <table id="nvr-datatable" class="table table-striped  table-hover table-bordered datatable display nowrap" cellspacing="0" width="100%">
              <thead>
                  <tr>
                      <th v-for="(item, index) in headings">{{item.column}}</th>
                  </tr>
              </thead>
          </table>
      </div>
    </div>
  </div>
  <!-- begin:: modal -->
  <div class="modal fade toggle-datatable-columns" ref="hideShow" style="padding: 0px;"  tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
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
                      <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;"><input type="checkbox" class="nvr-column" v-bind:data-id="item.id" v-on:change="showHideColumns(item.id)"><span></span> {{item.column}}</label>
                  </div>
                </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-default" data-dismiss="modal">{{form_labels.hide_show_button}}</button>
            </div>
        </div>
    </div>
  </div>
  <div class="modal fade" id="edit_nvr_to_db" ref="editmodal" style="padding: 0px;" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog" role="document">
        <div class="modal-content" style="padding: 0px;">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">
                    {{form_labels.edit_title}}
                </h5>
                <div class="cancel">
                  <a href="#" id="discardEditModal" data-dismiss="modal" v-on:click="editClearFrom">X</a>
                </div>
            </div>
            <div class="modal-body" id="body-nvr-edit-dis">
                <img src="/images/loading.gif" id="api-wait" v-if="show_loading">
                 <div id="nvrEditErrorDetails" v-if="show_edit_errors">
                    <div class="form-group m-form__group m--margin-top-10">
                        <div class="alert m-alert m-alert--default" role="alert">
                             <ul style="margin:0px">
                               <li v-for="message in show_edit_messages">{{message}}</li>
                            </ul>
                        </div>
                    </div>
                 </div>

                <div class="m-form m-form--fit m-form--label-align-left">
                    <input type="hidden" id="user_id"  v-model="user_id">
                    <input type="hidden" id="edit_nvr_id" >
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.name}}
                          </label>
                          <div class="col-9">
                             <input type="text" class="form-control m-input m-input--solid" id="edit_nvr_name"  aria-describedby="emailHelp" placeholder="Galway route." >
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.ip}}
                          </label>
                          <div class="col-9">
                             <input type="text" class="form-control m-input m-input--solid" id="edit_nvr_ip" placeholder="https://youripmaybe">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.username}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="edit_nvr_username" placeholder="i.e admin">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.password}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="edit_nvr_password"placeholder="Super Secret">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.http_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="edit_http_nvr_port" placeholder="i.e 80">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.rtsp_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="edit_rtsp_nvr_port"placeholder="i.e 880">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.sdk_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="edit_sdk_nvr_port"placeholder="i.e 840">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.vh_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="edit_vh_nvr_port" placeholder="i.e 890">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                          </label>
                          <div class="col-9">
                              <label class="m-checkbox">
                                <input type="checkbox" id="edit_nvr_is_monitoring">
                                  {{form_labels.status}}
                                <span></span>
                            </label>
                          </div>
                      </div>
                 </div>
                <!--end::Form-->
            </div>
            <div class="modal-footer">
                <button id="" type="button" class="btn btn-default" v-on:click="updateNVRdo">
                    {{form_labels.submit_button}}
                </button>
            </div>
        </div>
    </div>
  </div>
  <div class="modal fade add_nvr_to_db" ref="addmodal" style="padding: 0px;" id="m_modal_1" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
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
            <div class="modal-body" id="body-nvr-dis">
                <img src="/images/loading.gif" id="api-wait" v-if="show_loading">
                <div id="nvrErrorDetails" v-if="show_add_errors">
                    <div class="form-group m-form__group m--margin-top-10">
                        <div class="alert m-alert m-alert--default" role="alert">
                            <ul style="margin:0px">
                               <li v-for="message in show_add_messages">{{message}}</li>
                            </ul>
                        </div>
                    </div>
                </div>
                 <div class="m-form m-form--fit m-form--label-align-left">
                    <input type="hidden" id="user_id"  v-model="user_id">
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                               {{form_labels.name}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid"  id="nvr_name" aria-describedby="emailHelp" v-model="nvr_name" placeholder="Galway route.">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.ip}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="nvr_ip" v-model="nvr_ip" placeholder="https://youripmaybe">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.username}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="nvr_username" v-model="nvr_username" placeholder="i.e admin">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.password}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="nvr_password" v-model="nvr_password" placeholder="Super Secret">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.http_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="http_nvr_port" v-model="http_nvr_port" placeholder="i.e 80">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.rtsp_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="rtsp_nvr_port" v-model="rtsp_nvr_port" placeholder="i.e 880">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.sdk_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="sdk_nvr_port" v-model="sdk_nvr_port" placeholder="i.e 840">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.vh_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="vh_nvr_port" v-model="vh_nvr_port" placeholder="i.e 890">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                          </label>
                          <div class="col-9">
                              <label class="m-checkbox">
                                <input type="checkbox" id="nvr_is_monitoring"  v-model="nvr_is_monitoring">
                                {{form_labels.status}}
                                <span></span>
                            </label>
                          </div>
                      </div>
                 </div>
                <!--end::Form-->
            </div>
            <div class="modal-footer">
                <button id="" type="button" class="btn btn-default" v-on:click="saveModal">
                    {{form_labels.submit_button}}
                </button>
            </div>
        </div>
    </div>
  </div>
  <!--end::Modal-->
</div>
</template>

<script>

import Vue from 'vue'
import App from './App.vue'
const app = new Vue(App)

module.exports = {
  name: 'nvrs',
  data: function(){
    return{
    dataTable: null,
    m_form_search: "",
    show_loading: false,
    show_add_errors: false,
    show_edit_errors: false,
    show_edit_messages: "",
    show_add_messages: "",
    headings: [
      {column: "Reboot", visible: "checked", id: "reboot"},
      {column: "Actions", visible: "checked", id: "actions"},
      {column: "Name", visible: "checked", id: "name"},
      {column: "IP", visible: "checked", id: "ip"},
      {column: "HTTP Port", visible: "", id: "http_port"},
      {column: "VH Port", visible: "", id: "vh_port"},
      {column: "SDK Port", visible: "", id: "sdk_port"},
      {column: "RTSP Port", visible: "", id: "rtsp_port"},
      {column: "Username", visible: "", id: "username"},
      {column: "Password", visible: "", id: "password"},
      {column: "Model", visible: "checked", id: "model"},
      {column: "Firmware Version", visible: "checked", id: "firmware_version"},
      {column: "Encoder Released Date", visible: "", id: "encoder_released_date"},
      {column: "Encoder Version", visible: "", id: "encoder_version"},
      {column: "Firmware Released Date", visible: "", id: "firmware_released_date"},
      {column: "Serial Number", visible: "", id: "serial_number"},
      {column: "Mac Address", visible: "", id: "mac_address"},
      {column: "Status", visible: "checked", id: "status"},
      {column: "Monitoring", visible: "", id: "monitoring"},
      {column: "Created At", visible: "", id: "created_at"},
     ],
     form_labels: {
      name: "Name",
      ip: "IP",
      username: "Username",
      password: "Password",
      http_port: "HTTP Port",
      rtsp_port: "RTSP Port",
      sdk_port: "SDK Port",
      vh_port: "VH Port",
      status: "Monitoring",
      add_title: "Add NVR",
      edit_title: "Edit NVR",
      hide_show_title: "Show/Hide Columns",
      add_nvr_button: "Add NVR",
      hide_show_button: "OK",
      submit_button: "Save changes"
     },
     nvr_name: "",
     nvr_ip: "",
     nvr_username: "",
     nvr_password: "",
     http_nvr_port: "",
     sdk_nvr_port: "",
     vh_nvr_port: "",
     rtsp_nvr_port: "",
     user_id: "",
     nvr_is_monitoring: "",
     edit_nvr_id: "",
     edit_nvr_name: "",
     edit_nvr_ip: "",
     edit_nvr_username: "",
     edit_nvr_password: "",
     edit_http_nvr_port: "",
     edit_sdk_nvr_port: "",
     edit_vh_nvr_port: "",
     edit_nvr_is_monitoring: "",
     edit_rtsp_nvr_port: ""
    }
  },
  filters:{
    formatDate: function(value){
      return moment(String(value)).format('DD/MM/YYYY HH:mm:ss')
    },
    get_status_reason: function(value){
      if(value == ''){
        value = " (no reason found.)";
      }
      return value;
    }
  },
  methods: {
    initializeTable: function(){
      let nvrDataTable = $('#nvr-datatable').DataTable({
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
      url: "/nvrs/data",
        dataSrc: function(data) {
          return data.nvrs;
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
        class: "text-center reboot",
        data: function(row, type, set, meta) {
          return '<div class="action_btn"><button class="btn btn-default cursor_to_pointer rebootNVR" data-id="'+ row.id +'" style="font-size:10px;padding: 5px;">Reboot</button></div>';
        }
      },
      {
        class: "text-center actions",
        data: function(row, type, set, meta) {
          return '<div class="action_btn"><div id class="editNVR cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="cursor_to_pointer fa fa-trash delNVR" data-id="'+ row.id +'"></div></div>';
        }
      },
      {
        class: "name",
        data: function(row, type, set, meta) {
          let url = row.ip + ":" + row.port
          return row.name+"&nbsp;&nbsp;&nbsp;<a href='http://"+url+"' target='_blank'><span class='fa fa-external-link'></a>"
        }
      },
      {
        class: "text-left ip",
        data: function(row, type, set, meta) {
          return row.ip;
        }
      },
      {
        visible: false,
        class: "text-center http_port",
        data: function(row, type, set, meta) {
          return row.port;
        }
      },
      {
        visible: false,
        class: "text-center vh_port",
        data: function(row, type, set, meta) {
          return row.vh_port;
        }
      },
      {
        visible: false,
        class: "text-center sdk_port",
        data: function(row, type, set, meta) {
          return row.sdk_port;
        }
      },
      {
        visible: false,
        class: "text-center rtsp_port",
        data: function(row, type, set, meta) {
          return row.rtsp_port;
        }
      },
      {
        visible: false,
        class: "text-center username",
        data: function(row, type, set, meta) {
          return row.username;
        }
      },
      {
        visible: false,
        class: "text-center password",
        data: function(row, type, set, meta) {
          return row.password;
        }
      },
      {
        class: "text-center model",
        data: function(row, type, set, meta) {
          return row.model;
        }
      },
      {
        class: "text-center",
        data: function(row, type, set, meta) {
          return row.firmware_version;
        }
      },
      {
        visible: false,
        class: "text-center encoder_released_date",
        data: function(row, type, set, meta) {
          return row.encoder_released_date;
        }
      },
      {
        visible: false,
        class: "text-center encoder_version",
        data: function(row, type, set, meta) {
          return row.encoder_version;
        }
      },
      {
        visible: false,
        class: "text-center firmware_released_date",
        data: function(row, type, set, meta) {
          return row.firmware_released_date;
        }
      },
      {
        visible: false,
        class: "text-left serial_number",
        data: function(row, type, set, meta) {
          return row.serial_number;
        }
      },
      {
        visible: false,
        class: "text-center mac_address",
        data: function(row, type, set, meta) {
          return row.mac_address;
        }
      },
      {
        class: "text-center status",
        data: function(row, type, set, meta) {
          let reason;
          if(row.nvr_status == false){
            reason  = row.reason;
            if(reason == ''){
              reason = "no reason found.";
            }
            return "<span style='color:#d9534d'>Offline</span> <span>(" + reason + ")</span>";
          }else{
            return "<span style='color:#5cb85c'>Online</span>";
          }
        }
      },
      {
        visible: false,
        class: "text-center monitoring",
        data: function(row, type, set, meta) {
           if (row.is_monitoring) {
            return "Yes";
          } else{
            return "No";
          }
        }
      },
      {
        visible: false,
        class: "text-center created_at",
        data: function(row, type, set, meta) {
          return moment(row.created_at).format('DD/MM/YYYY HH:mm:ss');
        }
      },
      ],
      autoWidth: true,
      info: false,
      bPaginate: false,
      lengthChange: false,
      scrollX: true,
      colReorder: true,
      stateSave:  true
    });
      return this.dataTable = nvrDataTable;
      this.dataTable.search("");
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
   },
   onNVRButton: function() {
    $(this.$refs.addmodal).modal("show");
   },
   onNVRHideShowButton: function() {
    $(this.$refs.hideShow).modal("show");
   },
   saveModal: function() {
      this.show_loading = true;
      this.show_add_errors = true;

      this.$http.post('/nvrs', {
        name: this.nvr_name,
        ip:  this.nvr_ip,
        username: this.nvr_username,
        password: this.nvr_password,
        port: this.http_nvr_port,
        sdk_port: this.sdk_nvr_port,
        vh_port: this.vh_nvr_port,
        rtsp_port: this.rtsp_nvr_port,
        is_monitoring: this.nvr_is_monitoring,
        user_id: this.user_id
      }).then(function (response) {
        app.$notify({group: 'notify', title: 'NVR has been added'});
        this.show_loading = false;
        this.dataTable.ajax.reload();
        this.clearForm();
        $(this.$refs.addmodal).modal("hide");
      }).catch(function (error) {
        this.show_add_messages = error.body.errors;
        this.show_add_errors = true;
        this.show_loading = false;
      });
   },
   clearForm: function() {
      this.nvr_name = "";
      this.nvr_ip = "";
      this.nvr_username = "";
      this.nvr_password = "";
      this.http_nvr_port = "";
      this.sdk_nvr_port = "";
      this.vh_nvr_port = "";
      this.rtsp_nvr_port = "";
      this.nvr_is_monitoring = false;
      this.show_add_errors = false;
      this.show_add_messages = "";
   },
   getUniqueIdentifier: function(nvrDataTable){
    $(document).on("click", ".editNVR", function(){
      let tr = $(this).closest('tr');
      let row = nvrDataTable.row(tr);
      let data = row.data();
      let nvr_id = $(this).data("id");
      module.exports.methods.onNVREditButton(nvr_id, data);
    });
  },
   onNVREditButton: function(nvr_id, data) {
      $("#edit_nvr_id").val(nvr_id);
      $("#edit_nvr_ip").val(data.ip);
      $("#edit_nvr_name").val(data.name);
      $("#edit_nvr_username").val(data.username);
      $("#edit_nvr_password").val(data.password);
      $("#edit_http_nvr_port").val(data.port);
      $("#edit_vh_nvr_port").val(data.vh_port);
      $("#edit_sdk_nvr_port").val(data.sdk_port);
      $("#edit_rtsp_nvr_port").val(data.rtsp_port);
      if (data.is_monitoring == true) {
        $("#edit_nvr_is_monitoring").prop( "checked", true );
      }
      $('#edit_nvr_to_db').modal('show');
    },
    updateNVRdo: function(){
      this.show_loading = true;
      this.show_edit_errors = true;

      let nvrID = $("#edit_nvr_id").val();

      this.$http.patch("/nvrs/" + nvrID, {
        name: $("#edit_nvr_name").val(),
        ip: $("#edit_nvr_ip").val(),
        username: $("#edit_nvr_username").val(),
        password: $("#edit_nvr_password").val(),
        port: $("#edit_http_nvr_port").val(),
        sdk_port: $("#edit_sdk_nvr_port").val(),
        vh_port: $("#edit_vh_nvr_port").val(),
        is_monitoring: $('#edit_nvr_is_monitoring').is(':checked'),
        rtsp_port: $("#edit_rtsp_nvr_port").val(),
        id: nvrID
      }).then(function (response) {
        app.$notify({group: 'notify', title: 'NVR has been updated'});
        this.show_loading = false;
        this.dataTable.ajax.reload();
        this.editClearFrom();
        $(this.$refs.editmodal).modal("hide");
      }).catch(function (error) {
        this.show_loading = false;
        this.show_edit_messages = error.body.errors;
        this.show_edit_errors = true;
      });
    },
    editClearFrom: function() {
      this.edit_nvr_id = "";
      this.edit_nvr_name = "";
      this.edit_nvr_ip = "";
      this.edit_nvr_username = "";
      this.edit_nvr_password = ""
      this.edit_http_nvr_port = "";
      this.edit_vh_nvr_port = "";
      this.edit_sdk_nvr_port = "";
      this.edit_rtsp_nvr_port = "";
      this.edit_nvr_is_monitoring = false;
      this.show_loading = false;
      this.show_edit_errors = false;
      this.show_edit_messages = "";
    },
    initHideShow: function(){
      $(".nvr-column").each(function(){
        let that = $(this).attr("data-id");
        let nvrDataTable = $('#nvr-datatable').DataTable();
        let column = nvrDataTable.columns("." +that);
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
   deleteNvr: function(){
    $(document).on("click", ".delNVR", function(){
      let nvrRow, result;
      nvrRow = $(this).closest('tr');
      let nvrID = $(this).data("id");

      result = confirm("Are you sure to delete this NVR?");
      if (result === false) {
        return;
      }
      app.$http.delete("/nvrs/" + nvrID, {nvrRow: nvrRow}).then(function (response) {
        nvrRow.remove();
        app.$notify({group: 'notify', title: 'NVR has been deleted.'});
      }).catch(function (error) {
         return false
      });
    });
   },
   rebootNVR: function(){
    $(document).off("click").on("click", ".rebootNVR", function(){
      let nvrRow, result;
      nvrRow = $(this).closest('tr');
      let nvrID = $(this).data("id");

      result = confirm("Are you sure to delete this NVR?");
      if (result === false) {
        return;
      }
      app.$http.get("/nvrs/" + nvrID, {nvrRow: nvrRow}).then(function (response) {
        if (response.body.status != 201) {
          app.$notify({group: 'notify', title: response.body.message, type: 'error'});
        }else{
          app.$notify({group: 'notify', title: 'Nvr has been reboot successfully.'});
        }
      }).catch(function (error) {
          app.$notify({group: 'notify', title: error.body.message, type: 'error'});
        return false
      });
    });
   },
    active_menu_link: function(){
      $("li").removeClass(" m-menu__item--active");
      $(".nvrs").addClass(" m-menu__item--active");
    }
  }, // end of methods
  mounted(){
    this.get_session();
    this.rebootNVR();
    this.deleteNvr();
    let table =  this.initializeTable();
    this.getUniqueIdentifier(table);
    this.initHideShow();
    this.dataTable.search("");
    this.active_menu_link();
  }
}
</script>

<style lang="scss">
</style>
