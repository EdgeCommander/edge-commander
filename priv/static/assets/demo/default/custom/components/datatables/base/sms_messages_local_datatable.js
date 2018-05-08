var vm = new Vue({
  el: '#sms_main',
   data(){
    return{
      dataTable: null,
      m_form_search: "",
      headings: [
        {column: "From"},
        {column: "To"},
        {column: "Message ID"},
        {column: "Type"},
        {column: "Text Message"},
        {column: "Status"},
        {column: "Message Date"}
      ],
      form_labels: {
        sim: "SIM",
        message: "Message",
        submit_button: "Send",
        add_title: "Send SMS",
        hide_show_title: "Show/Hide Columns",
        add_sms_button: "Send SMS",
        hide_show_button: "OK"
      }
    }
  },
  methods: {
    initializeTable: function(){

      $( "#m_sms_datepicker_from" ).datepicker({autoclose:true, format:"yyyy-mm-dd"}).datepicker("setDate", new Date(new Date().getTime() - (48 * 60 * 60 * 1000)));
      $( "#m_sms_datepicker_to" ).datepicker({autoclose:true, format:"yyyy-mm-dd"}).datepicker("setDate", new Date());

      var from_date = $("#m_sms_datepicker_from").val(),
      to_date = $("#m_sms_datepicker_to").val();

      smsDataTable = $('#sms-datatable').DataTable({
        ajax: {
        url: "/get_all_sms/" + from_date + "/" + to_date,
          dataSrc: function(data) {
            return data.sms_messages;
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
          class: "width-120",
          data: function(row, type, set, meta) {
            return row.from;
          }
        },
        {
          class: "width-120",
          data: function(row, type, set, meta) {
            return row.to;
          }
        },
        {
          visible: false,
          class: "width-180",
          data: function(row, type, set, meta) {
            return row.message_id;
          }
        },
        {
          class: "width-80",
          data: function(row, type, set, meta) {
            if(row.type == "MO"){
              return "<span class='m-badge m-badge--metal m-badge--wide'>Incoming</span>";
            }else{
              return "<span class='m-badge m-badge--success m-badge--wide'>Outgoing</span>";
            }
          }
        },
        {
          class: "width-1060",
          data: function(row, type, set, meta) {
            return row.text;
          }
        },
        {
          class: "width-80",
          data: function(row, type, set, meta) {
            status = row.status;
            if(status == "Received"){
              return "<span class='m-badge m-badge--metal m-badge--wide' style='text-transform:capitalize'>"+status+"</span>"
            }else if(status == "delivered"){
              return "<span class='m-badge m-badge--success m-badge--wide' style='text-transform:capitalize'>"+status+"</span>"
            }else{
              return "<span class='m-badge m-badge--info m-badge--wide' style='text-transform:capitalize'>"+status+"</span>"
            }
          }
        },       
        {
          class: "text-center width-200",
          data: function(row, type, set, meta) {
            return moment(row.inserted_at).format('MMMM Do YYYY, H:mm:ss');
          },
        },
        ],
        autoWidth: false,
        info: false,
        bPaginate: false,
        lengthChange: false,
        // stateSave:  true,
      });
      this.dataTable = smsDataTable;
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
    sendSMS: function(){
      $('ul#errorOnSms').html("");
      $("#api-wait").removeClass("hide_me");
      $("#smsErrorDetails").addClass("hide_me");

      var sms_message  = $("#smsMessage").val(),
      to_number        = $("#toNumber").val(),
      user_id          = $("#user_id").val()

      var data = {};
      data.sms_message = sms_message;
      data.sim_number = to_number;
      data.user_id = user_id;

      var settings;

      settings = {
        cache: false,
        data: data,
        dataType: 'json',
        error: this.onSMSError,
        success: this.onSMSSuccess,
        contentType: "application/x-www-form-urlencoded",
        type: "POST",
        url: "/send_sms"
      };
      this.sendAJAXRequest(settings);
    },
    onSMSError: function(jqXHR, status, error) {
      $.notify({
        message: "Something went wrong."
      },{
        type: 'danger'
      });
      $("#smsErrorDetails").removeClass("hide_me");
      $("#api-wait").addClass("hide_me");
      $("#body-sms-dis *").prop('disabled', false);
      $("#set_to_load").removeClass("loading");
      return false;
    },
    onSMSSuccess: function(result, status, jqXHR) {
      if (result.status != 0) {
        $.notify({
          message: result.error_text
        },{
          type: 'danger'
        });
      } else{
        $.notify({
          message: "Your message has been sent."
        },{
          type: 'info'
        });
      }
      $(".modal-backdrop").remove();
      $(".add_sms_to_db").modal("hide");
      this.dataTable.ajax.reload();
      $("#api-wait").addClass("hide_me");
      this.clearForm();
      return true;
    },
    clearForm: function() {
      $("#smsMessage").val("");
      $('ul#errorOnSite').html("");
      $("#set_to_load").removeClass("loading");
      $("#body-sms-dis *").prop('disabled', false);
      $("#smsErrorDetails").addClass("hide_me");
    },
    resizeScreen: function(){
      $('#double-scroll').doubleScroll();
      var table_width = $("#sms-datatable").width();
      $(".doubleScroll-scroll").width(table_width);
    },
    dateFilterInitialize: function() {
      var table_data = this.dataTable;
    $('#m_sms_datepicker_from, #m_sms_datepicker_to').datepicker({
        autoclose: true,
        format: "yyyy-mm-dd"
      }).on('changeDate', function(e) {
        var from_date = $("#m_sms_datepicker_from").val(),
        to_date = $("#m_sms_datepicker_to").val();
        var new_url = "/get_all_sms/" + from_date + "/" + to_date
        table_data.ajax.url(new_url).load();
      });
    },
    onSendSMSFocus: function() {
      $('.add_sms_to_db').on('shown.bs.modal', function () {
        $('#smsMessage').focus();
      });
    },
    onSmsButton: function() {
      $('.add_sms_to_db').modal('show');
    }
  }, // end of methods
   mounted(){
    this.initializeTable();
    this.resizeScreen();
    this.dateFilterInitialize();
    this.onSendSMSFocus();
    window.addEventListener('resize', this.resizeScreen);
   }
});
