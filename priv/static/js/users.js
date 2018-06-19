var vm = new Vue({
  el: '#profile_main',
  data: {
    dataTable: null,
    add_button_label: "Add New",
    headings: [
      {column: "Actions", class: "text-center"},
      {column: "Username"},
      {column: "Password"},
      {column: "Created At"}
    ],
    form_labels: {
      fname: "First Name",
      lname: "Last Name",
      email: "Email",
      password: "Password",
      api_key: "Api Key",
      api_id: "Api Id",
      title: "My Profile",
      submit_button: "Save changes",
      add_title: "Add new account (three.ie)",
      username: "Username",
      password: "Password",
      edit_title: "Edit account details",
      hide_show_title: "Show/Hide Columns",
      hide_show_button: "OK"
    }
  },
  methods: {
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
    setValue: function(user_id, fname, lname, email, password){
      this.id = user_id;
      this.firstname = fname;
      this.lastname = lname;
      this.email = email;
    },
    updateMyProfile: function() {
      $('ul#errorOnUpdate').html("");
      $("#api-wait").removeClass("hide_me");
      $("#myProfileErrorDetail").addClass("hide_me");

      var firstname      = $("#firstname").val(),
          lastname       = $("#lastname").val(),
          email          = $("#email").val(),
          password       = $("#password").val(),
          id             = $("#id").val()

      var data = {};
          data.firstname = firstname;
          data.lastname = lastname;
          data.email = email;
          data.id = id;

      if ($("#password").val() != ""){
         data.password = password;
      }

      var settings;

      settings = {
        cache: false,
        data: data,
        dataType: 'json',
        error: this.onError,
        success: this.onSuccess,
        contentType: "application/x-www-form-urlencoded",
        type: "PATCH",
        url: "/update_profile"
      };
      this.sendAJAXRequest(settings);
    },
    onError: function(jqXHR, status, error) {
      var cList = $('ul#errorOnUpdate')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      $("#myProfileErrorDetail").removeClass("hide_me");
      $("#api-wait").addClass("hide_me");
      $("#set_to_load").removeClass("loading");
      return false;
    },
    onSuccess: function(result, status, jqXHR) {
      $.notify({
        message: 'Profile Details has been updated.'
      },{
        type: 'info'
      });
      $("#api-wait").addClass("hide_me");
      $("#password").val("");
      return true;
    },
    initializeTable: function(){
      commandsDataTable = $('#three-datatable').DataTable({
      ajax: {
      url: "/three_accounts",
        dataSrc: function(data) {
          return data.users;
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
        class: "text-center",
        data: function(row, type, set, meta) {
          return '<div class="editThree cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="deleteThree cursor_to_pointer fa fa-trash" data-id="'+ row.id +'"></div>';
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.username;
        }
      },
      {
        class: "text-center",
        data: function(row, type, set, meta) {
          return row.password;
        }
      },
      {
        class: "text-center",
        data: function(row, type, set, meta) {
          return moment(row.created_at).format('MMMM Do YYYY, H:mm:ss');
        },
      },
      ],
      autoWidth: false,
      info: false,
      bPaginate: false,
      lengthChange: false,
      searching: false,
      scrollX: true,
      // stateSave:  true
    });
      this.dataTable = commandsDataTable;
      this.onThreeEditButton();
      this.deleteThree();
   },
   saveThreeModal: function(){
    $('ul#errorOnThree').html("");
    $("#api-wait").removeClass("hide_me");
    $("#body-three-dis *").prop('disabled',true);
    $("#threeErrorDetails").addClass("hide_me");

    var username     = $("#three_username").val(),
        password     = $("#three_password").val(),
        user_id       = $("#user_id").val();

    var data = {};

    data.username = username;
    data.password = password;
    data.user_id = user_id;

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: this.onSaveError,
      success: this.onSaveSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "POST",
      url: "/three_accounts"
    };
    this.sendAJAXRequest(settings);
   },
   onSaveError: function(jqXHR, status, error) {
      var cList = $('ul#errorOnThree')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      $("#threeErrorDetails").removeClass("hide_me");
      $("#api-wait").addClass("hide_me");
      $("#body-three-dis *").prop('disabled', false);
      return false;
   },
   onSaveSuccess: function(result, status, jqXHR) {
    $.notify({
      message: 'Three user has been added.'
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
    onThreeEditButton: function(){
    $(document).on("click", ".editThree", function(){
      var tr = $(this).closest('tr');
      var row = commandsDataTable.row(tr);
      var data = row.data();

      three_user_id = $(this).data("id");

      $("#saveEditModal").attr('data-id', three_user_id);
      $("#edit_three_user_id").val(three_user_id);
      $("#edit_three_username").val(data.username);
      $("#edit_three_password").val(data.password);
      $('#edit_three_user_to_db').modal('show');
    });
   },
   updateThree: function(){
    $("#body-three-edit-dis *").prop('disabled', true);
    $('ul#errorOnEditThree').html("");
    $("#api-wait").removeClass("hide_me");
    $("#threeEditErrorDetails").addClass("hide_me");

    var threeID = $("#edit_three_user_id").val();

    var username = $("#edit_three_username").val(),
    password    = $("#edit_three_password").val();

    var data = {};

    data.username = username;
    data.password = password;
    data.id = threeID;

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: this.onEditError,
      success: this.onEditSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "PATCH",
      url: "/three_accounts"
    };

    vm.sendAJAXRequest(settings);
   },
   onEditError: function(jqXHR, status, error) {
    $("#api-wait").addClass("hide_me");
    $("#body-three-edit-dis *").prop('disabled', false);
    var cList = $('ul#errorOnEditThree')
    $.each(jqXHR.responseJSON.errors, function(index, value) {
      var li = $('<li/>')
      .text(value)
      .appendTo(cList);
    });
    $("#threeEditErrorDetails").removeClass("hide_me");
    return false;
   },
   onEditSuccess: function(result, status, jqXHR) {
    $.notify({
      message: 'Three user has been updated.'
    },{
      type: 'info'
    });
    $("#api-wait").addClass("hide_me");
    this.editClearFrom();
    $("#edit_three_user_to_db").modal("hide");
    this.dataTable.ajax.reload();
    return true;
   },
   deleteThree: function(){
    $(document).on("click", ".deleteThree", function() {
      var threeRow, result;
      result = confirm("Are you sure to delete this three user?");
      if (result === false) {
        return;
      }
      threeRow = $(this).parents('tr');
      threeID = $(this).attr('data-id');

      var data = {};
      data.id = threeID;
      var settings;

      settings = {
        cache: false,
        data: data,
        dataType: 'json',
        error: function(){return false},
        success: function(){
          this.threeRow.remove();
          $.notify({
            message: 'Three user has been deleted.'
          },{
            type: 'info'
          });
          return true;
        },
        contentType: "application/x-www-form-urlencoded",
        context: {threeRow: threeRow},
        type: "DELETE",
        url: "/three_accounts/" + threeID
      };

      vm.sendAJAXRequest(settings);
    });
   },
   editClearFrom: function() {
    $("#edit_three_username").val("");
    $("#edit_three_password").val("");
    $('ul#errorOnEditThree').html("");
    $("#body-three-edit-dis *").prop('disabled', false);
    $("#threeEditErrorDetails").addClass("hide_me");
   },
   clearForm: function(){
    $("#three_username").val("");
    $("#three_password").val("");
    $('ul#errorOnThree').html("");
    $("#body-three-dis *").prop('disabled', false);
    $("#threeErrorDetails").addClass("hide_me");
   },
   showHideColumns: function(column){
    var column = this.dataTable.column(column);
    column.visible( ! column.visible() );
   },
   onUserButton: function(){
    $('.add_user_to_db').modal('show');
   }
  }
});
vm.initializeTable();