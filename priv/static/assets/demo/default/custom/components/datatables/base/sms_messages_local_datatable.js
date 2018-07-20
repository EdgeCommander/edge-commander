var vm = new Vue({
  el: '#sms_main',
   data: {
    dataTable: null,
    m_form_search: "",
    show_loading: false,
    headings: [
      {column: "Message Date", visible: "checked", id: "inserted_at"},
      {column: "From", visible: "checked", id: "from"},
      {column: "To", visible: "checked", id: "to"},
      {column: "Message ID", id: "message_id"},
      {column: "Type", visible: "checked", id: "type"},
      {column: "Text Message", visible: "checked", id: "text_message"},
      {column: "Status", visible: "checked", id: "status"},
    ],
    form_labels: {
      sim: "SIM",
      message: "Message",
      submit_button: "Send",
      add_title: "Send SMS",
      hide_show_title: "Show/Hide Columns",
      add_sms_button: "Send SMS",
      hide_show_button: "OK"
    },
    smsMessage: "",
    toNumber: "",
    user_id: "",
    smsMessage_text: ""
  },
  methods: {
    initializeTable: function(){

      $( "#m_sms_datepicker_from" ).datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date(new Date().getTime() - (48 * 60 * 60 * 1000)));
      $( "#m_sms_datepicker_to" ).datepicker({autoclose:true, dateFormat:"yy-mm-dd"}).datepicker("setDate", new Date());

      var from_date = $("#m_sms_datepicker_from").val(),
      to_date = $("#m_sms_datepicker_to").val();

      smsDataTable = $('#sms-datatable').DataTable({
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
          class: "text-center inserted_at",
          data: function(row, type, set, meta) {
            return moment(row.inserted_at).format('MMMM Do YYYY, H:mm:ss');
          },
        },
        {
          class: "from",
          data: function(row, type, set, meta) {
            return row.from;
          }
        },
        {
          class: "to",
          data: function(row, type, set, meta) {
            return row.to;
          }
        },
        {
          class: "message_id",
          visible: false,
          data: function(row, type, set, meta) {
            return row.message_id;
          }
        },
        {
          class: "type",
          data: function(row, type, set, meta) {
            if(row.type == "MO"){
              return "<span class='m-badge m-badge--metal m-badge--wide'>Incoming</span>";
            }else{
              return "<span class='m-badge m-badge--success m-badge--wide'>Outgoing</span>";
            }
          }
        },
        {
          class: "text_message",
          data: function(row, type, set, meta) {
            return row.text;
          }
        },
        {
          class: "text-center  status",
          data: function(row, type, set, meta) {
            status = row.status;
            if(status == "Received"){
              return '<span title="Received"><svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 18 18" width="18" height="18"><path fill="#92A58C" d="M17.394 5.035l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-.427-.388a.381.381 0 0 0-.578.038l-.451.576a.497.497 0 0 0 .043.645l1.575 1.51a.38.38 0 0 0 .577-.039l7.483-9.602a.436.436 0 0 0-.076-.609zm-4.892 0l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-2.614-2.556a.435.435 0 0 0-.614.007l-.505.516a.435.435 0 0 0 .007.614l3.887 3.8a.38.38 0 0 0 .577-.039l7.483-9.602a.435.435 0 0 0-.075-.609z"></path></svg></span>'
            }else if(status == "delivered"){
              return '<span title="Delivered"><svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 18 18" width="18" height="18"><path fill="#4FC3F7" d="M17.394 5.035l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-.427-.388a.381.381 0 0 0-.578.038l-.451.576a.497.497 0 0 0 .043.645l1.575 1.51a.38.38 0 0 0 .577-.039l7.483-9.602a.436.436 0 0 0-.076-.609zm-4.892 0l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-2.614-2.556a.435.435 0 0 0-.614.007l-.505.516a.435.435 0 0 0 .007.614l3.887 3.8a.38.38 0 0 0 .577-.039l7.483-9.602a.435.435 0 0 0-.075-.609z"></path></svg></span>'
            }else if(status == "Failed"){
              return "<span title='Failed' style='color:#b51010;font-size:16px;font-weight:bold'>&#10005;</span>"
            }else if(status == "Accepted"){
              return '<span title="Accepted"><svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 15" width="18" height="18"><path fill="#92A58C" d="M10.91 3.316l-.478-.372a.365.365 0 0 0-.51.063L4.566 9.879a.32.32 0 0 1-.484.033L1.891 7.769a.366.366 0 0 0-.515.006l-.423.433a.364.364 0 0 0 .006.514l3.258 3.185c.143.14.361.125.484-.033l6.272-8.048a.365.365 0 0 0-.063-.51z"></path></svg></span>'
            }else{
              return "<span title='Pending'><i class='fa fa-clock-o' style='color:gray;font-size:16px'></i></span>"
            }
          }
        }
        ],
        autoWidth: false,
        info: false,
        bPaginate: false,
        lengthChange: false,
        scrollX: true,
        colReorder: true,
        stateSave:  true,
        sort: false
      });
      this.dataTable = smsDataTable;
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
    setUserId: function(id){
      this.user_id = id;
    },
    sendSMS: function(){
      $('ul#errorOnSms').html("");
      this.show_loading = true;

      var sms_message  = this.smsMessage_text,
      to_number        = this.toNumber,
      user_id          = this.user_id

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
      this.show_loading = false;
      this.clearForm();
      $("#body-sms-dis *").prop('disabled', false);
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
      this.show_loading = false;
      this.clearForm();
      return true;
    },
    clearForm: function() {
      this.smsMessage = "";
      this.toNumber = "";
      this.smsMessage_text = "";
      $('ul#errorOnSite').html("");
      $("#body-sms-dis *").prop('disabled', false);
    },
    dateFilterInitialize: function() {
      var table_data = this.dataTable;
      $('#m_sms_datepicker_from, #m_sms_datepicker_to').change(function(){
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
    },
    onSmsHideShowButton: function() {
      $('.toggle-datatable-columns').modal('show');
    },
    autocompleteInput: function(){
      $(function () {
        var availableTags = [
         "Disconnect",
          "Connect",
          "Restart",
          "Reconnect",
          "Status",
          "VPN on",
          "VPN off",
          "Upgrade",
          "Internet on",
          "Internet off",
          "WLAN on",
          "WLAN off",
          "On",
          "Off",
          "#01#",
          "#02#"
        ];
        $("#smsMessage").autocomplete({
          source: availableTags,
          minLength: 0,
          change: function(event, ui) {
            if (ui.item) {
              vm.smsMessage_text = ui.item.value
              vm.smsMessage = ui.item.value
            }
          }
        });
        $('#input_img').on('click', function () {
          $('#smsMessage').autocomplete('search' , '');
        });
        $('#smsMessage').on('keyup', function () {
          value =  $(this).val();
          vm.smsMessage_text = value
        });
      });
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
    },
    initHideShow: function(){
      $(".sms-column").each(function(){
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
    this.dateFilterInitialize();
    this.onSendSMSFocus();
    window.addEventListener('resize', this.resizeScreen);
   }
});
vm.initHideShow();