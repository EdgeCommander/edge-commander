<template>
  <div style="float: right; margin-right: 5px;">
  	<a href="javascript:void(0)"  class="btn btn-primary m-btn m-btn--icon" @click="show_model()">
	  <span>
	      <i class="fa fa-plus-square"></i>
	      <span>Add Rule</span>
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
                    <img src="../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
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
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.name}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="rule_name" aria-describedby="emailHelp" placeholder="Test Usage." v-model="rule_name">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.category}}
                            </label>
                            <div class="col-4">
                                <select class="form-control m-input" id="rule_category" v-model="rule_category" style="height: 33px !important;">
                                    <option value="usage_command">Internet usage in %</option>
                                    <option value="daily_sms_usage_command">Total SMS in a day</option>
                                    <option value="monthly_sms_usage_command">Total SMS in a monthly</option>
                                    <option value="battery_voltages_command">Battery voltage in volts</option>
                                </select>
                            </div>
                            <div class="col-4">
                              <select class="form-control m-input" id="rule_variable" v-model="rule_variable" style="height: 33px !important;">
                                <option value="greater_than">Greater than (>)</option>
                                <option value="greater_than_equal_to">Greater than or equal to (>=)</option>
                                <option value="less_than">Less than (<)</option>
                                <option value="less_than_equal_to">Less than or equal to (<=)</option>
                                <option value="equals_to">Equals to (==)</option>
                              </select>
                            </div>
                            <div class="col-2">
                              <input type="number" min="0" class="form-control m-input m-input--solid" id="rule_value"  aria-describedby="emailHelp" placeholder="10" v-model="rule_value">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.recipients}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="rule_recipients" aria-describedby="emailHelp" placeholder="test@user.com,who@am.io" v-model="rule_recipients">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                            </label>
                            <div class="col-10">
                                <label class="m-checkbox">
                                    <input type="checkbox" id="rule_is_active" v-model="rule_is_active">
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
  props: ["ruleData"],
  data: () => {
    return {
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
			show_loading: false,
      show_errors: false,
      show_add_messages: "",
      show_loading: false,
      show_add_errors: false,
      rule_name: "",
      rule_category: "",
      rule_variable: "",
      rule_value: "",
      rule_recipients: "",
      rule_is_active: false
    }
  },

  watch: {
    ruleData() {
      this.updatePropsValue(this.ruleData)
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

      let recipients = this.rule_recipients
      if (recipients != "") {
        recipients = recipients.split(",");
      }else{
        recipients = "";
      }

      this.$http.post('/rules/new', {
        rule_name: this.rule_name,
        user_id:  this.$root.user_id,
        category: this.rule_category,
        variable: this.rule_variable,
        value: this.rule_value,
        recipients: recipients,
        is_active: this.rule_is_active
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
      this.rule_name = "";
      this.rule_category = "";
      this.rule_variable = "";
      this.rule_value = "";
      this.rule_recipients = "";
      this.rule_is_active = false;
      this.show_add_errors = false;
      this.$events.fire("router-added", {})
    }
  }
}
</script>