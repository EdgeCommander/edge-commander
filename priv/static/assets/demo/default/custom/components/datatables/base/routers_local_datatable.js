var vm = new Vue({
  el: '#router_main',
  data(){
    return{
      dataTable: null,
      m_form_search: "",
      headings: [
        {column: "Actions"},
        {column: "Name"},
        {column: "IP"},
        {column: "HTTP Port"},
        {column: "Username"},
        {column: "Password"},
        {column: "Monitoring"},
        {column: "Created At"},
      ],
      form_labels: {
        name: "Name",
        ip: "IP",
        username: "Username",
        password: "Password",
        http_port: "HTTP Port",
        status: "Monitoring",
        add_title: "Add Router",
        edit_title: "Edit Router",
        hide_show_title: "Show/Hide Columns",
        add_router_button: "Add Router",
        hide_show_button: "OK",
        submit_button: "Save changes"
      }
    }
  },
  methods: {
    initializeTable: function(){
      routersDataTable = $('#routers-datatable').DataTable({
        ajax: {
        url: "/routers",
          dataSrc: function(data) {
            return data.routers;
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
          class: "text-center width-60",
          data: function(row, type, set, meta) {
            return '<div class="editRouter cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="deleteRouter cursor_to_pointer fa fa-trash" data-id="'+ row.id +'"></div>';
          }
        },
        {
          class: "width-250",
          data: function(row, type, set, meta) {
            return row.name;
          }
        },
        {
          class: "width-150",
          data: function(row, type, set, meta) {
            return row.ip;
          }
        },
        {
          class: "text-center width-150",
          data: function(row, type, set, meta) {
            return row.port;
          }
        },
        {
          class: "text-center width-150",
          data: function(row, type, set, meta) {
            return row.username;
          }
        },
        {
          class: "width-150",
          data: function(row, type, set, meta) {
            return row.password;
          }
        },
        {
          class: "width-120",
          data: function(row, type, set, meta) {
            return row.is_monitoring;
          }
        },
        {
          class: "text-center width-250",
          data: function(row, type, set, meta) {
            return moment(row.created_at).format('MMMM Do YYYY, H:mm:ss');
          },
        },
        ],
        autoWidth: false,
        info: false,
        bPaginate: false,
        lengthChange: false,
        // stateSave:  true,
      });
      this.dataTable = routersDataTable;
    },
    search: function(){
      this.dataTable.search(this.m_form_search).draw();
    },
    showHideColumns: function(column){
      var column = this.dataTable.column(column);
      column.visible( ! column.visible() );
      this.resizeScreen();
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
    onROUTERButton: function() {
      $('.add_router_to_db').modal('show');
    },
    saveModal: function() {
      $('ul#errorOnROUTER').html("");
      $("#api-wait").removeClass("hide_me");
      $("#body-router-dis *").prop('disabled',true);
      $("#routerErrorDetails").addClass("hide_me");
      // $("#set_to_load").addClass("loading");
      var name          = $("#router_name").val(),
          IP            = $("#router_ip").val(),
          username      = $("#router_username").val(),
          password      = $("#router_password").val(),
          http_router_port = $("#http_router_port").val(),
          user_id       = $("#user_id").val(),
          is_monitoring = $('input[id=router_is_monitoring]:checked').length > 0;

      var data = {};
          data.name = name;
          data.ip = IP;
          data.username = username;
          data.password = password;
          data.port = http_router_port;
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
        url: "/routers"
      };

      this.sendAJAXRequest(settings);
    },
    onError: function(jqXHR, status, error) {
      var cList = $('ul#errorOnROUTER')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      $("#routerErrorDetails").removeClass("hide_me");
      $("#api-wait").addClass("hide_me");
      $("#body-router-dis *").prop('disabled', false);
      $("#set_to_load").removeClass("loading");
      return false;
    },
    onSuccess: function(result, status, jqXHR) {
      $.notify({
        message: 'Router has been added.'
      },{
        type: 'info'
      });
      $(".modal-backdrop").remove();
      $("#m_modal_1").modal("hide");
      $("#api-wait").addClass("hide_me");
      this.dataTable.ajax.reload();
      this.clearForm();
      return true;
    },
    clearForm: function() {
      $("#router_name").val("");
      $("#router_ip").val("");
      $("#router_username").val("");
      $("#router_password").val("");
      $("#http_router_port").val("");
      $('ul#errorOnROUTER').html("");
      $("#set_to_load").removeClass("loading");
      $("#body-router-dis *").prop('disabled', false);
      $("#routerErrorDetails").addClass("hide_me");
    },
    deleteRouter: function() {
      $(document).on("click", ".deleteRouter", function() {
        var routerRow, result;
        result = confirm("Are you sure to delete this Router?");
        if (result === false) {
          return;
        }
        routerRow = $(this).parents('tr');
        routerID = $(this).attr('data-id');

        var data = {};
        data.id = routerID;
        var settings;

        settings = {
          cache: false,
          data: data,
          dataType: 'json',
          error: function(){return false},
          success: function(){
            this.routerRow.remove();
            $.notify({
              message: 'Router has been deleted.'
            },{
              type: 'info'
            });
            return true;
          },
          contentType: "application/x-www-form-urlencoded",
          context: {routerRow: routerRow},
          type: "DELETE",
          url: "/routers/" + routerID
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
    onRouterEditButton: function() {
      $(document).on("click", ".editRouter", function(){

        var tr = $(this).closest('tr');
        var row = routersDataTable.row(tr);
        var data = row.data();

        router_id = $(this).data("id");


        $("#saveEditModal").attr('data-id', router_id);
        $("#edit_router_id").val(router_id);
        $("#edit_router_name").val(data.name);
        $("#edit_router_ip").val(data.ip);
        $("#edit_router_username").val(data.username);
        $("#edit_router_password").val(data.password);
        $("#edit_http_router_port").val(data.port);

        if (data.is_monitoring) {
        $('#edit_router_is_monitoring').prop('checked', true);
        }
        $('#edit_router_to_db').modal('show');
      });
    },
    updateRouterdo: function(){
        $("#body-router-edit-dis *").prop('disabled', true);
        $('ul#errorOnEditROUTER').html("");
        $("#api-wait").removeClass("hide_me");
        $("#routerEditErrorDetails").addClass("hide_me");

        var routerID = $("#edit_router_id").val();
        var name          = $("#edit_router_name").val(),
            IP            = $("#edit_router_ip").val(),
            username      = $("#edit_router_username").val(),
            password      = $("#edit_router_password").val(),
            http_router_port = $("#edit_http_router_port").val(),
            is_monitoring = $('input[id=edit_router_is_monitoring]:checked').length > 0;

        var data = {};
            data.name = name;
            data.ip = IP;
            data.username = username;
            data.password = password;
            data.port = http_router_port;
            data.is_monitoring = is_monitoring;
            data.id = routerID;

        var settings;

        settings = {
          cache: false,
          data: data,
          dataType: 'json',
          error: this.onEditError,
          success: this.onEditSuccess,
          contentType: "application/x-www-form-urlencoded",
          type: "PATCH",
          url: "/routers/" + routerID
        };

        this.sendAJAXRequest(settings);
    },
    onEditError: function(jqXHR, status, error) {
      $("#api-wait").addClass("hide_me");
      $("#body-router-edit-dis *").prop('disabled', false);
      var cList = $('ul#errorOnEditROUTER')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      $("#routerEditErrorDetails").removeClass("hide_me");
      return false;
    },
    onEditSuccess: function(result, status, jqXHR) {
      $.notify({
        message: 'Router has been updated.'
      },{
        type: 'info'
      });
      $("#api-wait").addClass("hide_me");
      this.editClearFrom();
      $("#edit_router_to_db").modal("hide");
      this.dataTable.ajax.reload();
      return true;
    },
    editClearFrom: function() {
      $("#edit_router_name").val("");
      $("#edit_router_ip").val("");
      $("#edit_router_username").val("");
      $("#edit_router_password").val("");
      $("#edit_http_router_port").val("");
      $('ul#errorOnEditROUTER').html("");
      $("#body-router-edit-dis *").prop('disabled', false);
      $("#routerEditErrorDetails").addClass("hide_me");
    },
    resizeScreen: function(){
      $('#double-scroll').doubleScroll();
      var table_width = $("#routers-datatable").width();
      $(".doubleScroll-scroll").width(table_width);
    }
  }, // end of methods
   mounted(){
    this.initializeTable();
    this.resizeScreen();
    this.deleteRouter();
    this.onRouterEditButton();
    window.addEventListener('resize', this.resizeScreen);
   }
});
