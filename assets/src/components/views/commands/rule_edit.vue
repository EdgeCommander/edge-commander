<template>
  <div v-if="showModal">
    <transition name="modal">
     <div class="modal modal-mask" style="display: block">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
              <h5 class="modal-title" id="exampleModalLabel">Edit Router</h5>
              <div class="cancel">
                <a href="#" id="discardModal" data-dismiss="modal" @click="hideModal()">X</a>
              </div>
          </div>
          <div class="modal-body" id="body-rule-edit-dis">
            <img src="../../../assets/images/loading.gif" id="api-wait"  v-if="show_loading">
            <div id="ruleEditErrorDetails"  v-if="show_edit_errors">
                <div class="form-group m-form__group m--margin-top-10">
                    <div class="alert m-alert m-alert--default" role="alert">
                        <ul class="error_panel">
                          <li v-for="message in show_edit_messages">{{message}}</li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="m-form m-form--fit m-form--label-align-left">
                <input type="hidden" id="user_id" v-model="user_id">
                <input type="hidden" v-model="edit_rule_id" >
                <div class="form-group m-form__group row">
                    <label class="col-2 col-form-label">
                        {{form_labels.name}}
                    </label>
                    <div class="col-10">
                        <input type="text" class="form-control m-input m-input--solid" v-model="edit_rule_name" aria-describedby="emailHelp" placeholder="Test Usage.">
                    </div>
                </div>
                <div class="form-group m-form__group row">
                    <label class="col-2 col-form-label">
                        {{form_labels.category}}
                    </label>
                    <div class="col-4">
                        <select class="form-control m-input" v-model="edit_rule_category" style="height: 33px !important;">
                            <option value="usage_command">Internet usage in %</option>
                            <option value="daily_sms_usage_command">Total SMS in a day</option>
                            <option value="monthly_sms_usage_command">Total SMS in a monthly</option>
                            <option value="battery_voltages_command">Battery voltage in volts</option>
                        </select>
                    </div>
                    <div class="col-4">
                      <select class="form-control m-input" v-model="edit_rule_variable"  style="height: 33px !important;">
                        <option value="greater_than">Greater than (>)</option>
                        <option value="greater_than_equal_to">Greater than or equal to (>=)</option>
                        <option value="less_than">Less than (<)</option>
                        <option value="less_than_equal_to">Less than or equal to (<=)</option>
                        <option value="equals_to">Equals to (==)</option>
                      </select>
                    </div>
                    <div class="col-2">
                      <input type="number" min="0" class="form-control m-input m-input--solid" v-model="edit_rule_value"  aria-describedby="emailHelp" placeholder="10">
                    </div>
                </div>
                <div class="form-group m-form__group row">
                    <label class="col-2 col-form-label">
                        {{form_labels.recipients}}
                    </label>
                    <div class="col-10">
                        <input type="text" class="form-control m-input m-input--solid" v-model="edit_rule_recipients"aria-describedby="emailHelp" placeholder="test@user.com,who@am.io">
                    </div>
                </div>
                <div class="form-group m-form__group row">
                    <label class="col-2 col-form-label">
                    </label>
                    <div class="col-10">
                        <label class="m-checkbox">
                            <input type="checkbox" v-model="edit_rule_is_active">
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
      show_edit_errors: false,
      show_loading: false,
      show_edit_messages: "",
      edit_rule_name: "",
      edit_rule_id: "",
      edit_rule_category: "",
      edit_rule_variable: "",
      edit_rule_value: "",
      edit_rule_recipients: "",
      edit_rule_is_active: false
    }
  },

  watch: {
    editData() {
      this.edit_rule_name = this.editData.rule_name
      this.edit_rule_category = this.editData.category
      this.edit_rule_variable = this.editData.variable
      this.edit_rule_value = this.editData.value
      this.edit_rule_recipients = this.editData.recipients
      this.edit_rule_is_active = this.editData.active
      this.edit_rule_id = this.editData.id
    }
  },

  methods: {
    updateData (){
      this.show_loading = true;
      var ruleID = this.edit_rule_id;

      let recipients_array = this.edit_rule_recipients;
      let recipients = recipients_array.toString();
      if (recipients != "") {
        recipients = recipients.split(",");
      }else{
        recipients = "";
      }

      this.$http.patch('/rules/update', {
        rule_name: this.edit_rule_name,
        category: this.edit_rule_category,
        variable: this.edit_rule_variable,
        value: this.edit_rule_value,
        recipients: recipients,
        active: this.edit_rule_is_active,
        id: ruleID
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'Rule has been updated'});
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