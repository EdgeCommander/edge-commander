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
            <table id="data-table" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
            <thead>
                <tr>
                    <th v-for="(item, index) in headings" v-bind:class="item.class">{{item.column}}</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="record in table_records">
                  <td class="text-center actions">
                    <div class="cursor_to_pointer fa fa-edit" v-on:click="onRuleEditButton(record)"></div>
                    <div class="cursor_to_pointer fa fa-trash" v-on:click="deleteRule(record.id, $event)"></div>
                  </td>
                  <td class="rule_name">{{record.rule_name}}</td>
                  <td class="text-center active">{{record.active}}</td>
                  <td class="text-center category">{{record.category}}</td>
                  <td class="recipients">
                    <span v-for="(recipient, index) in record.recipients">
                      <span>{{recipient}}</span><span v-if="index+1 < record.recipients.length">, </span>
                    </span>
                </td>
                  <td class="text-center created_at">{{record.created_at | formatDate}}</td>
                </tr>
              </tbody>
          </table>
        </div>
      </div>
    </div>
    <!-- begin::modal -->
    <div class="modal fade add_rule_to_db" ref="addmodal" style="padding: 0px;" id="m_modal_1" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
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
              <div class="modal-body" id="body-rule-dis">
                  <img src="/images/loading.gif" id="api-wait" v-if="show_loading">
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
                      <input type="hidden" id="user_id"  v-model="user_id">
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.name}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="rule_name" aria-describedby="emailHelp" placeholder="Test Usage." v-model="rule_name">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.category}}
                          </label>
                          <div class="col-9">
                              <select class="form-control m-input" id="rule_category" v-model="rule_category">
                                  <option value="usage_command">Internet usage > 90%</option>
                                  <option value="daily_sms_usage_command">Daily SMS > 6</option>
                                  <option value="monthly_sms_usage_command">Monthy SMS > 190</option>
                              </select>
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.recipients}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="rule_recipients" aria-describedby="emailHelp" placeholder="test@user.com,who@am.io" v-model="rule_recipients">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                          </label>
                          <div class="col-9">
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
              <div class="modal-body" id="body-rule-edit-dis">
                  <img src="/images/loading.gif" id="api-wait"  v-if="show_loading">
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
                      <input type="hidden" id="user_id"  v-model="user_id">
                      <input type="hidden" id="edit_rule_id" v-model="edit_rule_id">
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.name}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="edit_rule_name" aria-describedby="emailHelp" placeholder="Test Usage." v-model="edit_rule_name">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.category}}
                          </label>
                          <div class="col-9">
                              <select class="form-control m-input" id="edit_rule_category" v-model="edit_rule_category">
                                  <option value="usage_command">Internet usage > 90%</option>
                                  <option value="daily_sms_usage_command">Daily SMS > 6</option>
                                  <option value="monthly_sms_usage_command">Monthy SMS > 190</option>
                              </select>
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.recipients}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="edit_rule_recipients" v-model="edit_rule_recipients" aria-describedby="emailHelp" placeholder="test@user.com,who@am.io">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                          </label>
                          <div class="col-9">
                              <label class="m-checkbox">
                                  <input type="checkbox" id="edit_rule_is_active" v-model="edit_rule_is_active">
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
                    <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;"><input type="checkbox" class="users-column" checked="checked" v-bind:id="index" v-bind:name="item.id" v-on:change="showHideColumns(index)"><span></span> {{item.column}}</label>
                  </div>
                </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-default" data-dismiss="modal">{{form_labels.hide_show_button}}</button>
            </div>
        </div>
    </div>
  </div>
  <!--end::Modal-->
  </div>
</template>

<script>
module.exports = {
  name: 'commands',
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
      headings: [
        {column: "Actions", id: "actions", class: "text-center"},
        {column: "Rule Name", id: "rule_name"},
        {column: "Active", id: "active", class: "text-center"},
        {column: "Category", id: "category", class: "text-center"},
        {column: "Recipients", id: "recipients"},
        {column: "Created At", id: "created_at", class: "text-center"}
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
      edit_rule_recipients: "",
      edit_rule_is_active: false,
      rule_name: "",
      rule_category: "",
      rule_recipients: "",
      rule_is_active: false,
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
      this.$http.get('/rules').then(
        response => {
          this.table_records = response.body.rules
          $("#data-table .dataTables_empty").hide();
        }).catch(function(error){
        console.log(error)
      })
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
      recipients: recipients,
      is_active: this.rule_is_active
    }).then(function (response) {
      $.notify({message: 'Rule has been added.'},{type: 'info'});
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
   deleteRule: function(ruleID, event){
      let ruleRow, result;
      ruleRow = event.target.parentElement.parentElement
      result = confirm("Are you sure to delete this rule?");
      if (result === false) {
        return;
      }
      let data = {};
      data.id = ruleID;
      this.$http.delete("/rules/" + ruleID, {ruleRow: ruleRow}).then(function (response) {
        ruleRow.remove();
        $.notify({message: 'Rule has been deleted.'},{type: 'info'});
      }).catch(function (error) {
         return false
      });
   },
   clearForm: function(){
    this.rule_name = "";
    this.rule_category = "";
    this.rule_recipients = "";
    this.rule_is_active = false;
    this.show_add_errors = false;
   },
   onRuleEditButton: function(data){
    this.edit_rule_id = data.id
    this.edit_rule_name = data.rule_name
    this.edit_rule_category = data.category
    this.edit_rule_recipients = data.recipients
    this.edit_rule_is_active = data.active
    $(this.$refs.editmodal).modal("show");
   },
   updateRule: function(){
    this.show_loading = true;
    this.show_edit_errors = true;

    var ruleID = this.edit_rule_id;

    let recipients = this.edit_rule_recipients;
    if (recipients != "") {
      recipients = recipients;
    }else{
      recipients = "";
    }

    this.$http.patch('/rules/update', {
      rule_name: this.edit_rule_name,
      category: this.edit_rule_category,
      recipients: recipients,
      active: this.edit_rule_is_active,
      id: ruleID
    }).then(function (response) {
      $.notify({message: 'Rule has been updated.'},{type: 'info'});
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
    this.show_edit_messages = "";
    this.show_edit_errors = false;
    this.edit_rule_name = ""
    this.edit_rule_recipients = ""
    this.edit_rule_is_active = false
   },
   search: function(){
    this.dataTable.search(this.m_form_search).draw();
   },
    onRuleButton: function(){
      $(this.$refs.addmodal).modal("show");
    },
    get_session: function(){
      this.$http.get('/get_porfile').then(response => {
        this.user_id = response.body.id;
      });
    },
    onRuleHideShowButton: function(){
      $(this.$refs.hideShow).modal("show");
    },
    showHideColumns: function(id){
    let column = this.dataTable.columns(id);
    if(column.visible()[0] == true){
      column.visible(false);
    }else{
      column.visible(true);
    }
   }
  },
  created() {
    this.initDatatable();
  },
  mounted(){
    this.get_session();
  },
  updated(){
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
  }
}
</script>

<style lang="scss">
</style>
