<template>
  <div style="float: right; margin-right: 5px;">
  	<a href="javascript:void(0)"  class="btn btn-primary m-btn m-btn--icon" @click="show_model()">
	  <span>
	      <i class="fa fa-plus-square"></i>
	      <span>Add Battery</span>
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
                          <ul class="error_panel">
                            <li v-for="message in show_add_messages">{{message}}</li>
                          </ul>
                        </div>
                    </div>
                    <div class="m-form m-form--fit m-form--label-align-left">
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.name}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="battery_name" v-model="battery_name">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                                {{form_labels.battery_source_url}}
                            </label>
                            <div class="col-10">
                                <input type="text" class="form-control m-input m-input--solid" id="battery_source_url"  v-model="battery_source_url">
                            </div>
                        </div>
                         <div class="form-group m-form__group row">
                            <label class="col-2 col-form-label">
                            </label>
                            <div class="col-10">
                                <label class="m-checkbox">
                                    <input type="checkbox" id="battery_is_active" v-model="battery_is_active">
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
  props: ["batteryData"],
  data: () => {
    return {
      form_labels: {
        name: "Name",
        battery_source_url: "Source URL",
        submit_button: "Save changes",
        edit_title: "Edit Battery",
        add_title: "Add Battery",
        hide_show_title: "Show/Hide Columns",
        add_battery_button: "Add Battery",
        hide_show_button: "OK",
        status: "Active"
      },
			show_loading: false,
      show_errors: false,
      show_add_messages: "",
      show_loading: false,
      show_add_errors: false,
      battery_name: "",
      battery_source_url: "",
      battery_is_active: false
    }
  },

  watch: {
    batteryData() {
      this.updatePropsValue(this.batteryData)
    }
  },
  methods: {
    updatePropsValue(battery) {
      this.battery_name = battery.name
      this.battery_source_url = battery.source_url
      this.battery_is_active = battery.active
    },
    saveData (e) {
      this.show_loading = true;
      this.$http.post('/battery/new', {
        name: this.battery_name,
        user_id:  this.$root.user_id,
        source_url: this.battery_source_url,
        active: this.battery_is_active
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'Battery has been added.'});
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
      this.$events.fire("battery-added", {})
    }
  }
}
</script>