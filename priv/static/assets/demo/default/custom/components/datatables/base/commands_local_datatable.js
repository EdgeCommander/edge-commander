var vm = new Vue({
  el: '#commands_main',
  data(){
    return{
       dataTable: null,
       m_form_search: "",
       headings: [
        {column: "Actions", class: "text-center"},
        {column: "Rule Name"},
        {column: "Active"},
        {column: "Category"},
        {column: "Recipients"},
        {column: "Created At"},
       ],
       form_labels: {
        name: "Rule Name",
        category: "Category",
        recipients: "Recipients",
        status: "Active",
        submit_button: "Save changes",
        edit_title: "Edit Rule",
        add_title: "Add Rule",
        hide_show_title: "Show/Hide Columns",
        add_rule_button: "Add Rule",
        hide_show_button: "OK"
       }
    }
  },
  methods: {
    initializeTable: function(){
      commandsDataTable = $('#commands-datatable').DataTable({
      ajax: {
      url: "/rules",
        dataSrc: function(data) {
          return data.rules;
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
        class: "text-center width-80",
        data: function(row, type, set, meta) {
          return '<div class="editRULE cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="deleteRULE cursor_to_pointer fa fa-trash" data-id="'+ row.id +'"></div>';
        }
      },
      {
        class: "width-180",
        data: function(row, type, set, meta) {
          return row.rule_name;
        }
      },
      {
        class: "text-center width-10",
        data: function(row, type, set, meta) {
          return row.active;
        }
      },
      {
        class: "text-center width-180",
        data: function(row, type, set, meta) {
          return row.category;
        }
      },
      {
        class: "width-180",
        data: function(row, type, set, meta) {
          return row.recipients;
        }
      },
      {
        class: "text-center width-150",
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
      this.dataTable = commandsDataTable;
      this.onRuleEditButton();
      this.deleteRULE();
   },
    search: function(){
      this.dataTable.search(this.m_form_search).draw();
    },
    onRuleEditButton: function(){
    $(document).on("click", ".editRULE", function(){
      var tr = $(this).closest('tr');
      var row = commandsDataTable.row(tr);
      var data = row.data();

      rule_id = $(this).data("id");

      $("#saveEditModal").attr('data-id', rule_id);
      $("#edit_rule_id").val(rule_id);
      $("#edit_rule_name").val(data.rule_name);
      $("#edit_rule_category").val(data.category);
      $("#edit_rule_recipients").val(data.recipients);
      if (data.active) {
        $('#edit_rule_is_active').prop('checked', true);
      }
      $('#edit_rule_to_db').modal('show');
    });
   },
   showHideColumns: function(column){
    var column = this.dataTable.column(column);
    column.visible( ! column.visible() );
    this.resizeScreen();
   },
   onRuleButton: function(){
    $('.add_rule_to_db').modal('show');
   },
   clearForm: function(){
    $("#rule_name").val("");
    $("#rule_recipients").val("");
    $('ul#errorOnRULE').html("");
    $("#body-rule-dis *").prop('disabled', false);
    $("#ruleErrorDetails").addClass("hide_me");
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
   saveModal: function(){
    $('ul#errorOnRULE').html("");
    $("#api-wait").removeClass("hide_me");
    $("#body-rule-dis *").prop('disabled',true);
    $("#ruleErrorDetails").addClass("hide_me");

    var rule_name     = $("#rule_name").val(),
        user_id       = $("#user_id").val(),
        category      = $('#rule_category').find(":selected").val(),
        recipients    = $("#rule_recipients").val(),
        is_active = $('input[id=rule_is_active]:checked').length > 0;

    var data = {};
    if (recipients != "") {
      data.recipients = recipients.split(",");
    } else
    {
      data.recipients = "";
    }
    data.rule_name = rule_name;
    data.category = category;
    data.active = is_active;
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
      url: "/rules/new"
    };
    this.sendAJAXRequest(settings);
   },
   onSaveError: function(jqXHR, status, error) {
      var cList = $('ul#errorOnRULE')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      $("#ruleErrorDetails").removeClass("hide_me");
      $("#api-wait").addClass("hide_me");
      $("#body-rule-dis *").prop('disabled', false);
      return false;
   },
   onSaveSuccess: function(result, status, jqXHR) {
    $.notify({
      message: 'Rule has been added.'
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
   deleteRULE: function(){
    $(document).on("click", ".deleteRULE", function() {
      var ruleRow, result;
      result = confirm("Are you sure to delete this Rule?");
      if (result === false) {
        return;
      }
      ruleRow = $(this).parents('tr');
      ruleID = $(this).attr('data-id');

      var data = {};
      data.id = ruleID;
      var settings;

      settings = {
        cache: false,
        data: data,
        dataType: 'json',
        error: function(){return false},
        success: function(){
          this.ruleRow.remove();
          $.notify({
            message: 'Rule has been deleted.'
          },{
            type: 'info'
          });
          return true;
        },
        contentType: "application/x-www-form-urlencoded",
        context: {ruleRow: ruleRow},
        type: "DELETE",
        url: "/rules/" + ruleID
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
   updateRule: function(){
    $("#body-rule-edit-dis *").prop('disabled', true);
    $('ul#errorOnEditRULE').html("");
    $("#api-wait").removeClass("hide_me");
    $("#ruleEditErrorDetails").addClass("hide_me");

    var ruleID = $("#edit_rule_id").val();

    var rule_name = $("#edit_rule_name").val(),
    category      = $('#edit_rule_category').find(":selected").val(),
    recipients    = $("#edit_rule_recipients").val(),
    is_active = $('input[id=edit_rule_is_active]:checked').length > 0;

    var data = {};
    if (recipients != "") {
      data.recipients = recipients.split(",");
    }else{
      data.recipients = "";
    }
    data.rule_name = rule_name;
    data.category = category;
    data.active = is_active;
    data.id = ruleID;

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: this.onEditError,
      success: this.onEditSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "PATCH",
      url: "/rules/update"
    };

    this.sendAJAXRequest(settings);
   },
   onEditError: function(jqXHR, status, error) {
    $("#api-wait").addClass("hide_me");
    $("#body-rule-edit-dis *").prop('disabled', false);
    var cList = $('ul#errorOnEditRULE')
    $.each(jqXHR.responseJSON.errors, function(index, value) {
      var li = $('<li/>')
      .text(value)
      .appendTo(cList);
    });
    $("#ruleEditErrorDetails").removeClass("hide_me");
    return false;
   },
   onEditSuccess: function(result, status, jqXHR) {
    $.notify({
      message: 'Rule has been updated.'
    },{
      type: 'info'
    });
    $("#api-wait").addClass("hide_me");
    this.editClearFrom();
    $("#edit_rule_to_db").modal("hide");
    this.dataTable.ajax.reload();
    return true;
   },
   editClearFrom: function() {
    $("#edit_rule_name").val("");
    $('ul#errorOnEditRULE').html("");
    $("#body-rule-edit-dis *").prop('disabled', false);
    $("#ruleEditErrorDetails").addClass("hide_me");
   },
   resizeScreen: function(){
    $('#double-scroll').doubleScroll();
    var table_width = $("#commands-datatable").width();
    $(".doubleScroll-scroll").width(table_width);
   }
  }, // end of methods
   mounted(){
    this.initializeTable()
    this.resizeScreen()
    window.addEventListener('resize', this.resizeScreen);
   }
});
