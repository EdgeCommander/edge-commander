var vm = new Vue({
  el: '#sharing_main',
  data: {
    dataTable: null,
    m_form_search: "",
    show_loading: false,
    show_errors: false,
    headings: [
      {column: "Actions", id: "actions"},
      {column: "Account of", id: "account_of_id"},
      {column: "Share With", id: "member_email"},
      {column: "Share by", id: "user_id"},
      {column: "Role", id: "role"}
    ],
    form_labels: {
      member_email: "Share With",
      role: "Role",
      choose_account: "Account of",
      submit_button: "Save changes",
      add_title: "Share Account with",
      hide_show_title: "Show/Hide Columns",
      add_sharing_button: "Share to others",
      hide_show_button: "OK"
    },
    role: 1,
    account_of_id: "",
  },
  methods: {
    initializeTable: function(){
      sharingDataTable = $('#members-datatable').DataTable({
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
      url: "/members",
        dataSrc: function(data) {
          return data.members;
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
        class: "text-center actions",
        data: function(row, type, set, meta) {
          return '<div id="action_btn"><div class="cursor_to_pointer fa fa-trash" data-id="'+ row.id +'" onclick="vms.deleteMember('+row.id+', this.parentNode.parentNode.parentNode)"></div></div>';
        }
      },
      {
        class: "account_of_id",
        data: function(row, type, set, meta) {
          return "<b>"+row.account_of_name+"</b></br>" + row.account_of_email;
        }
      },
      {
        class: "member_email",
        data: function(row, type, set, meta) {
          member_name = row.member_name;
          color = "";
          if(member_name == 'Pending....'){
            color = "red";
          }
            return "<b style='color:"+color+"'>"+row.member_name+"</b></br>" + row.member_email;
        }
      },
      {
        class: "user_id",
        data: function(row, type, set, meta) {
          return "<b>"+row.share_by_name+"</b></br>" + row.share_by_email;
        }
      },
      {
        class: "text-center role",
        data: function(row, type, set, meta) {
          role = row.role;
          if(role == 1){
            return "Full Rights";
          }else{
            return "Read-Only";
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
      stateSave:  true
    });
      this.dataTable = sharingDataTable;
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
   onMemberButton: function(){
    $('.add_member_to_db').modal('show');
   },
   onMemeberHideShowButton: function(){
    $('.toggle-datatable-columns').modal('show');
   },
   clearForm: function(){
    $("#member_email").val('').trigger('change')
    this.account_of_id = "";
    this.role = 1;
    $('ul#errorOnMember').html("");
    $("#body-member-dis *").prop('disabled', false);
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
    $('ul#errorOnMember').html("");
    this.show_loading = true;
    $("#body-member-dis *").prop('disabled',true);
    this.show_errors = true;

    member_email = $( "#member_email option:selected" ).text()

    var user_id      = this.user_id,
        member_email = member_email,
        role         = this.role,
        account_of_id = this.account_of_id

    var data = {};
   
    data.user_id = user_id;
    data.member_email = member_email;
    data.role = role
    data.account_of_id = account_of_id

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: this.onSaveError,
      success: this.onSaveSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "POST",
      url: "/members/new"
    };
    vm.sendAJAXRequest(settings);
   },
   onSaveError: function(jqXHR, status, error) {
      var cList = $('ul#errorOnMember')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      this.show_loading = false;
      $("#body-member-dis *").prop('disabled', false);
      return false;
   },
   onSaveSuccess: function(result, status, jqXHR) {
    $.notify({
      message: 'Member has been added.'
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
      $(".member-column").each(function(){
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

var vms = new Vue({
  el: '#action_btn',
  data: {},
  methods: {
     deleteMember: function(memberID, memberRow){
      var memberRow, result;
      result = confirm("Are you sure to delete this Member?");
      if (result === false) {
        return;
      }
      var data = {};
      data.id = memberID;
      var settings;

      settings = {
        cache: false,
        data: data,
        dataType: 'json',
        error: function(){return false},
        success: function(){
          this.memberRow.remove();
          $.notify({
            message: 'Member has been deleted.'
          },{
            type: 'info'
          });
          return true;
        },
        contentType: "application/x-www-form-urlencoded",
        context: {memberRow: memberRow},
        type: "DELETE",
        url: "/members/" + memberID
      };
      vm.sendAJAXRequest(settings);
     }
  }
});

$('.js-example-basic-single').select2({
  closeOnSelect: true,
  tokenSeparators: [',', ';', ' '],
  maximumSelectionLength: 1
});