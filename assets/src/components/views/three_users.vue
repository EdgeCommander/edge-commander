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
                      <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item">
                            <router-link v-bind:to="'/my_profile'" class="nav-link">My Profile</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/three_users'" class="nav-link  active show">Three Users</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/activities'" class="nav-link">Activities</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/sharing'" class="nav-link">Sharing</router-link>
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
            <table id="user-datatable" class="table table-striped  table-hover table-bordered datatable display nowrap" cellspacing="0" width="100%">
                <thead>
                    <tr>
                        <th v-for="(item, index) in headings">{{item.column}}</th>
                    </tr>
                </thead>
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
                    <img src="../../assets/images/loading.gif" id="api-wait" v-if="three_user.show_loading">
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
                <img src="../../assets/images/loading.gif" id="api-wait" v-if="three_user.show_loading">
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
                    <input type="hidden" id="user_id" v-model="user_id">
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
import $ from "jquery";
import moment from "moment";
import three_users from './three_users.vue'
import App from '../../App.vue'
const app = new Vue(App)

export default {
  name: 'three_users',
  data: function(){
    return{
      table_records: '',
      dataTable: null,
      sharing_dataTable: null,
      add_button_label: "Add New",
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
        hide_show_button: "OK",
      },
      user_id: this.$root.user_id
    }
  },
  methods: {
    date_format: function(id){
      let string = $("#" + id).val().split("-")
      return string[2] +"-"+ string[1]  +"-"+ string[0]
    },
    initializeTable: function(){
      let userDataTable = $('#user-datatable').DataTable({
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
          return '<div class="action_btn"><div id class="editUser cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="cursor_to_pointer fa fa-trash delUser" data-id="'+ row.id +'"></div></div>';
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
          return moment(row.created_at).format('DD-MM-YYYY HH:mm:ss');
        }
      },
      ],
      info: false,
      bPaginate: false,
      lengthChange: false,
      scrollX: true,
      colReorder: true,
      stateSave:  true
    });
      return this.dataTable = userDataTable;
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
        Vue.notify({group: 'notify', title: 'Three user has been added.'});
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
    getUniqueIdentifier: function(userDataTable){
      $(document).on("click", ".editUser", function(){
        let tr = $(this).closest('tr');
        let row = userDataTable.row(tr);
        let data = row.data();
        let user_id = $(this).data("id");
        three_users.methods.onThreeEditButton(user_id, data);
      });
    },
    onThreeEditButton: function(user_id, data){
      $("#edit_three_three_id").val(user_id);
      $("#edit_username").val(data.username);
      $("#edit_password").val(data.password);
      $("#edit_bill_day").val(data.bill_day);
      $('#edit_three_user_to_db').modal('show');
    },
    deleteThree: function(){
    $(document).on("click", ".delUser", function(){
      let threeRow, result;
      threeRow = $(this).closest('tr');
      let threeID = $(this).data("id");

      result = confirm("Are you sure to delete this three user?");
      if (result === false) {
        return;
      }
      app.$http.delete("/three_accounts/" + threeID, {threeRow: threeRow}).then(function (response) {
        threeRow.remove();
        Vue.notify({group: 'notify', title: 'Three user has been deleted.'});
      }).catch(function (error) {
         return false
      });
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
      Vue.notify({group: 'notify', title: 'Three user has been updated.'});
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
  },
  mounted(){
    this.active_menu_link();
    let table =  this.initializeTable();
    this.getUniqueIdentifier(table)
    this.deleteThree();
  }
}
</script>

<style lang="scss">
</style>
