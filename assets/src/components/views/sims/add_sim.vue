<template>
  <div style="float: right; margin-right: 5px;">
  	<a href="javascript:void(0)"  class="btn btn-primary m-btn m-btn--icon" @click="show_model()">
	  <span>
	      <i class="fa fa-plus-square"></i>
	      <span>Add Sim</span>
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
                <div class="modal-body" id="body-sim-dis">
                    <img src="../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                    <div id="simErrorDetails" v-if="show_errors">
                        <div class="form-group m-form__group m--margin-top-10">
                            <ul class="error_panel">
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
                                <input type="text" class="form-control m-input m-input--solid" id="name" placeholder="i.e IIA Airport" v-model="name">
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.number}}
                            </label>
                            <div class="col-9">
                            	<vue-tel-input v-model="number" @onInput="onInput" inputClasses="form-control" disabledFormatting="true" defaultCountry="ie" placeholder="i.e +353xxxxxx"> </vue-tel-input>
                            </div>
                        </div>
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.sim_provider}}
                            </label>
                            <div class="col-9">
                                <select class="form-control m-input" id="sim_provider" v-model="sim_provider">
                                    <option value="Lyca Mobile (Ireland)">Lyca Mobile (Ireland)</option>
                                    <option value="Vodafone (Ireland)">Vodafone (Ireland)</option>
                                    <option value="Vodafone (UK)">Vodafone (UK)</option>
                                    <option value="Three (UK)">Three (UK)</option>
                                    <option value="O2 (UK)">O2 (UK)</option>
                                    <option value="other">Other</option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group m-form__group row" v-if="sim_provider == 'other'">
                            <label class="col-3 col-form-label other_input">
                                &nbsp;
                            </label>
                            <div class="col-9">
                                <input type="text" class="form-control m-input m-input--solid other_input" v-model="other_sim_provider" placeholder="Please enter the sim provider name" />
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
import VueTelInput from 'vue-tel-input'
import 'vue-tel-input/dist/vue-tel-input.css';
export default {
	components: {
		"vue-tel-input": VueTelInput
	},
  props: ["simData"],
  data: () => {
    return {
			form_labels: {
				name: "Name",
				number: "Number",
				sim_provider: "SIM Provider",
				add_title: "Add SIM",
				hide_show_title: "Show/Hide Columns",
				edit_title: "Update Sim",
				add_sim_button: "Add SIM",
				hide_show_button: "OK",
				submit_button: "Save changes"
			},
			show_loading: false,
      show_errors: false,
      show_add_messages: "",
      show_loading: false,
      show_add_errors: false,
      errors: [],
      name: "",
      number: "",
      sim_provider: "",
      other_sim_provider: ""
    }
  },

  watch: {
    simData() {
      this.updatePropsValue(this.simData)
    }
  },
  methods: {
    updatePropsValue(sim) {
      this.name = sim.name,
      this.number = sim.number,
      this.sim_provider = sim.sim_provider
    },
    saveData (e) {
			this.show_loading = true;
			this.show_errors = true;

			let sim_provider = this.sim_provider;
			if(sim_provider == 'other'){
				sim_provider = this.other_sim_provider;
			}
			this.$http.post("/sims", {
				sim_provider: sim_provider,
				number:  this.number,
				name: this.name,
				addon: "Unknown",
				allowance: "-1.0",
				volume_used: "-1.0",
				user_id: this.$root.user_id,
				three_user_id: 0
			}).then(response => {
			  this.$notify({group: 'notify', title: 'SIM has been added.'});
			  this.clearForm()
			  jQuery('#addModel').modal('hide')
			}, error => {
				this.show_add_messages = error.body.errors;
				this.show_errors = true;
				this.show_loading = false;
			});
    },
    show_model(){
		  jQuery('#addModel').modal('show')
    },
    clearForm () {
			this.show_add_messages = "";
			this.show_errors = false;
      this.name = "",
      this.number = "",
      this.sim_provider = "",
      this.$events.fire("sim-added", {})
    }
  }
}
</script>