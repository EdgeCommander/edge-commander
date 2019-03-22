<template>
  <div style="float: right; margin-right: 5px;">
  	<a href="javascript:void(0)"  class="btn btn-primary m-btn m-btn--icon" @click="show_model()">
	  <span>
	      <i class="fa fa-plus-square"></i>
	      <span>Add Nvr</span>
	  </span>
	</a>
	<div class="modal fade" id="addModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
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
                 <div class="modal-body" id="body-nvr-dis">
                <img src="../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                <div id="nvrErrorDetails" v-if="show_add_errors">
                    <div class="form-group m-form__group m--margin-top-10">
                      <ul class="error_panel">
                         <li v-for="message in show_add_messages">{{message}}</li>
                      </ul>
                    </div>
                </div>
                 <div class="m-form m-form--fit m-form--label-align-left">
                    <input type="hidden" id="user_id"  v-model="user_id">
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                               {{form_labels.name}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid"  id="nvr_name" aria-describedby="emailHelp" v-model="nvr_name" placeholder="Galway route.">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.ip}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="nvr_ip" v-model="nvr_ip" placeholder="https://youripmaybe">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.username}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="nvr_username" v-model="nvr_username" placeholder="i.e admin">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.password}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" id="nvr_password" v-model="nvr_password" placeholder="Super Secret">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.http_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="http_nvr_port" v-model="http_nvr_port" placeholder="i.e 80">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.rtsp_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="rtsp_nvr_port" v-model="rtsp_nvr_port" placeholder="i.e 880">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.sdk_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="sdk_nvr_port" v-model="sdk_nvr_port" placeholder="i.e 840">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.vh_port}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" id="vh_nvr_port" v-model="vh_nvr_port" placeholder="i.e 890">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                          </label>
                          <div class="col-9">
                              <label class="m-checkbox">
                                <input type="checkbox" id="nvr_is_monitoring"  v-model="nvr_is_monitoring">
                                {{form_labels.status}}
                                <span></span>
                            </label>
                          </div>
                      </div>
                 </div>
                <!--end::Form-->
            </div>
                <div class="modal-footer">
                    <button id="" type="button" class="btn btn-default" @click="saveData($event)">
                        {{form_labels.submit_button}}
                    </button>
                </div>
            </div>
        </div>
    </div>
   
  </div>
</template>

<script>
import jQuery from 'jquery'
export default {
  props: ["nvrData"],
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
      show_loading: false,
      show_add_errors: false,
      show_add_messages: "",
      show_loading: false,
      nvr_name: "",
      nvr_ip: "",
      nvr_username: "",
      nvr_password: "",
      http_nvr_port: "",
      sdk_nvr_port: "",
      vh_nvr_port: "",
      rtsp_nvr_port: "",
      user_id: 1,
      nvr_is_monitoring: ""
    }
  },

  watch: {
    nvrData() {
      this.updatePropsValue(this.nvrData)
    }
  },
  methods: {
    updatePropsValue(nvr) {
      this.nvr_name = nvr.name,
      this.nvr_ip = nvr.ip,
      this.username = nvr.username
      this.password = nvr.password
      this.http_nvr_port = nvr.port
      this.sdk_nvr_port = nvr.sdk_port
      this.vh_nvr_port = nvr.vh_port
      this.rtsp_nvr_port = nvr.rtsp_port
      this.nvr_is_monitoring = nvr.is_monitoring
      this.user_id = nvr.user_id
    },
    saveData (e) {
      this.show_loading = true;
      this.show_add_errors = true;

      this.$http.post('/nvrs', {
        name: this.nvr_name,
        ip:  this.nvr_ip,
        username: this.nvr_username,
        password: this.nvr_password,
        port: this.http_nvr_port,
        sdk_port: this.sdk_nvr_port,
        vh_port: this.vh_nvr_port,
        rtsp_port: this.rtsp_nvr_port,
        is_monitoring: this.nvr_is_monitoring,
        user_id: this.user_id
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'NVR has been added.'});
        this.clearForm()
        jQuery('#addModel').modal('hide')
      }).catch(function (error) {
        this.show_add_messages = error.body.errors;
        this.show_add_errors = true;
        this.show_loading = false;
      });
    },
    show_model(){
		  jQuery('#addModel').modal('show')
    },
    clearForm () {
			this.nvr_name = "";
      this.nvr_ip = "";
      this.nvr_username = "";
      this.nvr_password = "";
      this.http_nvr_port = "";
      this.sdk_nvr_port = "";
      this.vh_nvr_port = "";
      this.rtsp_nvr_port = "";
      this.nvr_is_monitoring = false;
      this.show_add_errors = false;
      this.show_add_messages = "";
      this.$events.fire("nvr-added", {})
    }
  }
}
</script>