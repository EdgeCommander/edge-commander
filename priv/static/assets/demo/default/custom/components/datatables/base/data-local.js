var vm = new Vue({
  el: '#sims_main',
  data: {
    dataTable: null,
    m_form_search: "",
    show_loading: false,
    show_errors: false,
    headings: [
      {column: "Number", id: "number"},
      {column: "Name", id: "name"},
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
  },
  methods: {
    initializeTable: function(){
      simsDataTable = $('#sims-datatable').DataTable({
      fnInitComplete: function(){
          // Enable TFOOT scoll bars
          $('.dataTables_scrollFoot').css('overflow', 'auto');
          $('.dataTables_scrollHead').css('overflow', 'auto');
          // Sync TFOOT scrolling with TBODY
          $('.dataTables_scrollFoot').on('scroll', function () {
          $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
              vm.dataTable.columns.adjust().draw();
          });
          $('.dataTables_scrollHead').on('scroll', function () {
            $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
              vm.dataTable.columns.adjust().draw();
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
          link = "%2B" + row.number;
          return '<a style="color: blue;text-decoration: underline;cursor: pointer;" href="javascript:void(0)" onclick="load_page(\'/sims/\' '+ row.number+')" id="show-morris-graph" data-id="' + row.number + '">' + row.number  + '</a>'
        }
      },
      {
        class: "text-left name",
        data: function(row, type, set, meta) {
          return row.name;
        }
      },
      {
        class: "text-center allowance",
        data: function(row, type, set, meta) {
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
          return moment(row.date_of_use).format('MMMM Do YYYY, H:mm:ss');
        }
      },
      {
        class: "text-center last_bill_date",
        data: function(row, type, set, meta) {
          last_bill_date = row.last_bill_date
          if(last_bill_date == null){
            return "-"
          }else{
            return moment(row.last_bill_date).format('MMMM Do YYYY');
          }
        }
      },
      {
        class: "last_sms",
        data: function(row, type, set, meta) {
          return row.last_sms;
        },
        createdCell: function (td, cellData, rowData, row, col) {
          number = rowData.number
          if (cellData == "Processing") {
            $.get( "/sms/last/"+number+"/", function(data) {
              $(td).html(data.sms.last_sms)
            });
          }
        }
      },
      {
        class: "text-center last_sms_datetime",
        data: function(row, type, set, meta) {
          last_sms_date = row.last_sms_date
          return last_sms_date
        },
        createdCell: function (td, cellData, rowData, row, col) {
          number = rowData.number
          if (cellData == "Processing") {
            $.get( "/sms/last/"+number+"/", function(data) {
              last_sms_date = data.sms.last_sms_date
              if (last_sms_date == '-') {
                  date_value = last_sms_date
              }else{
               date_value = moment(last_sms_date).format('MMMM Do YYYY, H:mm:ss');
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
          bill_day = rowData.bill_day
          number = rowData.number
          if (cellData == "Processing") {
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
    this.resizeScreen();
   },
   sendAJAXRequest: function(settings) {
    var headers, token, xhrRequestChangeMonth;
    token = $('meta[name="csrf-token"]');
    if (token.length > 0) {
      headers = {
      "X-CSRF-Token": token.attr("content")
      };
      settings.headers = headers;
    }
    return xhrRequestChangeMonth = jQuery.ajax(settings);
   },
   onSIMButton: function() {
     this.initializeInput();
     $('.add_sim_to_db').modal('show');
   },
   onSIMHideShowButton: function() {
     $('.toggle-datatable-columns').modal('show');
   },
   setUserId: function(id){
     this.user_id = id;
   },
   saveModal: function() {
    $('ul#errorOnSIM').html("");
    this.show_loading = true;
    this.show_errors = true;
    $("#body-sim-dis *").prop('disabled',true);

    var sim_provider = this.sim_provider;
    if(sim_provider == 'other'){
      sim_provider = this.other_sim_provider;
    }


    var sim_provider  = sim_provider,
        number        = this.number,
        name          = this.name,
        user_id       = this.user_id
    var data = {};
        data.sim_provider = sim_provider;
        data.number = number;
        data.name = name;
        data.addon = "Unknown";
        data.allowance = "0";
        data.volume_used = "0";
        data.user_id = user_id;
        data.three_user_id = 0;

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: this.onError,
      success: this.onSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "POST",
      url: "/sims"
    };

    vm.sendAJAXRequest(settings);
   },
    onError: function(jqXHR, status, error) {
      var cList = $('ul#errorOnSIM')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
      var li = $('<li/>')
          .text(value)
          .appendTo(cList);
      });
      this.show_errors = true;
      this.show_loading = false;
      $("#body-sim-dis *").prop('disabled', false);
      return false;
    },
    onSuccess: function(result, status, jqXHR) {
      $.notify({
        message: 'SIM has been added.'
      },{
        type: 'info'
      });
      $("#m_modal_add").modal("hide");
      $(".modal-backdrop").remove();
      this.show_loading = false;
      this.dataTable.ajax.reload();
      this.clearForm();
      return true;
    },
    clearForm: function() {
      this.number = "";
      this.name = "";
      this.sim_provider = "";
      this.other_sim_provider = "";
      $('ul#errorOnSIM').html("");
      $("#body-sim-dis *").prop('disabled', false);
      this.show_errors = false;
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
    resizeScreen: function(){
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
      this.dataTable.search("");
    },
    initHideShow: function(){
      $(".sims-column").each(function(){
        var that = $(this).attr("data-id");
        var column = vm.dataTable.columns("." +that);
        if(column.visible()[0] == true){
          $(this).prop('checked', true);
        }else{
          $(this).prop('checked', false);
        }
      });
    }
  }, // end of methods
  mounted(){
    this.initializeTable();
    this.resizeScreen();
    window.addEventListener('resize', this.resizeScreen);
  }
});
vm.initHideShow();
$(document).ready(function() {
  function resize_scroll() {
    vm.dataTable.search("").draw();
 }
 setTimeout(resize_scroll, 1500)
});