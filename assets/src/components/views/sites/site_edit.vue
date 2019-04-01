<template>
  <div v-if="showModal">
    <transition name="modal">
     <div class="modal modal-mask" style="display: block">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
              <h5 class="modal-title" id="exampleModalLabel">Edit Site</h5>
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
              <input type="hidden" v-model="edit_id">
              <div class="row">
                  <div class="col-lg-6">
                       <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.name}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" v-model="edit_name"aria-describedby="emailHelp" placeholder="Site Name">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.sim}}
                          </label>
                          <div class="col-9">
                              <select class="form-control m-input" v-model="edit_sim_number">
                                  <option v-bind:value="sim.number" v-for="sim in sims_list">{{sim.number}} {{sim.name}} </option>
                              </select>
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.router}}
                          </label>
                          <div class="col-9">
                              <select class="form-control m-input drop-input" v-model="edit_router_id">
                                <option v-bind:value="router.id" v-for="router in routers_list">{{router.name}}</option>
                              </select>
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.nvr}}
                          </label>
                          <div class="col-9">
                              <select class="form-control m-input drop-input" v-model="edit_nvr_id">
                                   <option v-bind:value="nvr.id" v-for="nvr in nvrs_list">{{nvr.name}}</option>
                              </select>
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.notes}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input m-input--solid" v-model="edit_notes"aria-describedby="emailHelp" placeholder="Short Note.">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.latitude}}
                          </label>
                          <div class="col-9">
                              <input type="text" v-model="edit_lat" class="form-control m-input m-input--solid readonly" readonly>
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.longitude}}
                          </label>
                          <div class="col-9">
                            <input type="text" v-model="edit_lng" class="form-control m-input m-input--solid readonly" id="longitude" readonly>
                          </div>
                      </div>
                  </div>
                  <div class="col-lg-6">
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.location}}
                          </label>
                          <div class="col-9 ">
                             <gmap-autocomplete
                              @place_changed="setPlace" class="form-control m-input m-input--solid"  ref="autocomplete">
                            </gmap-autocomplete>
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <div class="col-12">
                             <gmap-map
                                :center="center"
                                :zoom="12"
                                style="height:300px;width:100%"
                              >
                              <gmap-marker
                                :key="index"
                                v-for="(m, index) in markers"
                                :position="m.position"
                                @click="center=m.position"
                                :draggable="true",
                                @dragend="getMarkerPosition($event.latLng)"
                              ></gmap-marker>
                            </gmap-map>
                          </div>
                      </div>
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
   z-index: 1400;
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
  width: 750px;
  max-width: 100%;
}
</style>

<script>
export default {
  props: ["editData", "showModal"],
  data: () => {
    return {
      lat: "",
      lng: "",
      center: {},
      markers: [],
      places: [],
      currentPlace: "",
      form_labels: {
        name: "Name",
        location: "Location",
        sim: "SIM",
        router: "Router",
        nvr: "NVR",
        notes: "Notes",
        latitude: "Latitude",
        longitude: "Longitude",
        add_title: "Add Site",
        edit_title: "Edit Site",
        hide_show_title: "Show/Hide Columns",
        add_site_button: "Add Site",
        hide_show_button: "OK",
        submit_button: "Save changes"
      },
      show_edit_errors: false,
      show_loading: false,
      show_edit_messages: "",
      edit_id: "",
      edit_name: "",
      edit_sim_number: "",
      edit_router_id: "",
      edit_nvr_id: "",
      edit_notes: "",
      edit_lng: "",
      edit_lat: ""
    }
  },

  watch: {
    editData() {
      this.edit_name = this.editData.name
      this.edit_sim_number = this.editData.sim_number
      this.edit_router_id = this.editData.router_id
      this.edit_nvr_id = this.editData.nvr_id
      this.edit_notes = this.editData.notes
      this.edit_lng = this.editData.lng
      this.edit_lat = this.editData.lat
      this.edit_id = this.editData.id
      this.geolocate();
      this.$nextTick(() => {
        this.$refs.autocomplete.$refs.input.value = this.editData.map_area
      });
    }
  },

  created() {
    this.get_sims();
    this.get_routers();
    this.get_nvrs();
  },

  methods: {
    setPlace(place) {
      this.currentPlace = place;
      const marker = {
        lat: this.currentPlace.geometry.location.lat(),
        lng: this.currentPlace.geometry.location.lng()
      };
      this.edit_lat = this.currentPlace.geometry.location.lat()
      this.edit_lng = this.currentPlace.geometry.location.lng()
      this.markers = []
      this.markers.push({ position: marker });
      this.places.push(this.currentPlace);
      this.center = marker;
    },

    geolocate() {
      this.center = {
        lat: this.edit_lat,
        lng: this.edit_lng
      };
      const marker = {
        lat: this.edit_lat,
        lng: this.edit_lng
      };
      this.markers = []
      this.markers.push({ position: marker });
      this.places.push(this.currentPlace);
      this.center = marker;
    },

    getMarkerPosition(latLng){
      this.edit_lat = latLng.lat()
      this.edit_lng = latLng.lng()
    },

    get_sims(){
       this.$http.get('/all_sim').then(response => {
        this.sims_list = response.body.sims;
      });
    },

    get_routers(){
      this.$http.get('/all_routers').then(response => {
        this.routers_list = response.body.routers;
      });
    },

    get_nvrs(){
      this.$http.get('/all_nvrs').then(response => {
        this.nvrs_list = response.body.nvrs;
      });
    },

    updateData (){
      let edit_map_area =  this.$refs.autocomplete.$refs.input.value

      this.show_loading = true;

      let siteID = this.edit_id;

      this.$http.patch('/sites/update', {
        name: this.edit_name,
        sim_number: this.edit_sim_number,
        router_id: this.edit_router_id,
        nvr_id: this.edit_nvr_id,
        notes: this.edit_notes,
        location: {
          lat: this.edit_lat,
          lng: this.edit_lng,
          map_area: edit_map_area
        },
        id: siteID
      }).then(function (response) {
        this.$notify({group: 'notify', title: 'Site has been updated'});
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