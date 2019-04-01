<template>
  <div v-if="showSimModal">
    <transition name="modal">
     <div class="modal modal-mask" style="display: block">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
              <h5 class="modal-title" id="exampleModalLabel">Edit Sim</h5>
              <div class="cancel">
                <a href="#" id="discardModal" data-dismiss="modal" @click="hideSimModal()">X</a>
              </div>
          </div>
          <div class="modal-body">
            <img src="../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                 <div v-if="show_edit_errors">
                    <div class="form-group m-form__group m--margin-top-10">
                      <ul class="error_panel">
                        <li v-for="message in show_edit_messages">{{message}}</li>
                      </ul>
                    </div>
                 </div>
                <div class="m-form m-form--fit m-form--label-align-left">
                    <input type="hidden" id="edit_sim_id" v-model="edit_sim_id">
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              Name
                          </label>
                          <div class="col-9">
                             <input type="text" class="form-control m-input m-input--solid" v-model="name" id="edit_sim_name">
                          </div>
                      </div>
                 </div>
                <!--end::Form-->
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-primary" @click="updateSim()"> Save </button>
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
  props: ["simEditData", "showSimModal"],
  data: () => {
    return {
      name: "",
      edit_sim_id: "",
      show_edit_errors: false,
      show_loading: false,
      show_edit_messages: "",
    }
  },

  watch: {
    simEditData() {
      this.name = this.simEditData.name
      this.edit_sim_id = this.simEditData.id
    }
  },

  methods: {
    updateSim (){
      this.show_loading = true;
      let simID = this.edit_sim_id;
      this.$http.patch("/sim/" + simID, {
        name: this.name,
        id: simID
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'Sim name has been updated'});
        this.show_loading = false;
        this.$events.fire("close-sim-modal", false);
        this.$events.fire("refresh-sim-table", true);

      }).catch(function (error) {
        this.show_loading = false;
        this.show_edit_errors = true;
        this.show_edit_messages = error.body.errors;
      });
    },

    hideSimModal () {
      this.show_loading = false;
      this.show_edit_errors = false;
      this.$events.fire("close-sim-modal", false);
    }
  }
}
</script>