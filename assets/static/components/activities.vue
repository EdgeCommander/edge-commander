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
                            <router-link v-bind:to="'/three_users'" class="nav-link">Three Users</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/activities'" class="nav-link active show">Activities</router-link>
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
          <div class="heading_panel">
            <div class="pull-left">
              <h4>Activity Logs <i class="fa fa-long-arrow-right"></i></h4>
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
</template>

<script>
import Vue from 'vue'
import App from './App.vue'
const app = new Vue(App)

module.exports = {
  name: 'activities',
  data: function(){
    return{
      table_records: '',
      dataTable: null,
      sharing_dataTable: null,
      logsDataTable: null,
      add_button_label: "Add New",
      headings_logs: [
        {column: "Browser", id: "browser"},
        {column: "IP address", id: "ip_address"},
        {column: "Country", id: "country", class: "text-center"},
        {column: "Date & Time", id: "created_at", class: "text-center"},
        {column: "Event", id: "created_at"}
      ],
      user_id: this.$root.user_id
    }
  },
  methods: {
    date_format: function(id){
      let string = $("#" + id).val().split("-")
      return string[2] +"-"+ string[1]  +"-"+ string[0]
    },
    initializeLogsTable: function(){
      $("#m_sms_datepicker_from").datepicker({autoclose:true, dateFormat:"dd-mm-yy"}).datepicker("setDate", new Date(new Date().getTime() - (48 * 60 * 60 * 1000)));
      $("#m_sms_datepicker_to").datepicker({autoclose:true, dateFormat:"dd-mm-yy"}).datepicker("setDate", new Date());

      let from_date = this.date_format("m_sms_datepicker_from");
      let to_date = this.date_format("m_sms_datepicker_to");

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
          return moment(row.inserted_at).format('DD-MM-YYYY HH:mm:ss');
        }
      },
      {
        class: "text-left event",
        data: function(row, type, set, meta) {
          return row.event;
        }
      }
      ],
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
   dateFilterInitialize: function() {
    let table_data = this.logsDataTable;
    $('#m_sms_datepicker_from, #m_sms_datepicker_to').change(function(){
      let from_date = module.exports.methods.date_format("m_sms_datepicker_from");
      let to_date = module.exports.methods.date_format("m_sms_datepicker_to");
      let new_url = "/user_logs/" + from_date + "/" + to_date
      table_data.ajax.url(new_url).load();
    });
   },
   active_menu_link: function(){
    $("li").removeClass(" m-menu__item--active");
    $(".settings").addClass(" m-menu__item--active");
    $("#m_aside_left").removeClass("m-aside-left--on");
    $("body").removeClass("m-aside-left--on");
    $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
   }
  },
  mounted(){
    this.active_menu_link();
    this.initializeLogsTable();
    this.dateFilterInitialize();
  }
}
</script>

<style lang="scss">
</style>
