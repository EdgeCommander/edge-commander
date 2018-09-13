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
    <div class="modal fade add_sim_to_db" ref="addmodal" style="padding: 0px;" id="m_modal_add" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
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
                    <img src="/images/loading.gif" id="api-wait" v-if="show_loading">
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
    <!--end::Modal-->
</div>
</template>

<script>
import Vue from 'vue'
import App from './App.vue'
const app = new Vue(App)

module.exports = {
  name: 'sims',
  data: function(){
    return{
      dataTable: null,
      m_form_search: "",
      show_loading: false,
      show_errors: false,
      show_add_messages: "",
      headings: [
        {column: "Number", id: "number"},
        {column: "Name", id: "name"},
        {column: "Status", id: "status"},
        {column: "MB Allowance", id: "allowance"},
        {column: "MB Used (Today)", id: "mb_used_today"},
        {column: "MB Used (Yest.)", id: "mb_used_yesterday"},
        {column: "% Used", id: "mb_used_percentage"},
        {column: "Remaning Days", id: "remaning_days"},
        {column: "Sim Provider", id: "sim_provider"},
        {column: "Last Reading", id: "last_reading"},
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
        add_sim_button: "Add SIM",
        hide_show_button: "OK",
        submit_button: "Save changes"
      },
      name: "",
      number: "",
      sim_provider: "",
      other_sim_provider: "",
      user_id: ""
    }
  },
  methods: {
    initializeTable: function(){
      let simsDataTable = $('#sims-datatable').DataTable({
      fnInitComplete: function(){
          // Enable TFOOT scoll bars
          $('.dataTables_scrollFoot').css('overflow', 'auto');
          $('.dataTables_scrollHead').css('overflow', 'auto');
          // Sync TFOOT scrolling with TBODY
          $('.dataTables_scrollFoot').on('scroll', function () {
          $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
            simsDataTable.columns.adjust().draw();
          });
          $('.dataTables_scrollHead').on('scroll', function () {
            $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
            simsDataTable.columns.adjust().draw();
          });
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
          return row.last_sms;
        },
        createdCell: function (td, cellData, rowData, row, col) {
          let number = rowData.number
          if (cellData == "Loading....") {
            $.get( "/sms/last/"+number+"/", function(data) {
              let status = "Not Found."
              let str = data.sms.last_sms
              let res = str.toLowerCase();

              if (res.indexOf('lost connection') > 1 || res.indexOf('disconnected') > 1 || res.indexOf('shutdown') > 1) {
                status = "<span class='red_text'>Disconnected</span>"
              }else if (res.indexOf('connected') > 1 || res.indexOf('restored') > 1 || res.indexOf('alive') > 1) {
                status = "<span class='green_text'>Connected</span>"
              }else if (res.indexOf('reboot') > 1 || res.indexOf('restart') > 1) {
                status = "<span class='orange_text'>Restarted</span>"
              }
              $(td).html(status)
            });
          }
        }
      },
      {
        class: "text-center allowance",
        data: function(row, type, set, meta) {
          let allowance_value;
          allowance_value = row.allowance_in_number
          if (allowance_value == -1.0) {
            allowance_value = "Unlimited";
          }
          return allowance_value;
        }
      },
      {
        class: "text-center mb_used_today",
        data: function(row, type, set, meta) {
          let allowance_value, current_in_number;
          allowance_value = row.allowance_in_number
          current_in_number = row.current_in_number
          if (allowance_value == -1.0) {
            current_in_number = "-";
          }
          return current_in_number;
        }
      },
      {
        class: "text-center mb_used_yesterday",
        data: function(row, type, set, meta) {
         let allowance_value, yesterday_in_number;
         allowance_value = row.allowance_in_number
          yesterday_in_number = row.yesterday_in_number
          if (allowance_value == -1.0) {
            yesterday_in_number = "-";
          }
          return yesterday_in_number;
        }
      },
      {
        class: "text-center mb_used_percentage",
        data: function(row, type, set, meta) {
          let allowance_value, percentage_used;
          allowance_value = row.allowance_in_number
          percentage_used = row.percentage_used
          if (allowance_value == -1.0) {
            percentage_used = "-";
          }
          return percentage_used;
        }
      },
      {
        class: "text-center remaning_days",
        data: function(row, type, set, meta) {
          let value;
          var days_left = (row.allowance_in_number - row.current_in_number) / (row.current_in_number - row.yesterday_in_number)
          value =  Math.round(days_left * 100) / 100;
          if (row.current_in_number == 0){
            value = "Infinity";
          }
          return value;
        }
      },
      {
        class: "text-center sim_provider",
        data: function(row, type, set, meta) {
          return row.sim_provider;
        }
      },
      {
        class: "text-center last_reading",
        data: function(row, type, set, meta) {
          return moment(row.date_of_use).format('DD/MM/YYYY HH:mm:ss');
        }
      },
      {
        class: "text-center last_bill_date",
        data: function(row, type, set, meta) {
          let last_bill_date;
          last_bill_date = row.last_bill_date
          if(last_bill_date == null){
            return "-"
          }else{
            return moment(row.last_bill_date).format('DD/MM/YYYY');
          }
        }
      },
      {
        class: "last_sms",
        data: function(row, type, set, meta) {
          return row.last_sms;
        },
        createdCell: function (td, cellData, rowData, row, col) {
          let number = rowData.number
          if (cellData == "Loading....") {
            $.get( "/sms/last/"+number+"/", function(data) {
              let resize = false;
              if(resize == false){
                simsDataTable.draw();
                resize = true;
              }
              $(td).html(data.sms.last_sms)
            });
          }
        }
      },
      {
        class: "text-center last_sms_datetime",
        data: function(row, type, set, meta) {
          let last_sms_date = row.last_sms_date
          return last_sms_date
        },
        createdCell: function (td, cellData, rowData, row, col) {
          let date_value;
          let number = rowData.number
          if (cellData == "Loading....") {
            $.get( "/sms/last/"+number+"/", function(data) {
              let last_sms_date = data.sms.last_sms_date
              if (last_sms_date == '-') {
                  date_value = last_sms_date
              }else{
               date_value = moment(last_sms_date).format('DD/MM/YYYY HH:mm:ss');
              }
              $(td).html(date_value)
            });
          }
        }
      },
      {
        class: "text-center sms_since_last_bill",
        data: function(row, type, set, meta) {
          return row.total_sms_send;
        },
        createdCell: function (td, cellData, rowData, row, col) {
          let bill_day = rowData.bill_day
          let number = rowData.number
          if (cellData == "Loading....") {
            $.get( "/sims/"+number+"/"+bill_day, function(data) {
              $(td).html(data.result)
            });
          }
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
    this.dataTable = simsDataTable;
    this.dataTable.search("");
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
    $(this.$refs.addmodal).modal("show");
   },
   onSIMHideShowButton: function() {
    $(this.$refs.hideShow).modal("show");
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
        allowance: "0",
        volume_used: "0",
        user_id: this.user_id,
        three_user_id: 0
      }).then(function (response) {
        app.$notify({group: 'notify', title: 'SIM has been added.'});
        this.show_loading = false;
        this.dataTable.ajax.reload();
        this.clearForm();
        $(this.$refs.addmodal).modal("hide");
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
    get_session: function(){
      this.$http.get('/get_porfile').then(response => {
        this.user_id = response.body.id;
      });
    },
    initializeInput: function() {
      $("#number").intlTelInput({
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
    select_menu_link: function(){
      $("li").removeClass(" m-menu__item--active");
      $(".sims").addClass(" m-menu__item--active");
    }
  }, // end of methods
  mounted(){
    this.initializeTable();
    this.get_session();
    this.initHideShow();
    this.select_menu_link();
  }
}
</script>
<style lang="scss">
</style>
