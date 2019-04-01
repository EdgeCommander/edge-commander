<template>
  <div v-if="showNvrModal">
    <transition name="modal">
     <div class="modal modal-mask" style="display: block">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
              <h5 class="modal-title" id="exampleModalLabel">Edit Nvr</h5>
              <div class="cancel">
                <a href="#" id="discardModal" data-dismiss="modal" @click="hideModal()">X</a>
              </div>
          </div>
          <div class="modal-body" id="body-nvr-edit-dis">
                <img src="../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                 <div id="nvrEditErrorDetails" v-if="show_edit_errors">
                    <div class="form-group m-form__group m--margin-top-10">
                      <ul class="error_panel">
                         <li v-for="message in show_edit_messages">{{message}}</li>
                      </ul>
                    </div>
                 </div>

                <div class="m-form m-form--fit m-form--label-align-left">
                    <input type="hidden" id="user_id"  v-model="user_id">
                    <input type="hidden" v-model="edit_nvr_id" >
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.name}}
                          </label>
                          <div class="col-9">
                             <input type="text" class="form-control m-input m-input--solid" v-model="edit_nvr_name"  aria-describedby="emailHelp" placeholder="Galway route." >
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.ip}}
                          </label>
                          <div class="col-9">
                             <input type="text" class="form-control m-input m-input--solid" v-model="edit_nvr_ip" placeholder="https://youripmaybe">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.username}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" v-model="edit_nvr_username" placeholder="i.e admin">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.password}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" v-model="edit_nvr_password"placeholder="Super Secret">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.http_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" v-model="edit_http_nvr_port" placeholder="i.e 80">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.rtsp_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" v-model="edit_rtsp_nvr_port"placeholder="i.e 880">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.sdk_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" v-model="edit_sdk_nvr_port"placeholder="i.e 840">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.vh_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" v-model="edit_vh_nvr_port" placeholder="i.e 890">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                          </label>
                          <div class="col-9">
                              <label class="m-checkbox">
                                <input type="checkbox" v-model="edit_nvr_is_monitoring">
                                  {{form_labels.status}}
                                <span></span>
                            </label>
                          </div>
                      </div>
                 </div>
                <!--end::Form-->
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
  props: ["nvrEditData", "showNvrModal"],
  data: () => {
    return {
      form_labels: {
        name: "Name",
        ip: "IP",
        username: "Username",
        password: "Password",
        http_port: "HTTP Port",
        rtsp_port: "RTSP Port",
        sdk_port: "SDK Port",
        vh_port: "VH Port",
        status: "Monitoring",
        add_title: "Add NVR",
        edit_title: "Edit NVR",
        hide_show_title: "Show/Hide Columns",
        add_nvr_button: "Add NVR",
        hide_show_button: "OK",
        submit_button: "Save changes"
     },
      show_edit_errors: false,
      show_loading: false,
      show_edit_messages: "",
      edit_nvr_id: "",
      edit_nvr_name: "",
      edit_nvr_ip: "",
      edit_nvr_username: "",
      edit_nvr_password: "",
      edit_http_nvr_port: "",
      edit_sdk_nvr_port: "",
      edit_vh_nvr_port: "",
      edit_nvr_is_monitoring: "",
      edit_rtsp_nvr_port: ""
    }
  },

  watch: {
    nvrEditData() {
      this.edit_nvr_name = this.nvrEditData.name
      this.edit_nvr_ip = this.nvrEditData.ip
      this.edit_nvr_username = this.nvrEditData.username
      this.edit_nvr_password = this.nvrEditData.password
      this.edit_http_nvr_port = this.nvrEditData.port
      this.edit_sdk_nvr_port = this.nvrEditData.sdk_port
      this.edit_vh_nvr_port = this.nvrEditData.vh_port
      this.edit_nvr_is_monitoring = this.nvrEditData.is_monitoring
      this.edit_rtsp_nvr_port = this.nvrEditData.rtsp_port
      this.edit_nvr_id = this.nvrEditData.id
    }
  },

  methods: {
    updateData (){
      this.show_loading = true;
      let nvrID = this.edit_nvr_id;

      this.$http.patch("/nvrs/" + nvrID, {
        name: this.edit_nvr_name,
        ip: this.edit_nvr_ip,
        username: this.edit_nvr_username,
        password: this.edit_nvr_password,
        port: this.edit_http_nvr_port,
        sdk_port: this.edit_sdk_nvr_port,
        vh_port: this.edit_vh_nvr_port,
        is_monitoring: this.edit_nvr_is_monitoring,
        rtsp_port: this.edit_rtsp_nvr_port,
        id: nvrID
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'NVR has been updated'});
        this.show_loading = false;
        this.$events.fire("close-nvr-modal", false);
        this.$events.fire("refresh-nvr-table", true);
      }).catch(function (error) {
        this.show_loading = false;
        this.show_edit_errors = true;
        this.show_edit_messages = error.body.errors;
      });
    },

    hideModal () {
      this.show_loading = false;
      this.show_edit_errors = false;
      this.$events.fire("close-nvr-modal", false);
    }
  }
}
</script>