<template>
  <div>
    <div class="m-content">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" style="padding: 10px;">
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right m--margin-bottom-10">
            <div class="row align-items-center">
              <div class="col-md-8 order-2 order-md-1">
                <div class="form-group m-form__group row align-items-center">
                  <div class="col-md-5">
                    <div class="m-input-icon m-input-icon--left">
                      <input type="text" class="form-control m-input m-input--solid" placeholder="Search..." id="m_form_search" v-model="m_form_search" v-on:keyup="search()">
                      <span class="m-input-icon__icon m-input-icon__icon--left">
                        <span>
                          <i class="la la-search"></i>
                        </span>
                      </span>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-4 order-1 order-md-2 m--align-right">
                 <a href="javascript:void(0)" class="btn btn-primary m-btn m-btn--icon" v-on:click="onMemberButton">
                      <span>
                          <i class="fa fa-plus-square"></i>
                          <span>
                              {{form_labels.add_sharing_button}}
                          </span>
                      </span>
                  </a>
                  <div href="javascript:void(0)" class="btn btn-default grey" v-on:click="onMemeberHideShowButton">
                    <i class="fa fa-columns"></i>
                  </div>
              </div>
            </div>
          </div>
          <!--end: Search Form -->
          <div>
          </div>
            <table id="members-datatable" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
                <thead>
                    <tr>
                        <th v-for="(item, index) in headings">{{item.column}}</th>
                    </tr>
                </thead>
            </table>
        </div>
      </div>
    </div>
    <!-- begin::modal -->
    <div class="modal fade toggle-datatable-columns" ref="hideShow" style="padding: 0px;" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
      <div class="modal-dialog modal-sm" role="document">
          <div class="modal-content" style="padding: 0px;">
              <div class="modal-header">
                  <h5 class="modal-title" id="exampleModalLabel">
                      {{form_labels.hide_show_title}}
                  </h5>
                  <div class="cancel">
                    <a href="#" id="discardModal" data-dismiss="modal" v-on:click="clearForm">X</a>
                  </div>
              </div>
              <div class="modal-body" id="body-sim-dis">
                  <div class="form-group">
                    <div class="column-checkbox" v-for="(item, index) in headings">
                        <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;"><input type="checkbox" class="sms-column" v-bind:data-id="item.id" v-bind:checked = "item.visible" v-on:change="showHideColumns(item.id)" ><span></span> {{item.column}}</label>
                    </div>
                  </div>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">{{form_labels.hide_show_button}}</button>
              </div>
          </div>
      </div>
    </div>
    <div class="modal fade add_member_to_db" ref="addmodal" style="padding: 0px;" id="m_modal_1" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
        <div class="modal-dialog" role="document">
            <div class="modal-content" style="padding: 0px;">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">
                       {{form_labels.add_title}}
                    </h5>
                    <div class="cancel">
                        <a href="#" id="discardModal" data-dismiss="modal" v-on:click="clearForm">X</a>
                    </div>
                </div>
                <div class="modal-body" id="body-member-dis">
                    <img src="/images/loading.gif" id="api-wait" v-if="show_loading">
                    <div  v-if="show_errors">
                        <div class="form-group m-form__group m--margin-top-10">
                            <div class="alert m-alert m-alert--default" role="alert">
                                <ul style="margin:0px">
                                   <li v-for="message in show_add_messages">{{message}}</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                    <div class="m-form m-form--fit m-form--label-align-left">
                        <input type="hidden" id="user_id"  v-model="user_id">
                        <input type="hidden" id="role" value="1" v-model="role">
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                              {{form_labels.choose_account}}
                            </label>
                            <div class="col-9">
                               <select class="form-control m-input " id="account_id" v-model="account_id">
                                  <option v-bind:value="user_id">{{user_email}} (my account)</option>
                                  <option v-bind:value="shared_user.id" v-for="shared_user in shared_users">{{shared_user.email}}</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.member_email}}
                            </label>
                            <div class="col-9">
                               <select class="js-example-basic-single form-control m-input " id="member_email"  style="width: 100%;" multiple="multiple" data-tags="true" >
                                  <option v-bind:value="other_user.id" v-for="other_user in other_users">{{other_user.email}}</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <!--end::Form-->
                </div>
                <div class="modal-footer" style="padding: 11px;">
                    <button id="" type="button" class="btn btn-default" v-on:click="saveModal">
                        {{form_labels.submit_button}}
                    </button>
                </div>
            </div>
        </div>
    </div>
    <!--end::Modal-->
  </div>
</template>

<script>
module.exports = {
  name: 'shares',
  data: function(){
    return{
      dataTable: null,
      m_form_search: "",
      show_loading: false,
      show_errors: false,
      show_add_messages: "",
      shared_users: "",
      other_users: "",
      headings: [
        {column: "Actions", visible: "checked", id: "actions"},
        {column: "Owner", visible: "checked", id: "account_id"},
        {column: "Share With", visible: "checked", id: "member_email"},
        {column: "Share by", visible: "checked", id: "user_id"},
        {column: "Rights", visible: "checked", id: "role"}
      ],
      form_labels: {
        member_email: "Share With",
        role: "Role",
        choose_account: "Account of",
        submit_button: "Share",
        add_title: "Share Account",
        hide_show_title: "Show/Hide Columns",
        add_sharing_button: "Share Details",
        hide_show_button: "OK"
      },
      role: 1,
      account_id: "",
      user_id: "",
      user_email: ""
    }
  },
  methods: {
    initializeTable: function(){
      let sharingDataTable = $('#members-datatable').DataTable({
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
          return '<div id="action_btn"><div class="cursor_to_pointer fa fa-trash delShare" data-id="'+ row.id +'"></div></div>';
        }
      },
      {
        class: "account_id",
        data: function(row, type, set, meta) {
          return "<b>"+row.account_of_name+"</b></br>" + row.account_of_email;
        }
      },
      {
        class: "member_email",
        data: function(row, type, set, meta) {
          let color;
          let member_name = row.member_name;
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
          let role = row.role;
          if(role == 1){
            return "Full Rights";
          }else{
            return "Read-Only";
          }
        }
      }
      ],
      autoWidth: true,
      info: false,
      bPaginate: false,
      lengthChange: false,
      scrollX: true,
      colReorder: true
    });
      this.dataTable = sharingDataTable;
      this.dataTable.search("");
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
   },
   onMemberButton: function(){
    $(this.$refs.addmodal).modal('show');
   },
   onMemeberHideShowButton: function(){
    $(this.$refs.hideShow).modal("show");
   },
   clearForm: function(){
    $("#member_email").val('').trigger('change')
    this.account_id = "";
    this.role = 1;
    $('ul#errorOnMember').html("");
    this.show_errors = false;
   },
   saveModal: function(){
    this.show_loading = true;
    this.show_errors = true;

    member_email = $( "#member_email option:selected" ).text()

    var user_id      = this.user_id,
        member_email = member_email,
        role         = this.role,
        account_id = this.account_id

    var data = {};
   
    data.user_id = user_id;
    data.member_email = member_email;
    data.role = role
    data.account_id = account_id

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
     $.ajax(settings)
   },
   onSaveError: function(jqXHR, status, error) {
    this.show_add_messages = jqXHR.responseJSON.errors
    this.show_loading = false;
    return false;
   },
   onSaveSuccess: function(result, status, jqXHR) {
    $.notify({message: 'Member has been added.'},{type: 'info'});
    $(this.$refs.addmodal).modal('hide');
    this.show_loading = false;
    this.dataTable.ajax.reload();
    this.clearForm();
    return true;
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
    },
    init_select: function(){
      $('.js-example-basic-single').select2({
        closeOnSelect: true,
        maximumSelectionLength: 1,
        placeholder: "Select an email",
      });
    },
    deleteMember: function(){
      $(document).on("click", ".delShare", function(){
        let memberRow, result, memberID, settings;
        memberRow = $(this).closest('tr');
        memberID = $(this).data("id")
        result = confirm("Are you sure to delete this Member?");
        if (result === false) {
          return;
        }
        let data = {};
        data.id = memberID;

        settings = {
          cache: false,
          data: data,
          dataType: 'json',
          error: function(){return false},
          success: function(){
            memberRow.remove();
            $.notify({message: 'Member has been deleted.'},{type: 'info'});
            return true;
          },
          contentType: "application/x-www-form-urlencoded",
          context: {memberRow: memberRow},
          type: "DELETE",
          url: "/members/" + memberID
        };
        $.ajax(settings)
      });
    },
    get_session: function(){
      this.$http.get('/get_porfile').then(response => {
        this.user_id = response.body.id;
        this.user_email = response.body.email;
      });
    },
    get_shared_users: function(){
      this.$http.get('/get_shared_users').then(response => {
                console.log(response.body.users)
        this.shared_users = response.body.users
      });
    },
    get_other_users: function(){
      this.$http.get('/get_other_users').then(response => {
        this.other_users = response.body.users
      });
    }
  }, // end of methods
   mounted(){
    this.init_select();
    this.initializeTable();
    this.deleteMember();
    this.get_session();
    this.get_shared_users();
    this.get_other_users();
   },
   updated(){
    $('div.alert .close').on('click', function() {$(this).parent().alert('close'); });
    setTimeout(function() {$(".alert-info").alert('close')}, 6000)
   }
}
</script>

<style lang="scss">
</style>
