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
                      <div class="form-group m-form__group row">
                        <label class="col-3 col-form-label">
                          Number
                        </label>
                        <div class="col-9">
                          <vue-tel-input v-model="number" @onInput="onInput" inputClasses="form-control" disabledFormatting="true" defaultCountry="ie"  placeholder="i.e +353xxxxxx"> </vue-tel-input>
                        </div>
                      </div>
                      <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                Sim Provider
                            </label>
                            <div class="col-9">
                                <select class="form-control m-input" id="sim_provider" v-model="sim_provider">
                                  <option v-for="name in networks">
                                    {{name}}
                                  </option>
                                </select>
                            </div>
                        </div>
                        <div class="form-group m-form__group row" v-if="sim_provider == 'Other'">
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
import VueTelInput from 'vue-tel-input'
import 'vue-tel-input/dist/vue-tel-input.css';

export default {
  components: {
    "vue-tel-input": VueTelInput
  },
  props: ["simEditData", "showSimModal"],
  data: () => {
    return {
      name: "",
      number: "",
      edit_sim_id: "",
      show_edit_errors: false,
      show_loading: false,
      show_edit_messages: "",
      sim_provider: "",
      other_sim_provider: "",
      networks: ["Three Ireland", "Lyca Mobile (Ireland)", "Vodafone (Ireland)", "Vodafone (UK)", "Three (UK)", "O2 (UK)", "Other"]
    }
  },

  watch: {
    simEditData() {
      this.name = this.simEditData.name
      this.number = this.simEditData.number
      this.edit_sim_id = this.simEditData.id
      let provider = this.simEditData.sim_provider
      if (this.networks.includes(provider) == false) {
        this.sim_provider = "Other"
        this.other_sim_provider = provider
      }else{
        this.sim_provider = provider
      }
    }
  },

  methods: {
    updateSim (){
      this.show_loading = true;
      let simID = this.edit_sim_id;
      let sim_provider = this.sim_provider;
      if(sim_provider == 'Other'){
        sim_provider = this.other_sim_provider;
      }

      this.$http.patch("/sims/" + simID, {
        name: this.name,
        number: this.number,
        sim_provider: sim_provider,
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