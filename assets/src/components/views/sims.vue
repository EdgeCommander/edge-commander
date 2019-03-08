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
                                        <input type="text" class="form-control m-input m-input--solid" placeholder="Search..." id="m_form_search" v-model="m_form_search" v-on:keyup="search()" autocomplete="off">
                                        <span class="m-input-icon__icon m-input-icon__icon--left">
                                        <span> <i class="la la-search"></i></span>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4 order-1 order-md-2 m--align-right">
                            <a href="javascript:void(0)"  class="btn btn-primary m-btn m-btn--icon" v-on:click="onSIMButton">
                              <span>
                                  <i class="fa fa-plus-square"></i>
                                  <span>{{form_labels.add_sim_button}}</span>
                              </span>
                            </a>
                            <div href="javascript:void(0)" class="btn btn-default grey"  v-on:click="onSIMHideShowButton">
                                <i class="fa fa-columns"></i>
                            </div>
                        </div>
                    </div>
                </div>
                <!--end: Search Form -->
               <table id="sims-datatable" class="table table-striped  table-hover table-bordered datatable display nowrap" cellspacing="0" width="100%">
                    <thead>
                        <tr>
                            <th v-for="(item, index) in headings">{{item.column}}</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
    </div>
    <!--begin::Modal-->
    <div class="modal fade toggle-datatable-columns" ref="hideShow" style="padding: 0px;" id="m_modal_1" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
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
                            <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;">
                                <input type="checkbox" class="sims-column" v-bind:data-id="item.id" v-on:change="showHideColumns(item.id)"><span></span> {{item.column}}</label>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">{{form_labels.hide_show_button}}</button>
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade add_sim_to_db"  style="padding: 0px;" id="m_modal_add" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
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
                <div class="modal-body" id="body-sim-dis">
                    <img src="../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                    <div id="simErrorDetails" v-if="show_errors">
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
                            <label class="col-3 col-form-label">
                                {{form_labels.name}}
                            </label>
                            <div class="col-9">
                                <input type="text" class="form-control m-input m-input--solid" id="name" placeholder="i.e IIA Airport" v-model="name">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.number}}
                            </label>
                            <div class="col-9">
                                <input type="text" class="form-control m-input m-input--solid" id="number" v-model="number" placeholder="i.e +353xxxxxx">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.sim_provider}}
                            </label>
                            <div class="col-9">
                                <select class="form-control m-input" id="sim_provider" v-model="sim_provider">
                                    <option value="Lyca Mobile (Ireland)">Lyca Mobile (Ireland)</option>
                                    <option value="Vodafone (Ireland)">Vodafone (Ireland)</option>
                                    <option value="Vodafone (UK)">Vodafone (UK)</option>
                                    <option value="Three (UK)">Three (UK)</option>
                                    <option value="O2 (UK)">O2 (UK)</option>
                                    <option value="other">Other</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label other_input">
                                &nbsp;
                            </label>
                            <div class="col-9">
                                <input type="text" class="form-control m-input m-input--solid other_input" id="other_sim_provider" v-model="other_sim_provider" placeholder="Please enter the sim provider name" />
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
     <div class="modal fade" id="edit_nvr_to_db" ref="editmodal" style="padding: 0px;" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog" role="document">
        <div class="modal-content" style="padding: 0px;">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">
                    {{form_labels.edit_title}}
                </h5>
                <div class="cancel">
                  <a href="#" id="discardEditModal" data-dismiss="modal">X</a>
                </div>
            </div>
            <div class="modal-body">
                <img src="../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                 <div v-if="show_edit_errors">
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
                    <input type="hidden" id="edit_sim_id" >
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.name}}
                          </label>
                          <div class="col-9">
                             <input type="text" class="form-control m-input m-input--solid" id="edit_sim_name">
                          </div>
                      </div>
                 </div>
                <!--end::Form-->
            </div>
            <div class="modal-footer">
                <button id="" type="button" class="btn btn-default" v-on:click="updateSim">
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

import * as jquery from 'jquery';
import intlTelInput from 'intl-tel-input'
import '../../assets/css/intlTelInput.css'

import Vue from 'vue'
import moment from "moment";
import sims from './sims.vue';
import App from '../../App.vue'
const app = new Vue(App)

export default {
  name: 'sims',
  data: function(){
    return{
      dataTable: null,
      m_form_search: "",
      show_loading: false,
      show_errors: false,
      show_add_messages: "",
      show_loading: false,
      show_add_errors: false,
      show_edit_errors: false,
      show_edit_messages: "",
      headings: [
        {column: "Action", id: "action"},
        {column: "Number", id: "number"},
        {column: "Name", id: "name"},
        {column: "Status", id: "status"},
        {column: "MB Allowance", id: "allowance"},
        {column: "MB Used (Today)", id: "volume_used"},
        {column: "MB Used (Yest.)", id: "volume_used_yesterday"},
        {column: "% Used", id: "percentage_used"},
        {column: "Remaning Days", id: "remaning_days"},
        {column: "Sim Provider", id: "sim_provider"},
        {column: "Last Reading", id: "last_log_reading_at"},
        {column: "Last Bill Date", id: "last_bill_date"},
        {column: "Last SMS", id: "last_sms"},
        {column: "Last SMS DateTime", id: "last_sms_datetime"},
        {column: "# SMS Since Last Bill", id: "sms_since_last_bill"}
      ],
      form_labels: {
        name: "Name",
        number: "Number",
        sim_provider: "SIM Provider",
        add_title: "Add SIM",
        hide_show_title: "Show/Hide Columns",
        edit_title: "Update Sim",
        add_sim_button: "Add SIM",
        hide_show_button: "OK",
        submit_button: "Save changes"
      },
      name: "",
      number: "",
      sim_provider: "",
      other_sim_provider: "",
      user_id: this.$root.user_id
    }
  },
  methods: {
    initializeTable: function(){
      let simsDataTable = $('#sims-datatable').DataTable({
      fnInitComplete: function(){
        // Enable TFOOT scoll bars
        $('.dataTables_scrollHead').css('overflow', 'auto');
        $('.dataTables_scrollFoot').css('overflow', 'auto');
        // Sync TFOOT scrolling with TBODY
        $('.dataTables_scrollFoot').on('scroll', function () {
          $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
        });
        var offset = $('.dataTables_scrollBody').offset().left - $(window).scrollLeft();
        $('.dataTables_scrollHead').on('scroll', function () {
          $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
          var offset = $('.dataTables_scrollBody').scrollLeft();
          if(offset == 1){
            simsDataTable.columns.adjust().draw()
          }
        });
          simsDataTable.search("").draw();
      },
      ajax: {
      url: "/sims/data/json",
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
        class: "text-center action",
        data: function(row, type, set, meta) {
          return '<div class="action_btn"><div id class="editSim cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div></div>';
        }
      },
      {
        class: "text-left number",
        data: function(row, type, set, meta) {
          let link = "%2B" + row.number;
          return '<a style="color: blue;text-decoration: underline;cursor: pointer; link" href="'+'/sims/'+row.number+'" id="show-morris-graph" data-id="' + row.number + '">' + row.number  + '</a>'
        }
      },
      {
        class: "text-left name",
        data: function(row, type, set, meta) {
          return row.name;
        }
      },
      {
        class: "text-left status",
        data: function(row, type, set, meta) {
          let status = "<span>Not Found.</span>"
          let res = row.last_sms.toLowerCase();
          if (res.indexOf('lost connection') > 1 || res.indexOf('disconnected') > 1 || res.indexOf('shutdown') > 1) {
            status = "<span class='red_text'>Disconnected</span>"
          }else if (res.indexOf('connected') > 1 || res.indexOf('restored') > 1 || res.indexOf('alive') > 1) {
            status = "<span class='green_text'>Connected</span>"
          }else if (res.indexOf('reboot') > 1 || res.indexOf('restart') > 1) {
            status = "<span class='orange_text'>Restarted</span>"
          }
          return status;
        }
      },
      {
        class: "text-center allowance",
        data: function(row, type, set, meta) {
          let allowance = row.allowance
          let addon = row.addon
          if(addon == "Unknown"){
            allowance = "-"
          }else if(allowance == '-1.0'){
            allowance = "Unlimited"
          }
          return allowance;
        }
      },
      {
        class: "text-center volume_used",
        data: function(row, type, set, meta) {
          return row.volume_used;
        }
      },
      {
        class: "text-center volume_used_yesterday",
        data: function(row, type, set, meta) {
          return row.volume_used_yesterday;
        }
      },
      {
        class: "text-center percentage_used",
        data: function(row, type, set, meta) {
          return row.percentage_used;
        }
      },
      {
        class: "text-center remaning_days",
        data: function(row, type, set, meta) {
          let remaning_days = row.remaning_days
          let addon = row.addon
          if(addon == "Unknown"){
            remaning_days = "-"
          }
          return remaning_days;
        }
      },
      {
        class: "text-center sim_provider",
        data: function(row, type, set, meta) {
          return row.sim_provider;
        }
      },
      {
        class: "text-center last_log_reading_at",
        data: function(row, type, set, meta) {
          return moment(row.last_log_reading_at).format('DD-MM-YYYY HH:mm:ss');
        }
      },
      {
        class: "text-center last_bill_date",
        data: function(row, type, set, meta) {
          let last_bill_date;
          last_bill_date = row.last_bill_date
          if(last_bill_date != "-"){
            last_bill_date = moment(row.last_bill_date).format('DD-MM-YYYY');
          }
          return last_bill_date;
        }
      },
      {
        class: "last_sms",
        data: function(row, type, set, meta) {
          return row.last_sms;
        }
      },
      {
        class: "text-center last_sms_date",
        data: function(row, type, set, meta) {
          let last_sms_date = row.last_sms_date
          if(last_sms_date != "-"){
            last_sms_date = moment(row.last_sms_date).format('DD-MM-YYYY HH:mm:ss');
          }
          return last_sms_date;
        }
      },
      {
        class: "text-center sms_since_last_bill",
        data: function(row, type, set, meta) {
          return row.sms_since_last_bill;
        }
      }
      ],
      autoWidth: true,
      info: false,
      bPaginate: false,
      lengthChange: false,
      order: [[ 5, "desc" ]],
      scrollX: true,
      colReorder: true,
      stateSave:  true
    });
    return this.dataTable = simsDataTable;
   },
   search: function(){
    this.dataTable.search(this.m_form_search).draw();
   },
   showHideColumns: function(id){
    var column = this.dataTable.columns("." +id);
    if(column.visible()[0] == true){
      column.visible(false);
    }else{
      column.visible(true);
    }
   },
   onSIMButton: function() {
    this.initializeInput();
    jquery("#m_modal_add").modal("show");
   },
    getUniqueIdentifier: function(simsDataTable){
      $(document).on("click", ".editSim", function(){
        let tr = $(this).closest('tr');
        let row = simsDataTable.row(tr);
        let data = row.data();
        let sim_id = $(this).data("id");
        sims.methods.onSimEditButton(sim_id, data);
      });
    },
    updateSim: function(){
      this.show_loading = true;
      this.show_edit_errors = true;
      let simID = $("#edit_sim_id").val();
      this.$http.patch("/sim/" + simID, {
        name: $("#edit_sim_name").val(),
        id: simID
      }).then(function (response) {
        Vue.notify({group: 'notify', title: 'Sim name has been updated'});
        this.show_loading = false;
        this.dataTable.ajax.reload();
        this.editClearFrom();
        jquery("#edit_nvr_to_db").modal("hide");
      }).catch(function (error) {
        this.show_loading = false;
        this.show_edit_messages = error.body.errors;
        this.show_edit_errors = true;
      });
    },
    editClearFrom: function() {
      this.edit_sim_id = "";
      this.edit_sim_name = "";
      this.show_loading = false;
      this.show_edit_errors = false;
      this.show_edit_messages = "";
    },
    onSimEditButton: function(sim_id, data) {
      $("#edit_sim_id").val(sim_id);
      $("#edit_sim_name").val(data.name);
      jquery('#edit_nvr_to_db').modal('show');
    },
   onSIMHideShowButton: function() {
    jquery(this.$refs.hideShow).modal("show");
   },
   saveModal: function() {
    $('ul#errorOnSIM').html("");
    this.show_loading = true;
    this.show_errors = true;

    var sim_provider = this.sim_provider;
    if(sim_provider == 'other'){
      sim_provider = this.other_sim_provider;
    }

    this.$http.post('/sims', {
        sim_provider: sim_provider,
        number:  this.number,
        name: this.name,
        addon: "Unknown",
        allowance: "-1.0",
        volume_used: "-1.0",
        user_id: this.user_id,
        three_user_id: 0
      }).then(function (response) {
        Vue.notify({group: 'notify', title: 'SIM has been added.'});
        this.show_loading = false;
        this.dataTable.ajax.reload();
        this.clearForm();
        jquery("#m_modal_add").modal("hide");
      }).catch(function (error) {
        this.show_add_messages = error.body.errors;
        this.show_errors = true;
        this.show_loading = false;
      });
   },
   clearForm: function() {
      this.number = "";
      this.name = "";
      this.sim_provider = "";
      this.other_sim_provider = "";
      this.show_add_messages = "";
      this.show_errors = false;
    },
    initializeInput: function() {
      var input = document.querySelector("#number");
      intlTelInput(input,{
        nationalMode: false,
        initialCountry: "ie"
      });

        $('.other_input').css("display","none");
        $('#sim_provider').change(function(){
        if($(this).val() == "other"){
          $('.other_input').css("display","block");
        }else{
          $('.other_input').css("display","none");
        }
      })
    },
    initHideShow: function(){
      $(".sims-column").each(function(){
        let simsDataTable = $('#sims-datatable').DataTable();
        var that = $(this).attr("data-id");
        var column = simsDataTable.columns("." +that);
        if(column.visible()[0] == true){
          $(this).prop('checked', true);
        }else{
          $(this).prop('checked', false);
        }
      });
    },
    active_menu_link: function(){
      $("li").removeClass(" m-menu__item--active");
      $(".sims").addClass(" m-menu__item--active");
      $("#m_aside_left").removeClass("m-aside-left--on");
      $("body").removeClass("m-aside-left--on");
      $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
    }
  }, // end of methods
  mounted(){
    let table = this.initializeTable();
    this.getUniqueIdentifier(table);
    this.initHideShow();
    this.active_menu_link();
  }
}
</script>
<style lang="scss">
</style>
