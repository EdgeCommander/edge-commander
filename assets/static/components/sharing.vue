<template>
  <div>
    <div class="m-content">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" style="padding: 10px;">
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right m--margin-bottom-10">
            <div class="row align-items-center">
              <div class="col-md-12">
                <div class="form-group m-form__group row align-items-center">
                  <div class="col-md-12">
                    <div class="m-input-icon m-input-icon--left">
                      <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item">
                            <router-link v-bind:to="'/my_profile'" class="nav-link">My Profile</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/three_users'" class="nav-link">Three Users</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/activities'" class="nav-link">Activities</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/sharing'" class="nav-link active show">Sharing</router-link>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-4 order-1 order-md-2 m--align-right">
              </div>
            </div>
          </div>
          <!--end: Search Form -->
          <div class="heading_panel">
            <div class="pull-left">
            </div>
            <div class="pull-right">
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
            <div class="clearfix"></div>
          </div>
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right m--margin-bottom-10">
            <div class="row align-items-center">
              <div class="col-md-4 order-1 order-md-2 m--align-right">
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
                        <input type="hidden" id="rights" value="1" v-model="rights">
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.sharee_email}}
                            </label>
                            <div class="col-9 sharing_inputs">
                              <input type="text" class="form-control m-input" v-model="sharee_email">
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
import Vue from 'vue'
import App from './App.vue'
const app = new Vue(App)

module.exports = {
  name: 'sharing',
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
        {column: "Share with", visible: "checked", id: "sharee_email"},
        {column: "Shared by", visible: "checked", id: "sharer_email"},
        {column: "Access Type", visible: "checked", id: "rights"}
      ],
      form_labels: {
        sharee_email: "Share With",
        rights: "Rights",
        submit_button: "Share",
        add_title: "Share Account",
        hide_show_title: "Show/Hide Columns",
        add_sharing_button: "Share Details",
        hide_show_button: "OK"
      },
      rights: 1,
      user_id: this.$root.user_id,
      user_email: "",
      sharee_email: ""
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
        class: "sharee_email",
        data: function(row, type, set, meta) {
          return "<span style='font-weight: bold;text-transform: capitalize'>"+row.sharee_name+"</span></br>" + row.sharee_email;
        }
      },
      {
        class: "sharer_email",
        data: function(row, type, set, meta) {
          return "<span style='font-weight: bold;text-transform: capitalize'>"+row.sharer_name+"</span></br>" + row.sharer_email;
        }
      },
      {
        class: "text-center rights",
        data: function(row, type, set, meta) {
          let rights = row.rights;
          if(rights == 1){
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
    this.sharee_email = ""
    this.rights = 1;
    $('ul#errorOnMember').html("");
    this.show_errors = false;
   },
   saveModal: function(){
    this.show_loading = true;
    this.show_errors = true;

    var user_id      = this.user_id,
        sharee_email = this.sharee_email,
        rights         = this.rights

    var data = {};
   
    data.user_id = user_id;
    data.sharee_email = sharee_email;
    data.rights = rights

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
    app.$notify({group: 'notify', title: 'Account has been shared and notify through email.'});
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
    deleteMember: function(){
    $(document).off("click").on("click", ".delShare", function(){
      let memberRow, result;
      memberRow = $(this).closest('tr');
      let memberID = $(this).data("id");

      result = confirm("Are you sure to delete this user account?");
      if (result === false) {
        return;
      }
      app.$http.delete("/members/" + memberID, {memberRow: memberRow}).then(function (response) {
        memberRow.remove();
        app.$notify({group: 'notify', title: 'User account has been deleted.'});
      }).catch(function (error) {
         return false
      });
    });
   },
    active_menu_link: function(){
      $("li").removeClass(" m-menu__item--active");
      $(".settings").addClass(" m-menu__item--active");
      $("#m_aside_left").removeClass("m-aside-left--on");
      $("body").removeClass("m-aside-left--on");
      $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
    }
  }, // end of methods
   mounted(){
    this.deleteMember();
    this.initializeTable();
    this.active_menu_link();
   }
}
</script>

<style lang="scss">
</style>
