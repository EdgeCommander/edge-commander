var vm = new Vue({
  el: '#commands_main',
  data: {
    dataTable: null,
    m_form_search: "",
    show_loading: false,
    show_errors: false,
    show_edit_errors: false,
    headings: [
      {column: "Actions"},
      {column: "Rule Name"},
      {column: "Active"},
      {column: "Category"},
      {column: "Recipients"},
      {column: "Created At"}
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
    },
    edit_rule_name: "",
    edit_rule_id: "",
    edit_rule_category: "",
    edit_rule_recipients: "",
    edit_rule_is_active: false,
    rule_name: "",
    rule_category: "",
    rule_recipients: "",
    rule_is_active: false
  },
  methods: {
    initializeTable: function(){
      commandsDataTable = $('#commands-datatable').DataTable({
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
        class: "text-center",
        data: function(row, type, set, meta) {
          return '<div class="editRULE cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="deleteRule cursor_to_pointer fa fa-trash" data-id="'+ row.id +'"></div>';
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.rule_name;
        }
      },
      {
        class: "text-center",
        data: function(row, type, set, meta) {
          return row.active;
        }
      },
      {
        class: "text-center",
        data: function(row, type, set, meta) {
          return row.category;
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.recipients;
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
      scrollX: true,
      // stateSave:  true,
    });
      this.dataTable = commandsDataTable;
   },
    search: function(){
      this.dataTable.search(this.m_form_search).draw();
    },
    getUniqueIdentifier: function(){
      $(document).on("click", ".editRULE", function(){
        var tr = $(this).closest('tr');
        var row = commandsDataTable.row(tr);
        var data = row.data();
        rule_id = $(this).data("id");
        vm.onRuleEditButton(rule_id, data);
      });
    },
    onRuleEditButton: function(rule_id, data){
      this.edit_rule_name = data.rule_name
      this.edit_rule_id = rule_id
      this.edit_rule_category = data.category
      this.edit_rule_recipients = data.recipients
      if (data.active) {
        this.edit_rule_is_active = true;
      }
      $('#edit_rule_to_db').modal('show');
   },
   showHideColumns: function(column){
    var column = this.dataTable.column(column);
    column.visible( ! column.visible() );
    this.resizeScreen();
   },
   onRuleButton: function(){
    $('.add_rule_to_db').modal('show');
   },
   onRuleHideShowButton: function(){
    $('.toggle-datatable-columns').modal('show');
   },
   clearForm: function(){
    this.rule_name = "";
    this.rule_category = "";
    this.rule_recipients = "";
    this.rule_is_active = false;
    $('ul#errorOnRULE').html("");
    $("#body-rule-dis *").prop('disabled', false);
    this.show_errors = false;
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
    return xhrRequestChangeMonth = $.ajax(settings);
   },
   setUserId: function(id){
    this.user_id = id;
   },
   saveModal: function(){
    $('ul#errorOnRULE').html("");
    this.show_loading = true;
    $("#body-rule-dis *").prop('disabled',true);
    this.show_errors = true;

    var rule_name     = this.rule_name,
        user_id       = this.user_id,
        category      = this.rule_category,
        recipients    = this.rule_recipients,
        is_active     = this.rule_is_active;

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
    vm.sendAJAXRequest(settings);
   },
   onSaveError: function(jqXHR, status, error) {
      var cList = $('ul#errorOnRULE')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      this.show_loading = false;
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
    this.show_loading = false;
    this.dataTable.ajax.reload();
    this.clearForm();
    return true;
   },
   deleteRule: function(){
    $(document).on("click", ".deleteRule", function() {
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

      vm.sendAJAXRequest(settings);
    });
   },
   updateRule: function(){
    $("#body-rule-edit-dis *").prop('disabled', true);
    $('ul#errorOnEditRULE').html("");
    this.show_loading = true;
    this.show_edit_errors = true;

    var ruleID = this.edit_rule_id;

    var rule_name = this.edit_rule_name,
    category      = this.edit_rule_category,
    recipients    = $("#edit_rule_recipients").val(),
    is_active     = this.edit_rule_is_active;

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

    vm.sendAJAXRequest(settings);
   },
   onEditError: function(jqXHR, status, error) {
    this.show_loading = false;
    $("#body-rule-edit-dis *").prop('disabled', false);
    var cList = $('ul#errorOnEditRULE')
    $.each(jqXHR.responseJSON.errors, function(index, value) {
      var li = $('<li/>')
      .text(value)
      .appendTo(cList);
    });
    return false;
   },
   onEditSuccess: function(result, status, jqXHR) {
    $.notify({
      message: 'Rule has been updated.'
    },{
      type: 'info'
    });
    this.show_loading = false;
    this.editClearFrom();
    $("#edit_rule_to_db").modal("hide");
    this.dataTable.ajax.reload();
    return true;
   },
   editClearFrom: function() {
    $('ul#errorOnEditRULE').html("");
    $("#body-rule-edit-dis *").prop('disabled', false);
    this.show_edit_errors = false;
    this.edit_rule_name = ""
    this.edit_rule_recipients = ""
    this.edit_rule_is_active = false
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
    }
  }, // end of methods
   mounted(){
    this.initializeTable();
    this.getUniqueIdentifier();
    this.deleteRule();
    this.resizeScreen();
    window.addEventListener('resize', this.resizeScreen);
   }
});
