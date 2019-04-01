<template>
  <div style="float: right; margin-right: 5px;">
  	<a href="javascript:void(0)"  class="btn btn-primary m-btn m-btn--icon" @click="show_model()">
	  <span>
	      <i class="fa fa-plus-square"></i>
	      <span>Add Router</span>
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
                <div class="modal-body" id="body-router-dis">
                    <img src="../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                    <div id="routerErrorDetails" v-if="show_add_errors">
                        <div class="form-group m-form__group m--margin-top-10">
                          <ul  class="error_panel">
                            <li v-for="message in show_add_messages">{{message}}</li>
                          </ul>
                        </div>
                    </div>
                    <div class="m-form m-form--fit m-form--label-align-left">
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
                    <button id="" type="button" class="btn btn-default" @click="saveData($event)">
                        {{form_labels.submit_button}}
                    </button>
                </div>
            </div>
        </div>
    </div>
   
  </div>
</template>

<style scoped>

</style>

<script>
import jQuery from 'jquery'
export default {
  props: ["routerData"],
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
			show_loading: false,
      show_errors: false,
      show_add_messages: "",
      show_loading: false,
      show_add_errors: false,
      router_name: "",
      router_ip: "",
      router_username: "",
      router_password: "",
      http_router_port: "",
      router_is_monitoring: false
    }
  },

  watch: {
    routerData() {
      this.updatePropsValue(this.routerData)
    }
  },
  methods: {
    updatePropsValue(router) {
      this.router_name = router.name
      this.router_ip = router.ip
      this.router_username = router.username
      this.router_password = router.password
      this.http_router_port = router.port
      this.router_is_monitoring = router.is_monitoring
    },
    saveData (e) {
      this.show_loading = true;
      this.show_add_errors = true;
      this.$http.post('/routers', {
        name: this.router_name,
        ip:  this.router_ip,
        username: this.router_username,
        password: this.router_password,
        port: this.http_router_port,
        is_monitoring: this.router_is_monitoring,
        user_id: this.$root.user_id
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'Router has been added.'});
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
			this.router_name = "";
      this.router_ip = "";
      this.router_username = "";
      this.router_password = "";
      this.http_router_port = "";
      this.router_is_monitoring = false;
      this.show_add_errors = false;
      this.$events.fire("router-added", {})
    }
  }
}
</script>