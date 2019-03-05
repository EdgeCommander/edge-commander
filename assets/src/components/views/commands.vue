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
                 <a href="javascript:void(0)" id="addRULE" class="btn btn-primary m-btn m-btn--icon" v-on:click="onRuleButton">
                      <span>
                          <i class="fa fa-plus-square"></i>
                          <span>
                              {{form_labels.add_rule_button}}
                          </span>
                      </span>
                  </a>
                  <div href="javascript:void(0)" class="btn btn-default grey" v-on:click="onRuleHideShowButton">
                    <i class="fa fa-columns"></i>
                  </div>
              </div>
            </div>
          </div>
          <!--end: Search Form -->
          <div>
          </div>
            <table id="commands-datatable" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
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
                                <input type="text" class="form-control m-input m-input--solid" id="rule_name" aria-describedby="emailHelp" placeholder="Test Usage." v-model="rule_name">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.category}}
                            </label>
                            <div class="col-4">
                                <select class="form-control m-input" id="rule_category" v-model="rule_category" style="height: 33px !important;">
                                    <option value="usage_command">Internet usage in %</option>
                                    <option value="daily_sms_usage_command">Total SMS in a day</option>
                                    <option value="monthly_sms_usage_command">Total SMS in a monthly</option>
                                    <option value="battery_voltages_command">Battery voltage in volts</option>
                                </select>
                            </div>
                            <div class="col-4">
                              <select class="form-control m-input" id="rule_variable" v-model="rule_variable" style="height: 33px !important;">
                                <option value="greater_than">Greater than (>)</option>
                                <option value="greater_than_equal_to">Greater than or equal to (>=)</option>
                                <option value="less_than">Less than (<)</option>
                                <option value="less_than_equal_to">Less than or equal to (<=)</option>
                                <option value="equals_to">Equals to (==)</option>
                              </select>
                            </div>
                            <div class="col-2">
                              <input type="number" min="0" class="form-control m-input m-input--solid" id="rule_value"  aria-describedby="emailHelp" placeholder="10" v-model="rule_value">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.recipients}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="rule_recipients" aria-describedby="emailHelp" placeholder="test@user.com,who@am.io" v-model="rule_recipients">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                            </label>
                            <div class="col-10">
                                <label class="m-checkbox">
                                    <input type="checkbox" id="rule_is_active" v-model="rule_is_active">
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
    <div class="modal fade" id="edit_rule_to_db" ref="editmodal" style="padding: 0px;" data-backdrop="static" data-keyboard="false">
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
                        <input type="hidden" id="edit_rule_id" >
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.name}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="edit_rule_name" aria-describedby="emailHelp" placeholder="Test Usage.">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.category}}
                            </label>
                            <div class="col-4">
                                <select class="form-control m-input" id="edit_rule_category" style="height: 33px !important;">
                                    <option value="usage_command">Internet usage in %</option>
                                    <option value="daily_sms_usage_command">Total SMS in a day</option>
                                    <option value="monthly_sms_usage_command">Total SMS in a monthly</option>
                                    <option value="battery_voltages_command">Battery voltage in volts</option>
                                </select>
                            </div>
                            <div class="col-4">
                              <select class="form-control m-input" id="edit_rule_variable"  style="height: 33px !important;">
                                <option value="greater_than">Greater than (>)</option>
                                <option value="greater_than_equal_to">Greater than or equal to (>=)</option>
                                <option value="less_than">Less than (<)</option>
                                <option value="less_than_equal_to">Less than or equal to (<=)</option>
                                <option value="equals_to">Equals to (==)</option>
                              </select>
                            </div>
                            <div class="col-2">
                              <input type="number" min="0" class="form-control m-input m-input--solid" id="edit_rule_value"  aria-describedby="emailHelp" placeholder="10">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.recipients}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="edit_rule_recipients"aria-describedby="emailHelp" placeholder="test@user.com,who@am.io">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                            </label>
                            <div class="col-10">
                                <label class="m-checkbox">
                                    <input type="checkbox" id="edit_rule_is_active">
                                    {{form_labels.status}}
                                    <span></span>
                                </label>
                            </div>
                        </div>
                    </div>
                    <!--end::Form-->
                </div>
                <div class="modal-footer" style="padding: 11px;">
                    <button id="" type="button" class="btn btn-default" v-on:click="updateRule">
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
import commands from './commands.vue'
import App from '../../App.vue'
const app = new Vue(App)

export default {
  name: 'commands',
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
        {column: "Rule Name", visible: "checked", id: "rule_name"},
        {column: "Active", visible: "checked", id: "active"},
        {column: "Category", id: "category"},
        {column: "Variable", id: "variable"},
        {column: "Value", id: "value"},
        {column: "Recipients", visible: "checked", id: "recipients"},
        {column: "Created At", visible: "checked", id: "created_at"}
      ],
      form_labels: {
        name: "Rule Name",
        category: "Category",
        recipients: "Recipients",
        status: "Active",
        submit_button: "Save changes",
        edit_title: "Edit Rule",
        add_title: "Add Rule",
        hide_show_title: "Show/Hide Columns",
        add_rule_button: "Add Rule",
        hide_show_button: "OK"
      },
      edit_rule_name: "",
      edit_rule_id: "",
      edit_rule_category: "",
      edit_rule_variable: "",
      edit_rule_value: "",
      edit_rule_recipients: "",
      edit_rule_is_active: false,
      rule_name: "",
      rule_category: "",
      rule_variable: "",
      rule_value: "",
      rule_recipients: "",
      rule_is_active: false,
      user_id: this.$root.user_id
    }
  },
  methods: {
    initializeTable: function(){
      let commandsDataTable = $('#commands-datatable').DataTable({
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
        commandsDataTable.search("").draw();
      },
      ajax: {
      url: "/rules",
        dataSrc: function(data) {
          return data.rules;
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
          return '<div id="action_btn"><div class="editRULE cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="cursor_to_pointer fa fa-trash delRule" data-id="'+ row.id +'"></div></div>';
        }
      },
      {
        class: "rule_name",
        data: function(row, type, set, meta) {
          return row.rule_name;
        }
      },
      {
        class: "text-center active",
        data: function(row, type, set, meta) {
          return row.active;
        }
      },
      {
        class: "text-center category",
        visible: false,
        data: function(row, type, set, meta) {
          return row.category;
        }
      },
      {
        class: "text-center variable",
        visible: false,
        data: function(row, type, set, meta) {
          return row.variable;
        }
      },
      {
        class: "text-center value",
        visible: false,
        data: function(row, type, set, meta) {
          return row.value;
        }
      },
      {
        class: "recipients",
        data: function(row, type, set, meta) {
          return row.recipients;
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
      return this.dataTable = commandsDataTable;
   },
   search: function(){
      this.dataTable.search(this.m_form_search).draw();
   },
   getUniqueIdentifier: function(commandsDataTable){
      $(document).on("click", ".editRULE", function(){
        var tr = $(this).closest('tr');
        var row = commandsDataTable.row(tr);
        var data = row.data();
        let rule_id = $(this).data("id");
        commands.methods.onRuleEditButton(rule_id, data);
      });
   },
   onRuleEditButton: function(rule_id, data){
      $("#edit_rule_name").val(data.rule_name)
      $("#edit_rule_id").val(rule_id)
      $("#edit_rule_category").val(data.category)
      $("#edit_rule_variable").val(data.variable)
      $("#edit_rule_value").val(data.value)
      $("#edit_rule_recipients").val(data.recipients)
      if (data.active == true) {
        $("#edit_rule_is_active").prop( "checked", true );
      }
      $('#edit_rule_to_db').modal('show');
   },
   showHideColumns: function(id){
    var column = this.dataTable.columns("." +id);
    if(column.visible()[0] == true){
      column.visible(false);
    }else{
      column.visible(true);
    }
   },
   onRuleButton: function(){
    $(this.$refs.addmodal).modal("show");
   },
   onRuleHideShowButton: function(){
    $(this.$refs.hideShow).modal("show");
   },
   clearForm: function(){
    this.rule_name = "";
    this.rule_category = "";
    this.rule_variable = "";
    this.rule_value = "";
    this.rule_recipients = "";
    this.rule_is_active = false;
    this.show_add_errors = false;
   },
   saveModal: function(){
    this.show_loading = true;
    this.show_add_errors = true;

    let recipients = this.rule_recipients
    if (recipients != "") {
      recipients = recipients.split(",");
    }else{
      recipients = "";
    }

    this.$http.post('/rules/new', {
      rule_name: this.rule_name,
      user_id:  this.user_id,
      category: this.rule_category,
      variable: this.rule_variable,
      value: this.rule_value,
      recipients: recipients,
      is_active: this.rule_is_active
    }).then(function (response) {
      Vue.notify({group: 'notify', title: 'Rule has been added'});
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
   updateRule: function(){
    this.show_loading = true;
    this.show_edit_errors = true;

    var ruleID = $("#edit_rule_id").val();

    let recipients = $("#edit_rule_recipients").val();
    if (recipients != "") {
        recipients = recipients.split(",");
    }else{
      recipients = "";
    }

    this.$http.patch('/rules/update', {
      rule_name: $("#edit_rule_name").val(),
      category: $("#edit_rule_category").val(),
      variable: $("#edit_rule_variable").val(),
      value: $("#edit_rule_value").val(),
      recipients: recipients,
      active: $('#edit_rule_is_active').is(':checked'),
      id: ruleID
    }).then(function (response) {
      Vue.notify({group: 'notify', title: 'Rule has been updated'});
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
    this.edit_rule_name = ""
    this.edit_rule_recipients = ""
    this.edit_rule_is_active = false
   },
    initHideShow: function(){
      $(".rule-column").each(function(){
        var that = $(this).attr("data-id");
        let commandsDataTable = $('#commands-datatable').DataTable();
        var column = commandsDataTable.columns("." +that);
        if(column.visible()[0] == true){
          $(this).prop('checked', true);
        }else{
          $(this).prop('checked', false);
        }
      });
    },
    deleteRule: function(){
    $(document).off("click").on("click", ".delRule", function(){
      let ruleRow, result;
      ruleRow = $(this).closest('tr');
      let ruleID = $(this).data("id");

      result = confirm("Are you sure to delete this Rule?");
      if (result === false) {
        return;
      }

      app.$http.delete("/rules/" + ruleID, {ruleRow: ruleRow}).then(function (response) {
        ruleRow.remove();
        Vue.notify({group: 'notify', title: 'Rule has been deleted'});
      }).catch(function (error) {
         return false
      });
    });
   },
   active_menu_link: function(){
    $("li").removeClass(" m-menu__item--active");
    $(".commands").addClass(" m-menu__item--active");
    $("#m_aside_left").removeClass("m-aside-left--on");
    $("body").removeClass("m-aside-left--on");
    $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
   }
  }, // end of methods
   mounted(){
    this.deleteRule();
    let table = this.initializeTable();
    this.getUniqueIdentifier(table);
    this.initHideShow();
    this.active_menu_link();
   }
}
</script>

<style lang="scss">
</style>
