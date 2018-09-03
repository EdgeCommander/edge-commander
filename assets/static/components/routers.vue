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
                  <div class="col-md-4">
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
                  <a href="javascript:void(0)" id="addROUTER" class="btn btn-primary m-btn m-btn--icon" v-on:click="onROUTERButton">
                      <span>
                          <i class="fa fa-plus-square"></i>
                          <span>
                              {{form_labels.add_router_button}}
                          </span>
                      </span>
                  </a>
                  <div href="javascript:void(0)" class="btn btn-default grey" v-on:click="onROUTERHideShowButton">
                    <i class="fa fa-columns"></i>
                  </div>
              </div>
            </div>
          </div>
          <!--end: Search Form -->
          <table id="data-table" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
              <thead>
                  <tr>
                      <th v-for="(item, index) in headings" v-bind:class="item.class">{{item.column}}</th>
                  </tr>
              </thead>
              <tbody>
                  <tr v-for="record in table_records">
                    <td class="text-center actions">
                      <div class="cursor_to_pointer fa fa-edit" v-on:click="onRouterEditButton(record)"></div>
                      <div class="cursor_to_pointer fa fa-trash" v-on:click="deleteRouter(record.id, $event)"></div>
                    </td>
                    <td class="rule_name">{{record.name}}</td>
                    <td class="active">{{record.ip}}</td>
                    <td class="text-center category">{{record.http_port}}</td>
                    <td class="text-center category">{{record.username}}</td>
                    <td class="text-center category">{{record.password}}</td>
                    <td class="text-center category">{{record.monitoring}}</td>
                    <td class="text-center created_at">{{record.created_at | formatDate}}</td>
                  </tr>
                </tbody>
            </table>
        </div>
      </div>
    </div>
    <div class="modal fade add_router_to_db" ref="addmodal" style="padding: 0px;" id="m_modal_1" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
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
              <div class="modal-body" id="body-router-dis">
                  <img src="/images/loading.gif" id="api-wait" v-if="show_loading">
                  <div id="routerErrorDetails" v-if="show_add_errors">
                      <div class="form-group m-form__group m--margin-top-10">
                          <div class="alert m-alert m-alert--default" role="alert">
                               <li v-for="message in show_add_messages">{{message}}</li>
                          </div>
                      </div>
                  </div>
                  <div class="m-form m-form--fit m-form--label-align-left">
                      <input type="hidden" id="user_id" v-model="user_id">
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.name}}
                          </label>
                          <div class="col-9">
                             <input type="text" class="form-control m-input m-input--solid" id="router_name" v-model="router_name" aria-describedby="emailHelp" placeholder="Galway route.">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.ip}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="router_ip" v-model="router_ip" placeholder="https://youripmaybe">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.username}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="router_username" v-model="router_username" placeholder="i.e admin">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.password}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="router_password" v-model="router_password" placeholder="Super Secret">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.http_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="http_router_port" v-model="http_router_port" placeholder="i.e 80">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                          </label>
                          <div class="col-9">
                              <label class="m-checkbox">
                                  <input type="checkbox" id="router_is_monitoring" v-model="router_is_monitoring">
                                  {{form_labels.status}}
                                  <span></span>
                              </label>
                          </div>
                      </div>
                  </div>
                  <!--end::Form-->
              </div>
              <div class="modal-footer">
                  <button id="" type="button" class="btn btn-default" v-on:click="saveModal">
                      {{form_labels.submit_button}}
                  </button>
              </div>
          </div>
      </div>
    </div>
    <div class="modal fade" id="edit_router_to_db" ref="editmodal" style="padding: 0px;" data-backdrop="static" data-keyboard="false">
      <div class="modal-dialog" role="document">
          <div class="modal-content" style="padding: 0px;">
              <div class="modal-header">
                  <h5 class="modal-title" id="exampleModalLabel">
                      {{form_labels.edit_title}}
                  </h5>
                  <div class="cancel">
                      <a href="#" id="discardEditModal" data-dismiss="modal" v-on:click="editClearFrom">X</a>
                  </div>
              </div>
              <div class="modal-body" id="body-router-edit-dis">
                  <img src="/images/loading.gif" id="api-wait" v-if="show_loading">
                   <div id="routerEditErrorDetails" v-if="show_edit_errors">
                      <div class="form-group m-form__group m--margin-top-10">
                          <div class="alert m-alert m-alert--default" role="alert">
                               <li v-for="message in show_edit_messages">{{message}}</li>
                          </div>
                      </div>
                  </div>
                  <div class="m-form m-form--fit m-form--label-align-left">
                      <input type="hidden" id="user_id"  v-model="user_id">
                      <input type="hidden" id="edit_router_id"  v-model="edit_router_id">
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.name}}
                          </label>
                          <div class="col-9">
                             <input type="text" class="form-control m-input m-input--solid" id="edit_router_name" v-model="edit_router_name" aria-describedby="emailHelp" placeholder="Galway route.">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.ip}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="edit_router_ip" v-model="edit_router_ip" placeholder="https://youripmaybe">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.username}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="edit_router_username" v-model="edit_router_username" placeholder="i.e admin">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.password}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="edit_router_password" v-model="edit_router_password" placeholder="Super Secret">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.http_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="edit_http_router_port" v-model="edit_http_router_port" placeholder="i.e 80">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                          </label>
                          <div class="col-9">
                              <label class="m-checkbox">
                                  <input type="checkbox" id="edit_router_is_monitoring" v-model="edit_router_is_monitoring">
                                  {{form_labels.status}}
                                  <span></span>
                              </label>
                          </div>
                      </div>
                  </div>
                  <!--end::Form-->
              </div>
              <div class="modal-footer">
                  <button id="" type="button" class="btn btn-default" v-on:click="updateRouterdo">
                      {{form_labels.submit_button}}
                  </button>
              </div>
          </div>
      </div>
    </div>
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
                <div class="form-group" >
                   <div class="column-checkbox" v-for="(item, index) in headings">
                    <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;"><input type="checkbox" class="users-column" checked="checked" v-bind:id="index" v-bind:name="item.id" v-on:change="showHideColumns(index)"><span></span> {{item.column}}</label>
                  </div>
                </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-default" data-dismiss="modal">{{form_labels.hide_show_button}}</button>
            </div>
        </div>
    </div>
  </div>
  <!--end::Modal-->
  </div>
</template>

<script>
module.exports = {
  name: 'routers',
  data: function(){
    return{
      dataTable: null,
      m_form_search: "",
      show_loading: false,
      show_add_errors: false,
      show_edit_errors: false,
      show_add_messages: "",
      table_records: "",
      show_edit_messages: "",
      headings: [
        {column: "Actions", id: "actions", class: "text-center"},
        {column: "Name", id: "name"},
        {column: "IP", id: "ip"},
        {column: "HTTP Port", id: "http_port", class: "text-center"},
        {column: "Username", id: "username", class: "text-center"},
        {column: "Password", id: "password", class: "text-center"},
        {column: "Monitoring", id: "monitoring", class: "text-center"},
        {column: "Created At", id: "created_at", class: "text-center"},
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
    }
  },
  filters:{
    formatDate: function(value){
      return moment(String(value)).format('DD/MM/YYYY HH:mm:ss')
    }
  },
  methods: {
    initDatatable: function(){
      this.$http.get('/routers/data').then(
        response => {
          this.table_records = response.body.routers
          $("#data-table .dataTables_empty").hide();
        }).catch(function(error){
        console.log(error)
      })
   },
   get_session: function(){
    this.$http.get('/get_porfile').then(response => {
      this.user_id = response.body.id;
    });
   },
   onROUTERButton: function(){
     $(this.$refs.addmodal).modal("show");
   },
   saveModal: function() {
      this.show_loading = true;
      this.show_add_errors = true;

      this.$http.post('/routers', {
        name: this.router_name,
        ip:  this.router_ip,
        username: this.router_username,
        password: this.router_password,
        port: this.http_router_port,
        is_monitoring: this.router_is_monitoring,
        user_id: this.user_id
      }).then(function (response) {
        $.notify({message: 'Router has been added.'},{type: 'info'});
        this.show_loading = false;
        this.initDatatable()
        this.clearForm();
        $(this.$refs.addmodal).modal("hide");
      }).catch(function (error) {
        this.show_add_messages = error.body.errors;
        this.show_add_errors = true;
        this.show_loading = false;
      });
   },
   search: function(){
    this.dataTable.search(this.m_form_search).draw();
   },
   clearForm: function() {
      this.router_name = "";
      this.router_ip = "";
      this.router_username = "";
      this.router_password = "";
      this.http_router_port = "";
      this.router_is_monitoring = false;
      this.show_add_messages = "";
      this.show_add_errors = false;
   },
   onRouterEditButton: function(data){
      this.edit_router_id = data.id
      this.edit_router_name = data.name
      this.edit_router_ip = data.ip
      this.edit_router_username = data.username
      this.edit_router_password = data.password
      this.edit_http_router_port = data.port
      this.edit_router_is_monitoring = data.is_monitoring
      $(this.$refs.editmodal).modal("show");
   },
   updateRouterdo: function(){
        this.show_loading = true;
        this.show_edit_errors = true;

        let routerID = this.edit_router_id;

        this.$http.patch('/routers/'+ routerID , {
          name: this.edit_router_name,
          ip: this.edit_router_ip,
          username: this.edit_router_username,
          password: this.edit_router_password,
          port: this.edit_http_router_port,
          is_monitoring: this.edit_router_is_monitoring,
          id: routerID
        }).then(function (response) {
          $.notify({message: 'Router has been updated.'},{type: 'info'});
          this.show_loading = false;
          this.initDatatable()
          this.editClearFrom();
          $(this.$refs.editmodal).modal("hide");
        }).catch(function (error) {
          this.show_loading = false;
          this.show_edit_messages = error.body.errors;
          this.show_edit_errors = true;
        });
    },
    editClearFrom: function() {
      this.edit_router_id = "";
      this.edit_router_name = "";
      this.edit_router_ip = "";
      this.edit_router_username = "";
      this.edit_router_password = "";
      this.edit_http_router_port = "";
      this.edit_router_is_monitoring = false;
      this.show_loading = false;
      this.show_edit_errors = false;
      this.show_edit_messages = "";
    },
    deleteRouter: function(routerID, event){
      let routerRow, result;
      routerRow = event.target.parentElement.parentElement
      result = confirm("Are you sure to delete this rule?");
      if (result === false) {
        return;
      }
      let data = {};
      data.id = routerID;
      this.$http.delete("/routers/" + routerID, {routerRow: routerRow}).then(function (response) {
        routerRow.remove();
        $.notify({message: 'Router has been deleted.'},{type: 'info'});
      }).catch(function (error) {
         return false
      });
   },
   onROUTERHideShowButton: function(){
      $(this.$refs.hideShow).modal("show");
    },
    showHideColumns: function(id){
    let column = this.dataTable.columns(id);
    if(column.visible()[0] == true){
      column.visible(false);
    }else{
      column.visible(true);
    }
   }
  },
  created() {
    this.initDatatable();
  },
  mounted(){
    this.get_session();
  },
  updated(){
    let dataTable = $('#data-table').DataTable({
      autoWidth: true,
      info: false,
      bPaginate: false,
      lengthChange: false,
      searching: true,
      scrollX: true,
      colReorder: true,
      retrieve: true,
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
      }
    });
    this.dataTable = dataTable;
  }
}
</script>

<style lang="scss">
</style>
