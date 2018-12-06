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
                <div class="col-md-4 order-1 order-md-2 m--align-right" style="padding-right: 0">
                  <div class="row">
                    <div class="col-sm-9">
                         <div class="form-group m-form__group row">
                        <label class="col-lg-2 col-form-label">
                            Date:
                        </label>
                        <div class="col-lg-10" style="padding-right: 0">
                            <input type="text" class="form-control m-input m-input--solid" id="m_sms_datepicker">
                        </div>
                        </div>
                    </div>
                    <div class="col-lg-2" style="padding-right: 0">
                      <div href="javascript:void(0)" class="btn btn-default grey" v-on:click="onHideShowButton">
                        <i class="fa fa-columns"></i>
                      </div>
                    </div>
                  </div>
              </div>
            </div>
          </div>
          <!--end: Search Form -->
          <div>
          </div>
            <table id="status-datatable" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
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
                    <a href="#" id="discardModal" data-dismiss="modal">X</a>
                  </div>
              </div>
              <div class="modal-body" id="body-sim-dis">
                  <div class="form-group">
                    <div class="column-checkbox" v-for="(item, index) in headings">
                        <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;"><input type="checkbox" class="rule-column" v-bind:data-id="item.id" v-on:change="showHideColumns(item.id)"><span></span> {{item.column}}</label>
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
import Vue from 'vue'
import App from './App.vue'
const app = new Vue(App)

module.exports = {
  name: 'battery_status',
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
        {column: "Reading DateTime", id: "datetime"},
        {column: "Battery voltage", id: "voltage"},
        {column: "Battery current", id: "i_value"},
        {column: "Panel voltage", id: "vpv_value"},
        {column: "Panel power", id: "ppv_value"},
        {column: "Serial#", id: "serial_no"},
        {column: "State of operation", id: "cs_value"},
        {column: "Error code", id: "err_value"},
        {column: "Yield total", id: "h19_value"},
        {column: "Yield today", id: "h20_value"},
        {column: "Maximum power today", id: "h21_value"},
        {column: "Yield yesterday", id: "h22_value"},
        {column: "Maximum power yesterday", id: "h23_value"}
      ],
      form_labels: {
        hide_show_title: "Show/Hide Columns",
        hide_show_button: "OK"
      }
    }
  },
  methods: {
    initializeTable: function(){
      $( "#m_sms_datepicker").datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date(new Date().getTime()));
      let date = $("#m_sms_datepicker").val();

      let statusDataTable = $('#status-datatable').DataTable({
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
      url: "/battery/data/"+date,
        dataSrc: function(data) {
          return data.records;
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
        class: "text-center datetime",
        data: function(row, type, set, meta) {
          return row.datetime;
        }
      },
      {
        class: "text-center voltage",
        data: function(row, type, set, meta) {
          return row.voltage;
        }
      },
      {
        class: "text-center i_value",
        data: function(row, type, set, meta) {
          return row.i_value;
        }
      },
      {
        class: "text-center vpv_value",
        data: function(row, type, set, meta) {
          return row.vpv_value;
        }
      },
      {
        class: "text-center ppv_value",
        data: function(row, type, set, meta) {
          return row.ppv_value;
        }
      },
      {
        class: "text-center serial_no",
        data: function(row, type, set, meta) {
          return row.serial_no;
        }
      },
      {
        class: "text-center cs_value",
        data: function(row, type, set, meta) {
          return row.cs_value;
        }
      },
      {
        class: "text-center err_value",
        data: function(row, type, set, meta) {
          return row.err_value;
        }
      },
      {
        class: "text-center h19_value",
        data: function(row, type, set, meta) {
          return row.h19_value;
        }
      },
      {
        class: "text-center h20_value",
        data: function(row, type, set, meta) {
          return row.h20_value;
        }
      },
      {
        class: "text-center h21_value",
        data: function(row, type, set, meta) {
          return row.h21_value;
        }
      },
      {
        class: "text-center h22_value",
        data: function(row, type, set, meta) {
          return row.h22_value;
        }
      },
      {
        class: "text-center h23_value",
        data: function(row, type, set, meta) {
          return row.h23_value;
        }
      },
      ],
      autoWidth: true,
      info: false,
      bPaginate: false,
      lengthChange: false,
      scrollX: true,
      colReorder: true,
      stateSave:  true,
      order: [[ 0, "desc" ]]
    });
      return this.dataTable = statusDataTable;
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
   onHideShowButton: function(){
    $(this.$refs.hideShow).modal("show");
   },
    initHideShow: function(){
      $(".rule-column").each(function(){
        var that = $(this).attr("data-id");
        let statusDataTable = $('#status-datatable').DataTable();
        var column = statusDataTable.columns("." +that);
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
   active_menu_link: function(){
    $("li").removeClass(" m-menu__item--active");
    $(".status").addClass(" m-menu__item--active");
    $("#m_aside_left").removeClass("m-aside-left--on");
    $("body").removeClass("m-aside-left--on");
    $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
   },
   dateFilterInitialize: function() {
      let table_data = this.dataTable;
      $('#m_sms_datepicker').change(function(){
        let date = $("#m_sms_datepicker").val()
          let new_url = "/battery/data/" + date
          table_data.ajax.url(new_url).load();
      });
    }
  }, // end of methods
   mounted(){
    this.initializeTable();
    this.dateFilterInitialize();
    this.search();
    this.get_session();
    this.initHideShow();
    this.active_menu_link();
   }
}
</script>

<style lang="scss">
</style>
