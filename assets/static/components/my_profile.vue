<template>
    <div class="m-content">
       <img src="/images/loading.gif" id="api-wait" v-if="my_profile.show_loading">
      <div class="row">
          <div class="col-sm-12">
              <div class="m-portlet m-portlet--tab" style="margin-bottom:5px">
              <div class="m-portlet__head">
                  <div class="m-portlet__head-caption">
                      <div class="m-portlet__head-title">
                          <span class="m-portlet__head-icon m--hide">
                              <i class="la la-gear"></i>
                          </span>
                          <h3 class="m-portlet__head-text">
                              <i class="fa fa-user"></i> My Profile
                          </h3>
                      </div>
                  </div>
              </div>
                  <!--begin::Form-->
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
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.fname}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input" v-model="my_profile.firstname">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.lname}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input" v-model="my_profile.lastname">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
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
          </div>
      </div>
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" style="padding: 10px;">
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right m--margin-bottom-10">
            <div class="row align-items-center">
              <div class="col-xl-8 order-2 order-xl-1">
                <div class="form-group m-form__group row align-items-center">
                  <div class="col-md-4">
                    <h5>Three Accounts</h5>
                  </div>
                </div>
              </div>
              <div class="col-xl-4 order-1 order-xl-2 m--align-right" >
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
            </div>
          </div>
          <!--end: Search Form -->
          <table id="data-table" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
            <thead>
                <tr>
                    <th v-for="(item, index) in headings" v-bind:class="item.class">{{item.column}}</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="record in table_records">
                  <td class="text-center actions">
                    <div class="cursor_to_pointer fa fa-edit" v-on:click="onThreeEditButton(record)"></div>
                    <div class="cursor_to_pointer fa fa-trash" v-on:click="deleteThree(record.id, $event)"></div>
                  </td>
                  <td class="username">{{record.username}}</td>
                  <td class="password">{{record.password}}</td>
                  <td class="text-center bill_day">{{record.bill_day}}</td>
                  <td class="text-center created_at">{{record.created_at | formatDate }}</td>
                </tr>
              </tbody>
          </table>
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
                    <input type="hidden" v-model="three_user.edit_three_three_id">
                    <div class="form-group m-form__group row">
                        <label class="col-3 col-form-label">
                            {{form_labels.username}}
                        </label>
                        <div class="col-9">
                            <input type="text" class="form-control m-input m-input--solid" v-model="three_user.edit_username">
                        </div>
                    </div>
                    <div class="form-group m-form__group row">
                        <label class="col-3 col-form-label">
                            {{form_labels.password}}
                        </label>
                        <div class="col-9">
                            <input type="text" class="form-control m-input m-input--solid" v-model="three_user.edit_password">
                        </div>
                    </div>
                    <div class="form-group m-form__group row">
                      <label class="col-3 col-form-label">
                       {{form_labels.day}}
                      </label>
                      <div class="col-9">
                          <input type="number" class="form-control m-input m-input--solid" v-model="three_user.edit_bill_day" min="1" max="31">
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
</template>

<script>
import Vue from 'vue'
import App from './App.vue'
const app = new Vue(App)

module.exports = {
  name: 'my_profile',
  data: function(){
    return{
      table_records: '',
      dataTable: null,
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
    initDatatable: function(){
      this.$http.get('/three_accounts').then(
        response => {
          this.table_records = response.body.users
          $("#data-table .dataTables_empty").hide();
        }).catch(function(error){
        console.log(error)
      })
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
        this.initDatatable()
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
    onThreeEditButton: function(data){
      this.three_user.edit_three_three_id = data.id
      this.three_user.edit_username = data.username
      this.three_user.edit_password = data.password
      this.three_user.edit_bill_day = data.bill_day
      $(this.$refs.editmodal).modal("show");
    },
    deleteThree: function(threeID, event){
      let threeRow, result;
      threeRow = event.target.parentElement.parentElement
      result = confirm("Are you sure to delete this three user?");
      if (result === false) {
        return;
      }
      let data = {};
      data.id = threeID;
      this.$http.delete("/three_accounts/" + threeID, {threeRow: threeRow}).then(function (response) {
        threeRow.remove();
        app.$notify({group: 'notify', title: 'Three user has been deleted.'});
      }).catch(function (error) {
         return false
      });
   },
   updateThree: function(){
    this.three_user.show_edit_messages = "";
    this.three_user.show_loading = true;
    this.three_user.show_edit_errors = true;

    this.$http.patch('/three_accounts', {
      username: this.three_user.edit_username,
      password: this.three_user.edit_password,
      bill_day: this.three_user.edit_bill_day,
      id: this.three_user.edit_three_three_id
    }).then(function (response) {
      app.$notify({group: 'notify', title: 'Three user has been updated.'});
      this.three_user.show_loading = false;
      this.initDatatable()
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
   select_menu_link: function(){
     $("li").removeClass(" m-menu__item--active");
     $(".my_profile").addClass(" m-menu__item--active");
   }
  },
  created() {
    this.initDatatable();
  },
  mounted(){
    this.get_my_prfile();
    this.select_menu_link();
  },
  updated(){
    let dataTable = $('#data-table').DataTable({
    autoWidth: false,
    info: false,
    bPaginate: false,
    lengthChange: false,
    searching: true,
    scrollX: true,
    colReorder: true,
    retrieve: true
    });
    this.dataTable = dataTable;
  }
}
</script>

<style lang="scss">
</style>
