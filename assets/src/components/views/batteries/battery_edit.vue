<template>
  <div v-if="showModal">
    <transition name="modal">
     <div class="modal modal-mask" style="display: block">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
              <h5 class="modal-title" id="exampleModalLabel">Edit Battery</h5>
              <div class="cancel">
                <a href="#" id="discardModal" data-dismiss="modal" @click="hideModal()">X</a>
              </div>
          </div>
          <div class="modal-body" id="body-battery-edit-dis">
            <img src="../../../assets/images/loading.gif" id="api-wait"  v-if="show_loading">
            <div id="batteryEditErrorDetails"  v-if="show_edit_errors">
                <div class="form-group m-form__group m--margin-top-10">
                    <div class="alert m-alert m-alert--default" role="alert">
                        <ul class="error_panel">
                          <li v-for="message in show_edit_messages">{{message}}</li>
                        </ul>
                    </div>
                </div>
            </div>
            <div class="m-form m-form--fit m-form--label-align-left">
              <input type="hidden" v-model="edit_battery_id" >
              <div class="form-group m-form__group row">
                  <label class="col-2 col-form-label">
                      {{form_labels.name}}
                  </label>
                  <div class="col-10">
                      <input type="text" class="form-control m-input m-input--solid" v-model="edit_battery_name" >
                  </div>
              </div>
              <div class="form-group m-form__group row">
                  <label class="col-2 col-form-label">
                      {{form_labels.battery_source_url}}
                  </label>
                  <div class="col-10">
                      <input type="text" class="form-control m-input m-input--solid" v-model="edit_battery_source_url">
                  </div>
              </div>
              <div class="form-group m-form__group row">
                  <label class="col-2 col-form-label">
                  </label>
                  <div class="col-10">
                      <label class="m-checkbox">
                          <input type="checkbox" v-model="edit_battery_is_active">
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
  width: 600px;
  max-width: 100%;
}
</style>

<script>
export default {
  props: ["editData", "showModal"],
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
      show_edit_errors: false,
      show_loading: false,
      show_edit_messages: "",
      edit_battery_name: "",
      edit_battery_id: "",
      edit_battery_source_url: "",
      edit_battery_is_active: false
    }
  },

  watch: {
    editData() {
      this.edit_battery_name = this.editData.name
      this.edit_battery_source_url = this.editData.source_url
      this.edit_battery_is_active = this.editData.active
      this.edit_battery_id = this.editData.id
    }
  },

  methods: {
    updateData (){
      this.show_loading = true;
      var recordID = this.edit_battery_id;

      this.$http.patch('/battery/update', {
        name: this.edit_battery_name,
        source_url: this.edit_battery_source_url,
        active: this.edit_battery_is_active,
        id: recordID
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'Battery has been updated'});
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