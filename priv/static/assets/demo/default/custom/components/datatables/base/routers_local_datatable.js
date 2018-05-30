var vm = new Vue({
  el: '#router_main',
  data: {
    dataTable: null,
    m_form_search: "",
    show_loading: false,
    show_errors: false,
    show_edit_errors: false,
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
    },
    router_name: "",
    router_ip: "",
    router_username: "",
    router_password: "",
    http_router_port: "",
    router_is_monitoring: false,
    edit_router_id: "",
    edit_router_name: "",
    edit_router_ip: "",
    edit_router_username: "",
    edit_router_password: "",
    edit_http_router_port: "",
    edit_router_is_monitoring:  false,
    user_id: ""
  },
  methods: {
    initializeTable: function(){
      routersDataTable = $('#routers-datatable').DataTable({
        ajax: {
        url: "/routers/data",
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
    setUserId: function(id){
      this.user_id = id;
    },
    saveModal: function() {
      $('ul#errorOnROUTER').html("");
      this.show_loading = true;
      $("#body-router-dis *").prop('disabled',true);
      this.show_errors = true;

      var name             = this.router_name,
          IP               = this.router_ip,
          username         = this.router_username,
          password         = this.router_password,
          http_router_port = this.http_router_port,
          user_id          = this.user_id,
          is_monitoring    = this.router_is_monitoring;

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

      vm.sendAJAXRequest(settings);
    },
    onError: function(jqXHR, status, error) {
      var cList = $('ul#errorOnROUTER')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      this.show_errors = true;
      this.show_loading = false;
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
      this.show_loading = false;
      this.dataTable.ajax.reload();
      this.clearForm();
      return true;
    },
    clearForm: function() {
      this.router_name = "";
      this.router_ip = "";
      this.router_username = "";
      this.router_password = "";
      this.http_router_port = "";
      this.router_is_monitoring = false;
      $('ul#errorOnROUTER').html("");
      $("#body-router-dis *").prop('disabled', false);
      this.show_errors = false;
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

        vm.sendAJAXRequest(settings);
      });
    },
    getUniqueIdentifier: function(){
      $(document).on("click", ".editRouter", function(){
        var tr = $(this).closest('tr');
        var row = routersDataTable.row(tr);
        var data = row.data();
        router_id = $(this).data("id");
        vm.onRouterEditButton(router_id, data);
      });
    },
    onRouterEditButton: function(router_id, data) {

        this.edit_router_id = router_id;
        this.edit_router_name = data.name;
        this.edit_router_ip = data.ip;
        this.edit_router_username = data.username;
        this.edit_router_password = data.password;
        this.edit_http_router_port = data.port;

        if (data.is_monitoring) {
          this.edit_router_is_monitoring = true;
        }
        $('#edit_router_to_db').modal('show');
    },
    updateRouterdo: function(){
        $("#body-router-edit-dis *").prop('disabled', true);
        $('ul#errorOnEditROUTER').html("");
        this.show_loading = true;
        this.show_edit_errors = true;

        var routerID         = this.edit_router_id;
        var name             = this.edit_router_name,
            IP               = this.edit_router_ip,
            username         = this.edit_router_username,
            password         = this.edit_router_password,
            http_router_port = this.edit_http_router_port,
            is_monitoring    = this.edit_router_is_monitoring;

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

        vm.sendAJAXRequest(settings);
    },
    onEditError: function(jqXHR, status, error) {
      this.show_loading = false;
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
      this.show_loading = false;
      this.editClearFrom();
      $("#edit_router_to_db").modal("hide");
      this.dataTable.ajax.reload();
      return true;
    },
    editClearFrom: function() {
      this.edit_router_id = "";
      this.edit_router_name = "";
      this.edit_router_ip = "";
      this.edit_router_username = "";
      this.edit_router_password = "";
      this.edit_http_router_port = "";
      this.edit_router_is_monitoring = false;
   
      $("#body-router-edit-dis *").prop('disabled', false);
      this.show_loading = false;
      this.show_edit_errors = false;
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
    this.getUniqueIdentifier();
    window.addEventListener('resize', this.resizeScreen);
   }
});
