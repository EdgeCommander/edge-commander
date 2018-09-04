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
          <div class="text-center" v-if="loading_data == true" >
            <i class="fa fa-circle-o-notch fa-spin fa-5x fa-fw"></i>
            <span>Loading...</span>
          </div>
          <div class="m_nvr_datatable" style="display: none">
              <table id="data-table" class=" table table-striped  table-hover table-bordered display nowrap " cellspacing="0" width="100%">
                <thead>
                    <tr>
                        <th v-for="(item, index) in headings" v-bind:class="item.class" >{{item.column}}</th>
                    </tr>
                </thead>
                <tbody>
                    <tr v-for="record in table_records">
                      <td class="text-center reboot">
                        <button class="btn btn-default cursor_to_pointer"  style="font-size:10px;padding: 5px;" v-on:click="rebootNVR(record.id, $event)">Reboot</button>
                      </td>
                      <td class="text-center actions">
                        <div class="cursor_to_pointer fa fa-edit" v-on:click="onNVREditButton(record)"></div>
                        <div class="cursor_to_pointer fa fa-trash" v-on:click="deleteNVR(record.id, $event)"></div>
                      </td>
                      <td class="name">{{record.name}}&nbsp;&nbsp;&nbsp;
                        <a v-bind:href="'http://' +record.ip + ':' + record.port" target="_blank">
                          <span class="fa fa-external-link"></span></a>
                      </td>
                      <td class="ip">{{record.ip}}</td>
                      <td class="text-center port">{{record.port}}</td>
                      <td class="text-center vh_port">{{record.vh_port}}</td>
                      <td class="text-center sdk_port">{{record.sdk_port}}</td>
                      <td class="text-center rtsp_port">{{record.rtsp_port}}</td>
                      <td class="text-center username">{{record.username}}</td>
                      <td class="text-center password">{{record.password}}</td>
                      <td class="text-center model">{{record.model}}</td>
                      <td class="text-center firmware_version">{{record.firmware_version}}</td>
                      <td class="text-center encoder_released_date">{{record.encoder_released_date}}</td>
                      <td class="text-center encoder_version">{{record.encoder_version}}</td>
                      <td class="text-center firmware_released_date">{{record.firmware_released_date}}</td>
                      <td class="serial_number">{{record.serial_number}}</td>
                      <td class="text-center mac_address">{{record.mac_address}}</td>
                      <td class="text-center nvr_status">
                        <div v-if="record.nvr_status == false">
                          <span style='color:#d9534d' >Offline</span><span>{{record.reason | get_status_reason}}</span>
                        </div>
                        <span style='color:#5cb85c' v-if="record.nvr_status == true">Online</span>
                      </td>
                      <td class="text-center monitoring">{{record.is_monitoring}}</td>
                      <td class="text-center created_at">{{record.created_at | formatDate}}</td>
                    </tr>
                </tbody>
              </table>
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
    <div class="modal fade" ref="editmodal" id="edit_nvr_to_db" style="padding: 0px;" data-backdrop="static" data-keyboard="false">
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
                      <input type="hidden" id="user_id" v-model="user_id">
                      <input type="hidden" id="edit_nvr_id" v-model="edit_nvr_id">
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.name}}
                            </label>
                            <div class="col-9">
                               <input type="text" class="form-control m-input m-input--solid" id="edit_nvr_name" v-model="edit_nvr_name" aria-describedby="emailHelp" placeholder="Galway route.">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.ip}}
                            </label>
                            <div class="col-9">
                               <input type="text" class="form-control m-input m-input--solid" id="edit_nvr_ip" v-model="edit_nvr_ip" placeholder="https://youripmaybe">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.username}}
                            </label>
                            <div class="col-9">
                                <input type="text" class="form-control m-input m-input--solid" id="edit_nvr_username" v-model="edit_nvr_username" placeholder="i.e admin">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.password}}
                            </label>
                            <div class="col-9">
                                <input type="text" class="form-control m-input m-input--solid" id="edit_nvr_password" v-model="edit_nvr_password" placeholder="Super Secret">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.http_port}}
                            </label>
                            <div class="col-9">
                                <input type="number" class="form-control m-input m-input--solid" id="edit_http_nvr_port" v-model="edit_http_nvr_port" placeholder="i.e 80">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.rtsp_port}}
                            </label>
                            <div class="col-9">
                                <input type="number" class="form-control m-input m-input--solid" id="edit_rtsp_nvr_port" v-model="edit_rtsp_nvr_port" placeholder="i.e 880">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.sdk_port}}
                            </label>
                            <div class="col-9">
                                <input type="number" class="form-control m-input m-input--solid" id="edit_sdk_nvr_port" v-model="edit_sdk_nvr_port" placeholder="i.e 840">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.vh_port}}
                            </label>
                            <div class="col-9">
                                <input type="number" class="form-control m-input m-input--solid" id="edit_vh_nvr_port" v-model="edit_vh_nvr_port" placeholder="i.e 890">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                            </label>
                            <div class="col-9">
                                <label class="m-checkbox">
                                  <input type="checkbox" id="edit_nvr_is_monitoring" v-model="edit_nvr_is_monitoring">
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
                  <div class="form-group" >
                     <div class="column-checkbox" v-for="(item, index) in headings">
                      <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;"><input type="checkbox" class="users-column" v-bind:checked="item.visible" v-bind:id="index" v-bind:name="item.id" v-on:change="showHideColumns(index)"><span></span> {{item.column}}</label>
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
module.exports = {
  name: 'nvrs',
  data: function(){
    return{
      dataTable: null,
      table_records: "",
      m_form_search: "",
      show_loading: false,
      show_add_errors: false,
      show_edit_errors: false,
      show_add_messages: "",
      show_edit_messages: "",
      loading_data: true,
      headings: [
        {column: "Reboot", visible: "checked", id: "reboot", class: "text-center reboot"},
        {column: "Actions", visible: "checked", id: "actions", class: "text-center"},
        {column: "Name", visible: "checked", class: "name"},
        {column: "IP", visible: "checked", id: "ip"},
        {column: "HTTP Port", visible: "", class: "text-center port"},
        {column: "VH Port", visible: "", class: "text-center vh_port"},
        {column: "SDK Port", visible: "", class: "text-center sdk_port"},
        {column: "RTSP Port", visible: "", class: "text-center rtsp_port"},
        {column: "Username", visible: "", class: "text-center username"},
        {column: "Password", visible: "", class: "text-center password"},
        {column: "Model", visible: "checked", class: "text-center"},
        {column: "Firmware Version", visible: "checked", class: "text-center"},
        {column: "Encoder Released Date", visible: "", class: "text-center encoder_released_date"},
        {column: "Encoder Version", visible: "", class: "text-center encoder_version"},
        {column: "Firmware Released Date", visible: "", class: "text-center firmware_released_date"},
        {column: "Serial Number", visible: "", class: "serial_number"},
        {column: "Mac Address", visible: "", class: "text-center mac_address"},
        {column: "Status", visible: "checked", class: "text-center"},
        {column: "Monitoring", visible: "", class: "text-center monitoring"},
        {column: "Created At", visible: "", class: "text-center created_at"},
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
    initDatatable: function(){
      this.$http.get('/nvrs/data').then(
        response => {
          this.table_records = response.body.nvrs
          $("#data-table .dataTables_empty").hide();
        }).then(()=>{
        this.init_datatable();
    }).catch(function(error){
      console.log(error)
    })
   },
   get_session: function(){
    this.$http.get('/get_porfile').then(response => {
      this.user_id = response.body.id;
    });
   },
   search: function(){
    this.dataTable.search(this.m_form_search).draw();
   },
   onNVRHideShowButton: function(){
    $(this.$refs.hideShow).modal("show");
   },
   showHideColumns: function(id){
    let column = this.dataTable.columns(id);
    if(column.visible()[0] == true){
      column.visible(false);
    }else{
      column.visible(true);
    }
   },
   onNVRButton: function(){
    $(this.$refs.addmodal).modal("show");
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
        $.notify({message: 'NVR has been added.'},{type: 'info'});
        this.show_loading = false;
        this.initDatatable()
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
      this.show_add_messages = "";
      this.show_add_errors = false;
   },
   onNVREditButton: function(data){
    this.edit_nvr_id = data.id
    this.edit_nvr_name = data.name
    this.edit_nvr_ip = data.ip
    this.edit_nvr_username = data.username
    this.edit_nvr_password = data.password
    this.edit_http_nvr_port = data.port
    this.edit_sdk_nvr_port = data.sdk_port
    this.edit_vh_nvr_port = data.vh_port
    this.edit_rtsp_nvr_port = data.rtsp_port
    this.edit_nvr_is_monitoring = data.is_monitoring
    $(this.$refs.editmodal).modal("show");
   },
   updateNVRdo: function(){
      this.show_loading = true;
      this.show_edit_errors = true;

      let nvrID = this.edit_nvr_id;

      this.$http.patch("/nvrs/" + nvrID, {
        name: this.edit_nvr_name,
        ip: this.edit_nvr_ip,
        username: this.edit_nvr_username,
        password: this.edit_nvr_password,
        port: this.edit_http_nvr_port,
        sdk_port: this.edit_sdk_nvr_port,
        vh_port: this.edit_vh_nvr_port,
        is_monitoring: this.edit_nvr_is_monitoring,
        rtsp_port: this.edit_rtsp_nvr_port,
        id: nvrID
      }).then(function (response) {
        $.notify({message: 'NVR has been updated.'},{type: 'info'});
        this.show_loading = false;
        this.initDatatable()
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
    deleteNVR: function(nvrID, event){
      let nvrRow, result;
      nvrRow = event.target.parentElement.parentElement
      result = confirm("Are you sure to delete this NVR?");
      if (result === false) {
        return;
      }
      let data = {};
      data.id = nvrID;
      this.$http.delete("/nvrs/" + nvrID, {nvrRow: nvrRow}).then(function (response) {
        nvrRow.remove();
        $.notify({message: 'NVR has been deleted.'},{type: 'info'});
      }).catch(function (error) {
         return false
      });
    },
    rebootNVR: function(nvrID, event){
      let nvrRow, result;
      nvrRow = event.target.parentElement.parentElement
      result = confirm("Are you sure to reboot this NVR?");
      if (result === false) {
        return;
      }
      this.$http.get("/nvrs/" + nvrID, {nvrRow: nvrRow}).then(function (response) {
        if (response.body.status != 201) {
          $.notify({message: response.body.message},{type: 'danger'});
        }else{
          $.notify({message: "Nvr has been reboot successfully."},{type: 'info'});
        }
      }).catch(function (error) {
       $.notify({ message: error.body.message },{ type: 'danger'});
        return false
      });
    },
    init_datatable: function(){
      let dataTable = $('#data-table').DataTable({
        autoWidth: true,
        info: false,
        bPaginate: false,
        lengthChange: false,
        searching: true,
        scrollX: true,
        colReorder: true,
        retrieve: true,
        fnInitComplete: function(){
           $(".m_nvr_datatable").css("display", "block")
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
        }
      });
      this.dataTable = dataTable;

      dataTable.columns([
        '.port',
        '.vh_port',
        '.sdk_port',
        '.rtsp_port',
        '.username',
        '.password',
        '.encoder_released_date',
        '.encoder_version',
        '.firmware_released_date',
        '.serial_number',
        '.mac_address',
        '.monitoring',
        '.created_at'
        ] 
      ).visible(false);  
      dataTable.columns.adjust().draw(false); // adjust column sizing and redraw  
     this.loading_data = false;
    }
  },
  created() {
    this.initDatatable();

  },
  mounted(){
    this.get_session();
  }
}
</script>

<style lang="scss">
</style>
