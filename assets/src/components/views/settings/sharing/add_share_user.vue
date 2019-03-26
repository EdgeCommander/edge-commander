<template>
  <div style="float: right; margin-right: 5px;">
  	<a href="javascript:void(0)"  class="btn btn-primary m-btn m-btn--icon" @click="show_model()">
	  <span>
	      <i class="fa fa-plus-square"></i>
	      <span>Share Details</span>
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
  props: ["shareData"],
  data: () => {
    return {
      form_labels: {
        sharee_email: "Share With",
        rights: "Rights",
        submit_button: "Share",
        add_title: "Share Account",
        hide_show_title: "Show/Hide Columns",
        add_sharing_button: "Share Details",
        hide_show_button: "OK"
      },
			show_loading: false,
      show_errors: false,
      show_add_messages: "",
      show_loading: false,
      show_add_errors: false,
      rights: 1,
      user_id: 1,
      user_email: "",
      sharee_email: ""
    }
  },

  watch: {
    shareData() {
      this.updatePropsValue(this.shareData)
    }
  },
  methods: {
    updatePropsValue(router) {
      this.sharee_email = router.sharee_email
    },
    saveData (e) {
      this.show_loading = true;

      this.$http.post('/members/new', {
        sharee_email: this.sharee_email,
        rights: this.rights,
        user_id:  this.user_id
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'Account has been shared and notify through email.'});
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
      this.sharee_email = "";
      this.show_add_errors = false;
      this.show_add_messages = "";
      this.$events.fire("sharing-added", {})
    }
  }
}
</script>