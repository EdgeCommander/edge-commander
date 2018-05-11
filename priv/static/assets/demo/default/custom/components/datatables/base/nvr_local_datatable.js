var vm = new Vue({
  el: '#nvr_main',
  data: {
    dataTable: null,
    m_form_search: "",
    show_loading: false,
    show_errors: false,
    show_edit_errors: false,
    headings: [
      {column: "Reboot", visible: "checked"},
      {column: "Actions", visible: "checked"},
      {column: "Name", visible: "checked"},
      {column: "IP", visible: "checked"},
      {column: "HTTP Port"},
      {column: "VH Port"},
      {column: "SDK Port"},
      {column: "RTSP Port"},
      {column: "Username"},
      {column: "Password"},
      {column: "Model", visible: "checked"},
      {column: "Firmware Version", visible: "checked"},
      {column: "Encoder Released Date"},
      {column: "Encoder Version"},
      {column: "Firmware Released Date"},
      {column: "Serial Number"},
      {column: "Mac Address"},
      {column: "Status", visible: "checked"},
      {column: "Monitoring"},
      {column: "Created At"},
     ],
     form_labels: {
      name: "Name",
      ip: "IP",
      username: "Username",
      password: "Password",
      http_port: "HTTP Port",
      rtsp_port: "RTSP Port",
      sdk_port: "SDK Port",
      vh_port: "VH Port",
      status: "Monitoring",
      add_title: "Add NVR",
      edit_title: "Edit NVR",
      hide_show_title: "Show/Hide Columns",
      add_nvr_button: "Add NVR",
      hide_show_button: "OK",
      submit_button: "Save changes"
     },
     nvr_name: "",
     nvr_ip: "",
     nvr_username: "",
     nvr_password: "",
     http_nvr_port: "",
     sdk_nvr_port: "",
     vh_nvr_port: "",
     rtsp_nvr_port: "",
     user_id: "",
     nvr_is_monitoring: "",
     edit_nvr_id: "",
     edit_nvr_name: "",
     edit_nvr_ip: "",
     edit_nvr_username: "",
     edit_nvr_password: "",
     edit_http_nvr_port: "",
     edit_sdk_nvr_port: "",
     edit_vh_nvr_port: "",
     edit_nvr_is_monitoring: ""
  },
  methods: {
    initializeTable: function(){
      nvrDataTable = $('#nvr-datatable').DataTable({
      ajax: {
      url: "/nvrs",
        dataSrc: function(data) {
          return data.nvrs;
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
        class: "text-center width-10",
        data: function(row, type, set, meta) {
          return '<button class="btn btn-default rebootNVR cursor_to_pointer" data-id="'+ row.id +'" style="font-size:10px;padding: 5px;">Reboot</button>';
        }
      },
      {
        class: "text-center width-80",
        data: function(row, type, set, meta) {
          return '<div class="editNVR cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="deleteNVR cursor_to_pointer fa fa-trash" data-id="'+ row.id +'"></div>';
        }
      },
      {
        class: "width-250",
        data: function(row, type, set, meta) {
          url = row.ip + ":" + row.port
          return "<span style='float:left'>"+row.name+"</span><a href='http://"+url+"' target='_blank'><span class='fa fa-external-link' style='float:right'></span></a>"
        }
      },
      {
        class: "text-left width-250",
        data: function(row, type, set, meta) {
          return row.ip;
        }
      },
      {
        visible: false,
        class: "text-center width-150",
        data: function(row, type, set, meta) {
          return row.port;
        }
      },
      {
        visible: false,
        class: "text-center width-80",
        data: function(row, type, set, meta) {
          return row.vh_port;
        }
      },
      {
        visible: false,
        class: "text-center width-80",
        data: function(row, type, set, meta) {
          return row.sdk_port;
        }
      },
      {
        visible: false,
        class: "text-center width-80",
        data: function(row, type, set, meta) {
          return row.rtsp_port;
        }
      },
      {
        visible: false,
        class: "text-center width-150",
        data: function(row, type, set, meta) {
          return row.username;
        }
      },
      {
        visible: false,
        class: "text-center width-150",
        data: function(row, type, set, meta) {
          return row.password;
        }
      },
      {
        class: "text-center width-250",
        data: function(row, type, set, meta) {
          return row.model;
        }
      },
      {
        class: "text-center width-180",
        data: function(row, type, set, meta) {
          return row.firmware_version;
        }
      },
      {
        visible: false,
        class: "text-center width-180",
        data: function(row, type, set, meta) {
          return row.encoder_released_date;
        }
      },
      {
        visible: false,
        class: "text-center width-180",
        data: function(row, type, set, meta) {
          return row.encoder_version;
        }
      },
      {
        visible: false,
        class: "text-center width-180",
        data: function(row, type, set, meta) {
          return row.firmware_released_date;
        }
      },
      {
        visible: false,
        class: "text-left width-400",
        data: function(row, type, set, meta) {
          return row.serial_number;
        }
      },
      {
        visible: false,
        class: "text-center width-180",
        data: function(row, type, set, meta) {
          return row.mac_address;
        }
      },
      {
        class: "text-center width-200",
        data: function(row, type, set, meta) {
          if(row.nvr_status == false){
            reason  = row.reason;
            if(reason == ''){
              reason = "no reason found.";
            }
            return "<span style='color:#d9534d'>Offline</span> <span>(" + reason + ")</span>";
          }else{
            return "<span style='color:#5cb85c'>Online</span>";
          }
        }
      },
      {
        visible: false,
        class: "text-center width-80",
        data: function(row, type, set, meta) {
           if (row.is_monitoring) {
            return "Yes";
          } else{
            return "No";
          }
        }
      },
      {
        visible: false,
        class: "text-center width-250",
        data: function(row, type, set, meta) {
          return moment(row.created_at).format('MMMM Do YYYY, H:mm:ss');
        }
      },
      ],
      autoWidth: false,
      info: false,
      bPaginate: false,
      lengthChange: false,
      // stateSave:  true,
    });
      this.dataTable = nvrDataTable;
   },
   search: function(){
    this.dataTable.search(this.m_form_search).draw();
   },
   showHideColumns: function(column){
    var column = this.dataTable.column(column);
    column.visible( ! column.visible() );
    this.resizeScreen();
   },
   resizeScreen: function(){
    $('#double-scroll').doubleScroll();
    var table_width = $("#nvr-datatable").width();
    $(".doubleScroll-scroll").width(table_width);
   },
   onNVRButton: function() {
    $('.add_nvr_to_db').modal('show');
   },
   sendAJAXRequest: function(settings){
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
   saveModal: function() {
      $('ul#errorOnNVR').html("");
      this.show_loading = true;
      $("#body-nvr-dis *").prop('disabled',true);
      this.show_errors = true;

      var name          = this.nvr_name,
          IP            = this.nvr_ip,
          username      = this.nvr_username,
          password      = this.nvr_password,
          http_nvr_port = this.http_nvr_port,
          sdk_nvr_port  = this.sdk_nvr_port,
          vh_nvr_port   = this.vh_nvr_port,
          rtsp_nvr_port = this.rtsp_nvr_port,
          user_id       = this.user_id,
          is_monitoring = this.nvr_is_monitoring;

      var data = {};
          data.name = name;
          data.ip = IP;
          data.username = username;
          data.password = password;
          data.port = http_nvr_port;
          data.sdk_port = sdk_nvr_port;
          data.vh_port = vh_nvr_port;
          data.rtsp_port = rtsp_nvr_port;
          data.is_monitoring = is_monitoring;
          data.user_id = user_id;

      var settings;

      settings = {
        cache: false,
        data: data,
        dataType: 'json',
        error: this.onError,
        success: this.onSuccess,
        contentType: "application/x-www-form-urlencoded",
        type: "POST",
        url: "/nvrs"
      };

      vm.sendAJAXRequest(settings);
   },
   onError: function(jqXHR, status, error) {
      var cList = $('ul#errorOnNVR')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      this.show_errors = true;
      this.show_loading = false;
      $("#body-nvr-dis *").prop('disabled', false);
      $("#set_to_load").removeClass("loading");
      return false;
   },
   onSuccess: function(result, status, jqXHR) {
      $.notify({
        message: 'NVR has been added.'
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
      this.nvr_name = "";
      this.nvr_ip = "";
      this.nvr_username = "";
      this.nvr_password = "";
      this.http_nvr_port = "";
      this.sdk_nvr_port = "";
      this.vh_nvr_port = "";
      this.rtsp_nvr_port = "";
      this.nvr_is_monitoring = false;
      $('ul#errorOnNVR').html("");
      $("#body-nvr-dis *").prop('disabled', false);
      this.show_errors = false;
   },
   deleteNVR: function() {
      $(document).on("click", ".deleteNVR", function() {
        var nvrRow, result;
        result = confirm("Are you sure to delete this NVR?");
        if (result === false) {
          return;
        }
        nvrRow = $(this).parents('tr');
        nvrID = $(this).attr('data-id');

        var data = {};
        data.id = nvrID;
        var settings;

        settings = {
          cache: false,
          data: data,
          dataType: 'json',
          error: function(){return false},
          success: function(){
            this.nvrRow.remove();
            $.notify({
              message: 'NVR has been deleted.'
            },{
              type: 'info'
            });
            return true;
          },
          contentType: "application/x-www-form-urlencoded",
          context: {nvrRow: nvrRow},
          type: "DELETE",
          url: "/nvrs/" + nvrID
        };

        vm.sendAJAXRequest(settings)

      });
   },
   rebootNVR: function() {
    $(document).on("click", ".rebootNVR", function() {
      var nvrRow, result;
      result = confirm("Are you sure to reboot this NVR?");
      if (result === false) {
        return;
      }
      nvrRow = $(this).parents('tr');
      nvrID = $(this).attr('data-id');

      var data = {};
      data.id = nvrID;
      var settings;

      mApp.block(".m_nvr_datatable", {
        overlayColor: "#000000",
        type: "loader",
        state: "primary",
        message: "Please Wait..."
      });

      settings = {
        cache: false,
        data: data,
        dataType: 'json',
        error: function(jqXHR, status, error) {
        mApp.unblock(".m_nvr_datatable", {
          overlayColor: "#000000",
          type: "loader",
          state: "primary",
          message: "Please Wait..."
        });
       $.notify({
          message: jqXHR.responseJSON.message
        },{
          type: 'danger'
        });
      return false;
      },
      success: function(result, status, jqXHR) {
        mApp.unblock(".m_nvr_datatable", {
          overlayColor: "#000000",
          type: "loader",
          state: "primary",
          message: "Please Wait..."
        });
        if (result.status != 201) {
          $.notify({
            message: result.message
          },{
            type: 'danger'
          });
        } else
        {
          $.notify({
            message: "Nvr has been reboot successfully."
          },{
            type: 'info'
          });
        }
        return true;
      },
        contentType: "application/x-www-form-urlencoded",
        context: {nvrRow: nvrRow},
        type: "GET",
        url: "/nvrs/" + nvrID
      };

      var headers, token, xhrRequestChangeMonth;
      token = $('meta[name="csrf-token"]');
      if (token.length > 0) {
        headers = {
          "X-CSRF-Token": token.attr("content")
        };
        settings.headers = headers;
      }
      jQuery.ajax(settings);
    });
   },
   getUniqueIdentifier: function(){
      $(document).on("click", ".editNVR", function(){
        var tr = $(this).closest('tr');
        var row = nvrDataTable.row(tr);
        var data = row.data();
        nvr_id = $(this).data("id");
        vm.onNVREditButton(nvr_id, data);
      });
    },
   onNVREditButton: function(nvr_id, data) {
      this.edit_nvr_id = nvr_id
      this.edit_nvr_ip = data.ip
      this.edit_nvr_name = data.name
      this.edit_nvr_username = data.username
      this.edit_nvr_password = data.password
      this.edit_http_nvr_port = data.port
      this.edit_vh_nvr_port = data.vh_port
      this.edit_sdk_nvr_port = data.sdk_port
      this.edit_rtsp_nvr_port = data.rtsp_port

      if (data.is_monitoring) {
        this.edit_nvr_is_monitoring = true;
      }
      $('#edit_nvr_to_db').modal('show');
    },
    updateNVRdo: function(){
      $("#body-nvr-edit-dis *").prop('disabled', true);
      $('ul#errorOnEditNVR').html("");
      this.show_loading = true;
      this.show_edit_errors = true;

      var nvrID = this.edit_nvr_id;

      var name          = this.edit_nvr_name,
          IP            = this.edit_nvr_ip,
          username      = this.edit_nvr_username,
          password      = this.edit_nvr_password,
          http_nvr_port = this.edit_http_nvr_port,
          sdk_nvr_port  = this.edit_sdk_nvr_port,
          vh_nvr_port   = this.edit_vh_nvr_port,
          rtsp_nvr_port = this.edit_rtsp_nvr_port,
          is_monitoring = this.edit_nvr_is_monitoring;

      var data = {};
          data.name = name;
          data.ip = IP;
          data.username = username;
          data.password = password;
          data.port = http_nvr_port;
          data.sdk_port = sdk_nvr_port;
          data.vh_port = vh_nvr_port;
          data.rtsp_port = rtsp_nvr_port;
          data.is_monitoring = is_monitoring;
          data.id = nvrID;

      var settings;

      settings = {
        cache: false,
        data: data,
        dataType: 'json',
        error: this.onEditError,
        success: this.onEditSuccess,
        contentType: "application/x-www-form-urlencoded",
        type: "PATCH",
        url: "/nvrs/" + nvrID
      };

      vm.sendAJAXRequest(settings);
    },
    onEditError: function(jqXHR, status, error) {
      $("#body-nvr-edit-dis *").prop('disabled', false);
      var cList = $('ul#errorOnEditNVR')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      $("#nvrEditErrorDetails").removeClass("hide_me");
      this.show_loading = false;
      return false;
    },
    onEditSuccess: function(result, status, jqXHR) {
      $.notify({
        message: 'NVR has been updated.'
      },{
        type: 'info'
      });
      this.editClearFrom();
      $("#edit_nvr_to_db").modal("hide");
      this.show_loading = false;
      this.dataTable.ajax.reload();
      return true;
    },
    editClearFrom: function() {

      this.edit_nvr_id = "";
      this.edit_nvr_name = "";
      this.edit_nvr_ip = "";
      this.edit_nvr_username = "";
      this.edit_nvr_password = ""
      this.edit_http_nvr_port = "";
      this.edit_vh_nvr_port = "";
      this.edit_sdk_nvr_port = "";
      this.edit_rtsp_nvr_port = "";
      this.edit_nvr_is_monitoring = false;
       
      $("#body-nvr-edit-dis *").prop('disabled', false);
      this.show_loading = false;
      this.show_edit_errors = false;
    }

  }, // end of methods
  mounted(){
    this.initializeTable();
    this.resizeScreen();
    this.deleteNVR();
    this.rebootNVR();
    this.getUniqueIdentifier();
    window.addEventListener('resize', this.resizeScreen);
  }

});
