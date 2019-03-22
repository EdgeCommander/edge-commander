<template>
  <div v-if="showModal">
    <transition name="modal">
     <div class="modal modal-mask" style="display: block">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
              <h5 class="modal-title" id="exampleModalLabel">Edit Router</h5>
              <div class="cancel">
                <a href="#" id="discardModal" data-dismiss="modal" @click="hideModal()">X</a>
              </div>
          </div>
          <div class="modal-body" id="body-router-edit-dis">
            <img src="../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
             <div id="routerEditErrorDetails" v-if="show_edit_errors">
                <div class="form-group m-form__group m--margin-top-10">
                  <ul class="error_panel">
                    <li v-for="message in show_edit_messages">{{message}}</li>
                  </ul>
                </div>
            </div>
            <div class="m-form m-form--fit m-form--label-align-left">
                <input type="hidden" id="user_id" v-model="user_id">
                <input type="hidden" v-model="edit_router_id">
                <div class="form-group m-form__group row">
                    <label class="col-3 col-form-label">
                        {{form_labels.name}}
                    </label>
                    <div class="col-9">
                       <input type="text" class="form-control m-input m-input--solid" v-model="edit_router_name"aria-describedby="emailHelp" placeholder="Galway route.">
                    </div>
                </div>
                <div class="form-group m-form__group row">
                    <label class="col-3 col-form-label">
                        {{form_labels.ip}}
                    </label>
                    <div class="col-9">
                        <input type="text" class="form-control m-input m-input--solid" v-model="edit_router_ip"placeholder="https://youripmaybe">
                    </div>
                </div>
                <div class="form-group m-form__group row">
                    <label class="col-3 col-form-label">
                        {{form_labels.username}}
                    </label>
                    <div class="col-9">
                        <input type="text" class="form-control m-input m-input--solid" v-model="edit_router_username" placeholder="i.e admin">
                    </div>
                </div>
                <div class="form-group m-form__group row">
                    <label class="col-3 col-form-label">
                        {{form_labels.password}}
                    </label>
                    <div class="col-9">
                        <input type="text" class="form-control m-input m-input--solid" v-model="edit_router_password"placeholder="Super Secret">
                    </div>
                </div>
                <div class="form-group m-form__group row">
                    <label class="col-3 col-form-label">
                        {{form_labels.http_port}}
                    </label>
                    <div class="col-9">
                        <input type="number" class="form-control m-input m-input--solid" v-model="edit_http_router_port"placeholder="i.e 80">
                    </div>
                </div>
                <div class="form-group m-form__group row">
                    <label class="col-3 col-form-label">
                    </label>
                    <div class="col-9">
                        <label class="m-checkbox">
                            <input type="checkbox" v-model="edit_router_is_monitoring">
                            {{form_labels.status}}
                            <span></span>
                        </label>
                    </div>
                </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-primary" @click="updateData()"> Save </button>
          </div>
        </div>
      </div>
    </div>
    </transition>
  </div>
</template>

<style scoped>
.modal-mask {
   position: fixed;
   z-index: 9998;
   top: 0;
   left: 0;
   width: 100%;
   height: 100%;
   background-color: rgba(0, 0, 0, .5);
   display: table;
   overflow: auto;
   transition: opacity .3s ease;
}

.modal-dialog {
  width: 550px;
  max-width: 100%;
}
</style>

<script>
export default {
  props: ["editData", "showModal"],
  data: () => {
    return {
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
      show_edit_errors: false,
      show_loading: false,
      show_edit_messages: "",
      edit_router_id: "",
      edit_router_name: "",
      edit_router_ip: "",
      edit_router_username: "",
      edit_router_password: "",
      edit_http_router_port: "",
      edit_router_is_monitoring:  false
    }
  },

  watch: {
    editData() {
      this.edit_router_name = this.editData.name
      this.edit_router_ip = this.editData.ip
      this.edit_router_username = this.editData.username
      this.edit_router_password = this.editData.password
      this.edit_http_router_port = this.editData.port
      this.edit_router_is_monitoring = this.editData.is_monitoring
      this.edit_router_id = this.editData.id
    }
  },

  methods: {
    updateData (){

      this.show_loading = true;
      let routerID = this.edit_router_id;

      this.$http.patch("/routers/" + routerID, {
        name: this.edit_router_name,
        ip: this.edit_router_ip,
        username: this.edit_router_username,
        password: this.edit_router_password,
        port: this.edit_http_router_port,
        is_monitoring: this.edit_router_is_monitoring,
        id: routerID
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'Router has been updated'});
        this.show_loading = false;
        this.$events.fire("close-modal", false);
        this.$events.fire("refresh-table", true);
      }).catch(function (error) {
        this.show_loading = false;
        this.show_edit_messages = error.body.errors;
        this.show_edit_errors = true;
      });
    },

    hideModal () {
      this.show_loading = false;
      this.show_edit_errors = false;
      this.$events.fire("close-modal", false);
    }
  }
}
</script>