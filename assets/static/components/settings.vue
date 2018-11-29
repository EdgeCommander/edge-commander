<template>
  <div>
    <div class="m-content">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" style="padding: 10px;">
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right m--margin-bottom-10">
            <div class="row align-items-center">
              <div class="col-md-12">
                <div class="form-group m-form__group row align-items-center">
                  <div class="col-md-12">
                    <div class="m-input-icon m-input-icon--left">
                      <ul class="nav nav-tabs" role="tablist">
                        <li class="nav-item">
                            <a class="nav-link  active show" data-toggle="tab" href="#m_tabs_1_1">My Profile</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-toggle="tab" href="#m_tabs_1_2" v-on:click="redraw_table">Three Users</a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-toggle="tab" href="#m_tabs_1_3" v-on:click="redraw_table">Activities</a>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-4 order-1 order-md-2 m--align-right">
              </div>
            </div>
          </div>
          <!--end: Search Form -->
           <div class="tab-content">
              <div class="tab-pane  active show" id="m_tabs_1_1" role="tabpanel">
                <div class="heading_panel">
                    <div class="pull-left">
                      <h4>My Profile Details <i class="fa fa-long-arrow-right"></i></h4>
                    </div>
                    <div class="pull-right"></div>
                    <div class="clearfix"></div>
                  </div>
                  <div class="col-sm-6">
                   <div id="myProfileErrorDetail" v-if="my_profile.show_errors">
                      <div class="form-group m-form__group m--margin-top-10">
                          <div class="alert m-alert m-alert--default" role="alert">
                              <ul style="margin:0px">
                                <li v-for="message in my_profile.show_message">{{message}}</li>
                              </ul>
                          </div>
                      </div>
                    </div>
                   <div class="m--margin-top-20">
                    <img class="gravatar pull-left" v-bind:src="my_profile.gravatar_url">
                    <div class="username">
                      <span class="grey">Username </span><strong><span v-html="my_profile.username"></span></strong>
                    </div>
                    <p class="small grey">Manage your avatar with <a href="https://en.gravatar.com/" target="_blank">Gravatar</a> </p>
                  </div>
                  <div class="clearfix"></div>
                  <div class="m-form m-form--fit m-form--label-align-left" style="margin-left:10px">
                      <input type="hidden" id="id"  v-model="user_id">
                      <input type="hidden"  v-model="my_profile.csrf_token">
                      <div class="form-group m-form__group row" style="margin-bottom: 0">
                          <label class="col-3 col-form-label">
                              {{form_labels.fname}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input" v-model="my_profile.firstname">
                          </div>
                      </div>
                      <div class="form-group m-form__group row" style="margin-bottom: 0">
                          <label class="col-3 col-form-label">
                              {{form_labels.lname}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input" v-model="my_profile.lastname">
                          </div>
                      </div>
                      <div class="form-group m-form__group row" style="margin-bottom: 0">
                          <label class="col-3 col-form-label">
                              {{form_labels.email}}
                          </label>
                          <div class="col-9">
                              <input type="email" class="form-control m-input" v-model="my_profile.email">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.password}}
                          </label>
                          <div class="col-9">
                              <input type="password" class="form-control m-input" v-model="my_profile.password" >
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.api_key}}
                          </label>
                          <div class="col-9" style="padding:10px 15px" v-html="my_profile.api_key"></div>
                      </div>
                      <div class="form-group m-form__group row" style="padding-top:0">
                          <label class="col-3 col-form-label">
                              {{form_labels.api_id}}
                          </label>
                          <div class="col-9" style="padding:10px 15px" v-html="my_profile.api_id"></div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                          </label>
                          <div class="col-9">
                            <button type="button" class="btn btn-default" id="updateMyProfile" v-on:click="updateMyProfile()">
                              {{form_labels.submit_button}}
                            </button>
                          </div>
                      </div>
                      <div style="height:20px"></div>
                  </div>
              </div>
              </div>
              <div class="tab-pane" id="m_tabs_1_2" role="tabpanel">
                  <div class="heading_panel" style="margin-bottom: 10px">
                    <div class="pull-left">
                      <h4>Three Users <i class="fa fa-long-arrow-right"></i></h4>
                    </div>
                    <div class="pull-right">
                      <a href="javascript:void(0)" class="btn btn-primary m-btn m-btn--icon" v-on:click="onUserButton">
                          <span>
                              <i class="fa fa-plus-square"></i>
                              <span>
                                  {{add_button_label}}
                              </span>
                          </span>
                      </a>
                      <div href="javascript:void(0)" class="btn btn-default grey" v-on:click="onUserHideShowButton">
                        <i class="fa fa-columns"></i>
                      </div>
                    </div>
                    <div class="clearfix"></div>
                  </div>
                  <table id="nvr-datatable" class="table table-striped  table-hover table-bordered datatable display nowrap" cellspacing="0" width="100%">
                      <thead>
                          <tr>
                              <th v-for="(item, index) in headings">{{item.column}}</th>
                          </tr>
                      </thead>
                  </table>
              </div>
              <div class="tab-pane" id="m_tabs_1_3" role="tabpanel">
                  <div class="heading_panel">
                    <div class="pull-left">
                      <h4>Activity logs <i class="fa fa-long-arrow-right"></i></h4>
                    </div>
                    <div class="pull-right">
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
                    <div class="clearfix"></div>
                  </div>
                  <table id="logs-datatable" class="table table-striped  table-hover table-bordered datatable display nowrap" cellspacing="0" width="100%">
                      <thead>
                          <tr>
                              <th v-for="(item, index) in headings_logs">{{item.column}}</th>
                          </tr>
                      </thead>
                  </table>
              </div>
          </div>
        </div>
      </div>
            <!-- start:: add user Models -->
<div class="modal fade add_user_to_db" ref="addmodal"  style="padding: 0px;" id="m_modal_1" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
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
                <div class="modal-body">
                    <img src="/images/loading.gif" id="api-wait" v-if="three_user.show_loading">
                    <div id="threeErrorDetails" v-if="three_user.show_add_errors">
                        <div class="form-group m-form__group m--margin-top-10">
                            <div class="alert m-alert m-alert--default" role="alert">
                                <ul style="margin:0px">
                                   <li v-for="message in three_user.show_add_messages">{{message}}</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div class="m-form m-form--fit m-form--label-align-left">
                        <input type="hidden" v-model="user_id" >
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.username}}
                            </label>
                            <div class="col-9">
                                <input type="text" class="form-control m-input m-input--solid" v-model="three_user.username">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.password}}
                            </label>
                            <div class="col-9">
                                <input type="text" class="form-control m-input m-input--solid" v-model="three_user.password">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                           {{form_labels.day}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" v-model="three_user.bill_day" min="1" max="31">
                          </div>
                      </div>
                    </div>
                    <!--end::Form-->
                </div>
                <div class="modal-footer" style="padding: 11px;">
                    <button id="" type="button" class="btn btn-default" v-on:click="saveThreeModal()">
                        {{form_labels.submit_button}}
                    </button>
                </div>
            </div>
        </div>
</div>
<!-- end:: add user Models -->
  <!-- begin::hide/show Models -->
<div id="toggle-datatable-columns" ref="hideShow" class="modal fade" style="padding: 0px;">
  <div class="modal-dialog" style="width:300px;">
    <div class="modal-content" style="padding: 0px;">
      <div class="modal-header">
        <div class="caption"><strong>{{form_labels.hide_show_title}}</strong></div>
        <div class="cancel">
          <a class="cancel_link" href="#" data-dismiss="modal">X</a>
        </div>
      </div>
      <div class="modal-body" style="padding: 15px;padding-bottom: 0px;">
        <div class="form-group" >
           <div class="column-checkbox" v-for="(item, index) in headings">
            <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;"><input type="checkbox" class="users-column" checked="checked" v-bind:id="index" v-bind:name="item.id" v-on:change="showHideColumns(index)"><span></span> {{item.column}}</label>
          </div>
        </div>
      </div>
      <div class="modal-footer" style="padding: 11px;">
        <div class="pull-right">
          <button type="button" class="btn btn-default" data-dismiss="modal">{{form_labels.hide_show_button}}</button>
        </div>
      </div>
    </div>
  </div>
</div>
<!-- end:: hide/show Models -->
<!--start:: edit user Models-->
<div class="modal fade" id="edit_three_user_to_db" ref="editmodal" style="padding: 0px;" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog" role="document">
        <div class="modal-content" style="padding: 0px;">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">
                    {{form_labels.edit_title}}
                </h5>
                <div class="cancel">
                    <a href="#" id="discardEditModal" data-dismiss="modal" v-on:click="editClearFrom()">X</a>
                </div>
            </div>
            <div class="modal-body" id="body-three-edit-dis">
                <img src="/images/loading.gif" id="api-wait" v-if="three_user.show_loading">
                <div id="threeEditErrorDetails" v-if="three_user.show_edit_errors">
                    <div class="form-group m-form__group m--margin-top-10">
                        <div class="alert m-alert m-alert--default" role="alert">
                            <ul style="margin:0px">
                               <li v-for="message in three_user.show_edit_messages">{{message}}</li>
                            </ul>
                        </div>
                    </div>
                </div>
                <div class="m-form m-form--fit m-form--label-align-left">
                    <input type="hidden" id="user_id" value="<%= @user.id %>">
                    <input type="hidden" id="edit_three_three_id">
                    <div class="form-group m-form__group row">
                        <label class="col-3 col-form-label">
                            {{form_labels.username}}
                        </label>
                        <div class="col-9">
                            <input type="text" class="form-control m-input m-input--solid" id="edit_username">
                        </div>
                    </div>
                    <div class="form-group m-form__group row">
                        <label class="col-3 col-form-label">
                            {{form_labels.password}}
                        </label>
                        <div class="col-9">
                            <input type="text" class="form-control m-input m-input--solid" id="edit_password">
                        </div>
                    </div>
                    <div class="form-group m-form__group row">
                      <label class="col-3 col-form-label">
                       {{form_labels.day}}
                      </label>
                      <div class="col-9">
                          <input type="number" class="form-control m-input m-input--solid"  id="edit_bill_day" min="1" max="31">
                      </div>
                    </div>
                </div>
                <!--end::Form-->
            </div>
            <div class="modal-footer" style="padding: 11px;">
                <button id="" type="button" class="btn btn-default" v-on:click="updateThree">
                    {{form_labels.submit_button}}
                </button>
            </div>
        </div>
    </div>
</div>
 <!-- end:: edit user Models -->
    </div>
  </div>
</template>

<script>
import Vue from 'vue'
import App from './App.vue'
const app = new Vue(App)

module.exports = {
  name: 'settings',
  data: function(){
    return{
      table_records: '',
      dataTable: null,
      logsDataTable: null,
      add_button_label: "Add New",
      my_profile: {
        show_loading: false,
        show_message: [],
        show_errors: false,
        firstname: "",
        lastname: "",
        email: "",
        password: "",
        api_key: "",
        api_id: "",
        username: "",
        gravatar_url: "",
        csrf_token: ""
      },
      three_user: {
        show_loading: false,
        show_add_errors: false,
        show_edit_errors: false,
        show_add_messages: [],
        show_edit_messages: [],
        username: "",
        password: "",
        bill_day: "",
        edit_three_three_id: "",
        edit_username: "",
        edit_password: "",
        edit_bill_day: ""
      },
      headings: [
        {column: "Actions", id: "actions", class: "text-center"},
        {column: "Username", id: "username"},
        {column: "Password", id: "password"},
        {column: "Bill Day", id: "bill_day", class: "text-center"},
        {column: "Created At", id: "created_at", class: "text-center"}
      ],
      headings_logs: [
        {column: "Browser", id: "browser"},
        {column: "IP address", id: "ip_address"},
        {column: "Country", id: "country", class: "text-center"},
        {column: "Date & Time", id: "created_at", class: "text-center"},
        {column: "Event", id: "created_at"}
      ],
      form_labels: {
        fname: "First Name",
        lname: "Last Name",
        email: "Email",
        password: "Password",
        api_key: "Api Key",
        api_id: "Api Id",
        title: "My Profile",
        submit_button: "Save changes",
        add_title: "Add new account (three.ie)",
        username: "Username",
        password: "Password",
        day: "Bill Day",
        edit_title: "Edit account details",
        hide_show_title: "Show/Hide Columns",
        hide_show_button: "OK"
      },
      user_id: ""
    }
  },
  filters:{
    formatDate: function(value){
      return moment(String(value)).format('DD/MM/YYYY HH:mm:ss')
    }
  },
  methods: {
    initializeLogsTable: function(){
      $("#m_sms_datepicker_from").datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date(new Date().getTime() - (48 * 60 * 60 * 1000)));
      $("#m_sms_datepicker_to").datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date());

      let from_date = $("#m_sms_datepicker_from").val(),
      to_date = $("#m_sms_datepicker_to").val();

      let logsDataTable = $('#logs-datatable').DataTable({
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
      url: "/user_logs/" + from_date + "/" + to_date,
        dataSrc: function(data) {
          return data.activity_logs;
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
        class: "text-left browser",
        data: function(row, type, set, meta) {
          let browser = row.browser
          let platform = row.platform
          let browser_icon
          if(browser == 'IE'){
              browser_icon = "internet-explorer"
          }else{
            browser_icon = browser.toLowerCase()
          }
          return '<i class="fa fa-'+browser_icon+'" aria-hidden="true"></i> ' +browser + ' on ' + platform ;
        }
      },
      {
        class: "text-center ip",
        data: function(row, type, set, meta) {
          return row.ip;
        }
      },
      {
        class: "country",
        data: function(row, type, set, meta) {
          let country = row.country
          let country_code = row.country_code
          if(country != null){
            return '<img src="https://www.countryflags.io/'+country_code+'/shiny/16.png"> '+row.country;
          }else{
            return "---"
          }
        }
      },
      {
        class: "text-center inserted_at",
        data: function(row, type, set, meta) {
          return moment(row.inserted_at).format('DD/MM/YYYY HH:mm:ss');
        }
      },
      {
        class: "text-left event",
        data: function(row, type, set, meta) {
          return row.event;
        }
      }
      ],
      autoWidth: true,
      info: false,
      bPaginate: false,
      lengthChange: false,
      scrollX: true,
      colReorder: true,
      stateSave:  true,
      order: [[ 3, "desc" ]]
    });
      this.logsDataTable = logsDataTable
   },
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
      url: "/three_accounts",
        dataSrc: function(data) {
          return data.users;
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
        class: "text-center actions",
        data: function(row, type, set, meta) {
          return '<div class="action_btn"><div id class="editNVR cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="cursor_to_pointer fa fa-trash delNVR" data-id="'+ row.id +'"></div></div>';
        }
      },
      {
        class: "text-left username",
        data: function(row, type, set, meta) {
          return row.username;
        }
      },
      {
        class: "text-center password",
        data: function(row, type, set, meta) {
          return row.password;
        }
      },
      {
        class: "text-center bill_day",
        data: function(row, type, set, meta) {
          return row.bill_day;
        }
      },
      {
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
    updateMyProfile: function() {
      this.my_profile.show_loading = true;
      this.my_profile.show_errors = true;

      this.$http.patch('/update_profile', {
        firstname: this.my_profile.firstname,
        lastname: this.my_profile.lastname,
        email: this.my_profile.email,
        password: this.my_profile.password,
        id: this.user_id
      }).then(function (response) {
        this.my_profile.show_message = "";
        this.my_profile.show_errors = false;
        this.my_profile.show_loading = false;
        this.my_profile.password = "";
        app.$notify({group: 'notify', title: 'Profile has been updated.'});
      }).catch(function (error) {
        this.my_profile.show_message = error.body.errors;
        this.my_profile.show_errors = true;
        this.my_profile.show_loading = false;
       });
    },
    get_my_prfile: function(){
      this.$http.get('/get_porfile').then(response => {
        this.my_profile.firstname = response.body.firstname;
        this.my_profile.lastname = response.body.lastname;
        this.my_profile.email = response.body.email;
        this.my_profile.api_key = response.body.api_key;
        this.my_profile.api_id = response.body.api_id;
        this.user_id = response.body.id;
        this.my_profile.username = response.body.username;
        this.my_profile.gravatar_url = response.body.gravatar_url;
        this.my_profile.csrf_token = response.body.csrf_token;
      });
    },
    onUserButton: function(){
      $(this.$refs.addmodal).modal("show");
    },
    saveThreeModal: function(){
      this.three_user.show_loading = true;
      this.three_user.show_add_errors = true;
      this.$http.post('/three_accounts', {
        username: this.three_user.username,
        password: this.three_user.password,
        user_id:  this.user_id,
        bill_day: this.three_user.bill_day
      }).then(function (response) {
        app.$notify({group: 'notify', title: 'Three user has been added.'});
        this.three_user.show_loading = false;
        this.dataTable.ajax.reload();
        this.clearForm();
        $(this.$refs.addmodal).modal("hide");
      }).catch(function (error) {
        this.three_user.show_add_messages = error.body.errors;
        this.three_user.show_add_errors = true;
        this.three_user.show_loading = false;
      });
    },
    clearForm: function(){
      this.three_user.username = ""
      this.three_user.password = ""
      this.three_user.bill_day = ""
      this.three_user.show_add_errors = false;
      this.three_user.show_add_messages = "";
    },
    getUniqueIdentifier: function(nvrDataTable){
      $(document).on("click", ".editNVR", function(){
        let tr = $(this).closest('tr');
        let row = nvrDataTable.row(tr);
        let data = row.data();
        let nvr_id = $(this).data("id");
        module.exports.methods.onThreeEditButton(nvr_id, data);
      });
    },
    onThreeEditButton: function(nvr_id, data){
      $("#edit_three_three_id").val(nvr_id);
      $("#edit_username").val(data.username);
      $("#edit_password").val(data.password);
      $("#edit_bill_day").val(data.bill_day);
      $('#edit_three_user_to_db').modal('show');
    },
    deleteThree: function(){
    $(document).on("click", ".delNVR", function(){
      let threeRow, result;
      threeRow = $(this).closest('tr');
      let threeID = $(this).data("id");

      result = confirm("Are you sure to delete this three user?");
      if (result === false) {
        return;
      }
      app.$http.delete("/three_accounts/" + threeID, {threeRow: threeRow}).then(function (response) {
        threeRow.remove();
        app.$notify({group: 'notify', title: 'Three user has been deleted.'});
      }).catch(function (error) {
         return false
      });
    });
   },
   dateFilterInitialize: function() {
    let table_data = this.logsDataTable;
    $('#m_sms_datepicker_from, #m_sms_datepicker_to').change(function(){
      let from_date = $("#m_sms_datepicker_from").val(),
        to_date = $("#m_sms_datepicker_to").val();
        let new_url = "/user_logs/" + from_date + "/" + to_date
        table_data.ajax.url(new_url).load();
    });
  },
   updateThree: function(){
    this.three_user.show_edit_messages = "";
    this.three_user.show_loading = true;
    this.three_user.show_edit_errors = true;
    this.$http.patch('/three_accounts', {
      username: $("#edit_username").val(),
      password: $("#edit_password").val(),
      bill_day: $("#edit_bill_day").val(),
      id: $("#edit_three_three_id").val()
    }).then(function (response) {
      app.$notify({group: 'notify', title: 'Three user has been updated.'});
      this.three_user.show_loading = false;
      this.dataTable.ajax.reload();
      this.editClearFrom();
      $(this.$refs.editmodal).modal("hide");
    }).catch(function (error) {
      this.three_user.show_loading = false;
      this.three_user.show_edit_messages = error.body.errors;
      this.three_user.show_edit_errors = true;
    });
   },
   editClearFrom: function() {
    this.three_user.edit_username = ""
    this.three_user.edit_password = ""
    this.three_user.edit_bill_day = ""
    this.three_user.show_edit_messages = "";
    this.three_user.show_edit_errors = false;
   },
   onUserHideShowButton: function(){
    $(this.$refs.hideShow).modal("show");
   },
   showHideColumns: function(id){
    let column = this.dataTable.columns(id);
    console.log(column.visible()[0])
    if(column.visible()[0] == true){
      column.visible(false);
    }else{
      column.visible(true);
    }
   },
   active_menu_link: function(){
    $("li").removeClass(" m-menu__item--active");
    $(".settings").addClass(" m-menu__item--active");
    $("#m_aside_left").removeClass("m-aside-left--on");
    $("body").removeClass("m-aside-left--on");
    $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
   },
   redraw_table: function(){
    this.dataTable.ajax.reload();
    this.logsDataTable.ajax.reload();
   }
  },
  mounted(){
    this.get_my_prfile();
    this.active_menu_link();
    let table =  this.initializeTable();
    this.getUniqueIdentifier(table)
    this.deleteThree();
    this.initializeLogsTable();
    this.dateFilterInitialize();
  }
}
</script>

<style lang="scss">
</style>
