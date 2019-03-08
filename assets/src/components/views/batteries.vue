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
                 <a href="javascript:void(0)" id="addRULE" class="btn btn-primary m-btn m-btn--icon" v-on:click="onBatteryButton">
                      <span>
                          <i class="fa fa-plus-square"></i>
                          <span>
                              {{form_labels.add_battery_button}}
                          </span>
                      </span>
                  </a>
                  <div href="javascript:void(0)" class="btn btn-default grey" v-on:click="onHideShowButton">
                    <i class="fa fa-columns"></i>
                  </div>
              </div>
            </div>
          </div>
          <!--end: Search Form -->
          <div>
          </div>
            <table id="battery-datatable" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
                <thead>
                    <tr>
                        <th v-for="(item, index) in headings">{{item.column}}</th>
                    </tr>
                </thead>
            </table>
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
    <div class="modal fade add_rule_to_db"  ref="addmodal" style="padding: 0px;" id="m_modal_1" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content" style="padding: 0px;">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">
                       {{form_labels.add_title}}
                    </h5>
                    <div class="cancel">
                        <a href="#" id="discardModal" data-dismiss="modal" v-on:click="clearForm">X</a>
                    </div>
                </div>
                <div class="modal-body" id="body-rule-dis">
                    <img src="../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                    <div id="ruleErrorDetails"  v-if="show_add_errors">
                        <div class="form-group m-form__group m--margin-top-10">
                            <div class="alert m-alert m-alert--default" role="alert">
                                <ul style="margin:0px">
                                  <li v-for="message in show_add_messages">{{message}}</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div class="m-form m-form--fit m-form--label-align-left">
                        <input type="hidden" id="user_id" v-model="user_id">
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.name}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="battery_name" v-model="battery_name">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.battery_source_url}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="battery_source_url"  v-model="battery_source_url">
                            </div>
                        </div>
                         <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                            </label>
                            <div class="col-10">
                                <label class="m-checkbox">
                                    <input type="checkbox" id="battery_is_active" v-model="battery_is_active">
                                        {{form_labels.status}}
                                    <span></span>
                                </label>
                            </div>
                        </div>
                    </div>
                    <!--end::Form-->
                </div>
                <div class="modal-footer" style="padding: 11px;">
                    <button id="" type="button" class="btn btn-default" v-on:click="saveModal">
                        {{form_labels.submit_button}}
                    </button>
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="edit_battery_to_db" ref="editmodal" style="padding: 0px;" data-backdrop="static" data-keyboard="false">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content" style="padding: 0px;">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">
                        {{form_labels.edit_title}}
                    </h5>
                    <div class="cancel">
                        <a href="#" id="discardEditModal" data-dismiss="modal" v-on:click="editClearFrom">X</a>
                    </div>
                </div>
                <div class="modal-body" id="body-rule-edit-dis">
                    <img src="../../assets/images/loading.gif" id="api-wait"  v-if="show_loading">
                    <div id="ruleEditErrorDetails"  v-if="show_edit_errors">
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
                        <input type="hidden" id="edit_battery_id" >
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.name}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="edit_battery_name" >
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.battery_source_url}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="edit_battery_source_url">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                            </label>
                            <div class="col-10">
                                <label class="m-checkbox">
                                    <input type="checkbox" id="edit_battery_is_active">
                                    {{form_labels.status}}
                                    <span></span>
                                </label>
                            </div>
                        </div>
                    </div>
                    <!--end::Form-->
                </div>
                <div class="modal-footer" style="padding: 11px;">
                    <button id="" type="button" class="btn btn-default" v-on:click="updateBattery">
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
import $ from "jquery";
import moment from "moment";
import batteries from './batteries.vue';
import App from '../../App.vue'
const app = new Vue(App)

export default {
  name: 'batteries',
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
        {column: "Actions", visible: "checked", id: "actions"},
        {column: "Name", visible: "checked", id: "name"},
        {column: "URL", visible: "checked", id: "source_url"},
        {column: "Active", visible: "checked", id: "active"},
        {column: "Created At", visible: "checked", id: "created_at"}
      ],
      form_labels: {
        name: "Name",
        battery_source_url: "Source URL",
        submit_button: "Save changes",
        edit_title: "Edit Battery",
        add_title: "Add Battery",
        hide_show_title: "Show/Hide Columns",
        add_battery_button: "Add Battery",
        hide_show_button: "OK",
        status: "Active"
      },
      edit_battery_name: "",
      edit_battery_id: "",
      edit_battery_source_url: "",
      battery_name: "",
      battery_source_url: "",
      user_id: this.$root.user_id,
      battery_is_active: false,
      edit_battery_is_active: false
    }
  },
  methods: {
    initializeTable: function(){
      let batteryDataTable = $('#battery-datatable').DataTable({
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
        batteryDataTable.search("").draw();
      },
      ajax: {
      url: "/battery",
        dataSrc: function(data) {
          return data.batteries;
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
          return '<div id="action_btn"><div class="editRecord cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="cursor_to_pointer fa fa-trash delBattery" data-id="'+ row.id +'"></div></div>';
        }
      },
      {
        class: "name",
        data: function(row, type, set, meta) {
          return "<a href='/battery/"+row.id+"'style='color: blue;text-decoration: underline;cursor: pointer; link'>"+row.name+"</a>";
        }
      },
      {
        class: "source_url",
        data: function(row, type, set, meta) {
          return row.source_url;
        }
      },
      {
        class: "text-center active",
        data: function(row, type, set, meta) {
          return row.active;
        }
      },
      {
        class: "text-center created_at",
        data: function(row, type, set, meta) {
          return moment(row.created_at).format('DD-MM-YYYY HH:mm:ss');
        },
      },
      ],
      info: false,
      bPaginate: false,
      lengthChange: false,
      scrollX: true,
      colReorder: true
    });
      return this.dataTable = batteryDataTable;
   },
   search: function(){
      this.dataTable.search(this.m_form_search).draw();
   },
   getUniqueIdentifier: function(batteryDataTable){
      $(document).on("click", ".editRecord", function(){
        var tr = $(this).closest('tr');
        var row = batteryDataTable.row(tr);
        var data = row.data();
        let battery_id = $(this).data("id");
        batteries.methods.onRuleEditButton(battery_id, data);
      });
   },
   onRuleEditButton: function(battery_id, data){
      $("#edit_battery_name").val(data.name)
      $("#edit_battery_id").val(battery_id)
      $("#edit_battery_source_url").val(data.source_url)
      if (data.active == true) {
        $("#edit_battery_is_active").prop( "checked", true );
      }
      $('#edit_battery_to_db').modal('show');
   },
   showHideColumns: function(id){
    var column = this.dataTable.columns("." +id);
    if(column.visible()[0] == true){
      column.visible(false);
    }else{
      column.visible(true);
    }
   },
   onBatteryButton: function(){
    $(this.$refs.addmodal).modal("show");
   },
   onHideShowButton: function(){
    $(this.$refs.hideShow).modal("show");
   },
   clearForm: function(){
    this.battery_name = "";
    this.battery_source_url = "";
    this.show_add_errors = false;
   },
   saveModal: function(){
    this.show_loading = true;
    this.show_add_errors = true;


    this.$http.post('/battery/new', {
      name: this.battery_name,
      user_id:  this.user_id,
      source_url: this.battery_source_url,
      user_id:  this.user_id,
      active: this.battery_is_active
    }).then(function (response) {
      Vue.notify({group: 'notify', title: 'Battery has been added'});
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
   updateBattery: function(){
    this.show_loading = true;
    this.show_edit_errors = true;

    var recordID = $("#edit_battery_id").val();

    this.$http.patch('/battery/update', {
      name: $("#name").val(),
      source_url: $("#source_url").val(),
      active: $('#edit_battery_is_active').is(':checked'),
      id: recordID
    }).then(function (response) {
      Vue.notify({group: 'notify', title: 'Device has been updated'});
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
    this.show_edit_errors = false;
    this.edit_battery_name = ""
    this.edit_battery_source_url = ""
   },
    initHideShow: function(){
      $(".rule-column").each(function(){
        var that = $(this).attr("data-id");
        let batteryDataTable = $('#battery-datatable').DataTable();
        var column = batteryDataTable.columns("." +that);
        if(column.visible()[0] == true){
          $(this).prop('checked', true);
        }else{
          $(this).prop('checked', false);
        }
      });
    },
    deleteBattery: function(){
    $(document).off("click").on("click", ".delBattery", function(){
      let recordRow, result;
      recordRow = $(this).closest('tr');
      let recordID = $(this).data("id");

      result = confirm("Are you sure to delete this Battery?");
      if (result === false) {
        return;
      }

      app.$http.delete("/battery/" + recordID, {recordRow: recordRow}).then(function (response) {
        recordRow.remove();
        Vue.notify({group: 'notify', title: 'Battery has been deleted'});
      }).catch(function (error) {
         return false
      });
    });
   },
   active_menu_link: function(){
    $("li").removeClass(" m-menu__item--active");
    $(".batteries").addClass(" m-menu__item--active");
    $("#m_aside_left").removeClass("m-aside-left--on");
    $("body").removeClass("m-aside-left--on");
    $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
   }
  }, // end of methods
   mounted(){
    this.deleteBattery();
    let table = this.initializeTable();
    this.getUniqueIdentifier(table);
    this.initHideShow();
    this.active_menu_link();
   }
}
</script>

<style lang="scss">
</style>
