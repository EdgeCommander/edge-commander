<template>
  <div v-if="showModal">
    <transition name="modal">
     <div class="modal modal-mask" style="display: block">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
              <h5 class="modal-title" id="exampleModalLabel">Edit Three User</h5>
              <div class="cancel">
                <a href="#" id="discardModal" data-dismiss="modal" @click="hideModal()">X</a>
              </div>
          </div>
          <div class="modal-body" id="body-rule-edit-dis">
            <img src="../../../../assets/images/loading.gif" id="api-wait"  v-if="show_loading">
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
              <input type="hidden" v-model="edit_three_three_id">
              <div class="form-group m-form__group row">
                <label class="col-3 col-form-label">
                {{form_labels.username}}
                </label>
                <div class="col-9">
                  <input type="text" class="form-control m-input m-input--solid" v-model="edit_username">
                </div>
              </div>
              <div class="form-group m-form__group row">
                <label class="col-3 col-form-label">
                {{form_labels.password}}
                </label>
                <div class="col-9">
                  <input type="text" class="form-control m-input m-input--solid" v-model="edit_password">
                </div>
              </div>
              <div class="form-group m-form__group row">
                <label class="col-3 col-form-label">
                {{form_labels.day}}
                </label>
                <div class="col-9">
                  <input type="number" class="form-control m-input m-input--solid"  v-model="edit_bill_day" min="1" max="31">
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
      show_edit_errors: false,
      show_loading: false,
      show_edit_messages: "",
      edit_three_three_id: "",
      edit_username: "",
      edit_password: "",
      edit_bill_day: ""
    }
  },

  watch: {
    editData() {
      this.edit_username = this.editData.username
      this.edit_password = this.editData.password
      this.edit_bill_day = this.editData.bill_day
      this.edit_three_three_id = this.editData.id
    }
  },

  methods: {
    updateData (){
      this.show_edit_messages = "";
      this.show_loading = true;

      this.$http.patch('/three_accounts', {
        username: this.edit_username,
        password: this.edit_password,
        bill_day: this.edit_bill_day,
        id: this.edit_three_three_id
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'Three user has been updated'});
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