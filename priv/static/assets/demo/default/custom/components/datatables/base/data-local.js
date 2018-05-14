var vm = new Vue({
  el: '#sims_main',
  data: {
    dataTable: null,
    m_form_search: "",
    show_loading: false,
    show_errors: false,
    headings: [
      {column: "Number"},
      {column: "Name"},
      {column: "MB Allowance"},
      {column: "MB Used (Today)"},
      {column: "MB Used (Yest.)"},
      {column: "% Used"},
      {column: "Remaning Days"},
      {column: "Sim Provider"},
      {column: "Last Reading"},
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
    other_sim_provider: ""
  },
  methods: {
    initializeTable: function(){
      simsDataTable = $('#sims-datatable').DataTable({
      ajax: {
      url: "/sims",
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
        class: "text-left width-150",
        data: function(row, type, set, meta) {
          return '<a style="color: blue;text-decoration: underline;cursor: pointer;" href="/sims/' + row.number + '" id="show-morris-graph" data-id="' + row.number + '">' + row.number  + '</a>'
        }
      },
      {
        class: "text-left width-250",
        data: function(row, type, set, meta) {
          return row.name;
        }
      },
      {
        class: "text-center width-150",
        data: function(row, type, set, meta) {
          allowance_value = row.allowance_in_number
          if (allowance_value == -1.0) {
            allowance_value = "Unlimited";
          }
          return allowance_value;
        }
      },
      {
        class: "text-center width-150",
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
        class: "text-center width-150",
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
        class: "text-center width-150",
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
        class: "text-center width-150",
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
        class: "text-center width-150",
        data: function(row, type, set, meta) {
          return row.sim_provider;
        }
      },
      {
        class: "text-center width-250",
        data: function(row, type, set, meta) {
          return moment(row.date_of_use).format('MMMM Do YYYY, H:mm:ss');
        }
      },
      ],
      autoWidth: false,
      info: false,
      bPaginate: false,
      lengthChange: false,
      order: [[ 5, "desc" ]],
      // stateSave:  true,
    });
      this.dataTable = simsDataTable;
   },
   search: function(){
    this.dataTable.search(this.m_form_search).draw();
   },
   showHideColumns: function(column){
    var column = this.dataTable.column(column);
    column.visible( ! column.visible() );
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
        name          = this.name

    var data = {};
        data.sim_provider = sim_provider;
        data.number = number;
        data.name = name;
        data.addon = "Unknown";
        data.allowance = "0";
        data.volume_used = "0";

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
      $(".modal-backdrop").remove();
      $("#m_modal_1").modal("hide");
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
    $('#double-scroll').doubleScroll();
    var table_width = $("#sims-datatable").width();
    $(".doubleScroll-scroll").width(table_width);
   }
  }, // end of methods
  mounted(){
    this.initializeTable();
    this.resizeScreen();
    window.addEventListener('resize', this.resizeScreen);
  }
});
