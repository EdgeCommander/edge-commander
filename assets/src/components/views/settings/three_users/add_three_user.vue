<template>
  <div style="float: right; margin-right: 5px;">
  	<a href="javascript:void(0)"  class="btn btn-primary m-btn m-btn--icon" @click="show_model()">
	  <span>
	      <i class="fa fa-plus-square"></i>
	      <span>Add Three User</span>
	  </span>
	</a>
	<div class="modal fade" id="addModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content" style="padding: 0px;">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel">
                          {{form_labels.add_title}}
                      </h5>
                    <div class="cancel">
                        <a href="#" id="discardModal" data-dismiss="modal" v-on:click="clearForm">X</a>
                    </div>
                </div>
                <div class="modal-body" id="body-rule-dis">
                    <img src="../../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                    <div id="ruleErrorDetails"  v-if="show_add_errors">
                        <div class="form-group m-form__group m--margin-top-10">
                            <div class="form-group m-form__group m--margin-top-10">
                              <ul  class="error_panel">
                                <li v-for="message in show_add_messages">{{message}}</li>
                              </ul>
                            </div>
                        </div>
                    </div>
                    <div class="m-form m-form--fit m-form--label-align-left">
                        <input type="hidden" v-model="user_id" >
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.username}}
                            </label>
                            <div class="col-9">
                                <input type="text" class="form-control m-input m-input--solid" v-model="username">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.password}}
                            </label>
                            <div class="col-9">
                                <input type="text" class="form-control m-input m-input--solid" v-model="password">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                           {{form_labels.day}}
                          </label>
                          <div class="col-9">
                              <input type="number" class="form-control m-input m-input--solid" v-model="bill_day" min="1" max="31">
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
  props: ["userData"],
  data: () => {
    return {
      form_labels: {
        password: "Password",
        submit_button: "Save changes",
        add_title: "Add new account (three.ie)",
        username: "Username",
        password: "Password",
        day: "Bill Day",
        edit_title: "Edit account details",
        hide_show_title: "Show/Hide Columns",
        hide_show_button: "OK",
      },
			show_loading: false,
      show_errors: false,
      show_add_messages: "",
      show_loading: false,
      show_add_errors: false,
      username: "",
      password: "",
      bill_day: "",
      user_id: 1
    }
  },

  watch: {
    userData() {
      this.updatePropsValue(this.userData)
    }
  },
  methods: {
    updatePropsValue(user) {
      this.username = user.username
      this.password = user.password
      this.bill_day = user.bill_day
      this.user_id = user.user_id
    },
    saveData (e) {
      this.show_loading = true;
      this.$http.post('/three_accounts', {
        username: this.username,
        password: this.password,
        user_id:  this.user_id,
        bill_day: this.bill_day
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'Three user has been added.'});
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
      this.username = "";
      this.password = "";
      this.user_id = "";
      this.bill_day = "";
      this.show_add_errors = false;
      this.show_loading = false;
      this.$events.fire("router-added", {})
    }
  }
}
</script>