<template>
  <div style="float: right; margin-right: 5px;">
  	<a href="javascript:void(0)"  class="btn btn-primary m-btn m-btn--icon" @click="show_model()">
	  <span>
	      <i class="fa fa-plus-square"></i>
	      <span>Add Site</span>
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
                    <div style="height: 10px"></div>
                    <div class="m-form m-form--fit m-form--label-align-left">
                      <div class="row">
                              <div class="col-lg-6">
                                  <div class="form-group m-form__group row">
                                      <label class="col-3 col-form-label">
                                          {{form_labels.name}}
                                      </label>
                                      <div class="col-9">
                                          <input type="text" class="form-control m-input m-input--solid" id="name" v-model="name" aria-describedby="emailHelp" placeholder="Site Name">
                                      </div>
                                  </div>
                                  <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.sim}}
                                  </label>
                                  <div class="col-9">
                                      <select class="form-control m-input" id="sim_number" v-model="sim_number">
                                        <option v-bind:value="sim.number" v-for="sim in sims_list">{{sim.number}} {{sim.name}} </option>
                                      </select>
                                  </div>
                                  </div>
                                  <div class="form-group m-form__group row">
                                      <label class="col-3 col-form-label">
                                          {{form_labels.router}}
                                      </label>
                                      <div class="col-9">
                                          <select class="form-control m-input drop-input" id="router_id" v-model="router_id">
                                              <option v-bind:value="router.id" v-for="router in routers_list">{{router.name}}</option>
                                          </select>
                                      </div>
                                  </div>
                                  <div class="form-group m-form__group row">
                                      <label class="col-3 col-form-label">
                                          {{form_labels.nvr}}
                                      </label>
                                      <div class="col-9">
                                          <select class="form-control m-input drop-input" id="nvr_id" v-model="nvr_id">
                                             <option v-bind:value="nvr.id" v-for="nvr in nvrs_list">{{nvr.name}}</option>
                                          </select>
                                      </div>
                                  </div>
                                  <div class="form-group m-form__group row">
                                      <label class="col-3 col-form-label">
                                          {{form_labels.notes}}
                                      </label>
                                      <div class="col-9">
                                          <input type="text" class="form-control m-input m-input--solid" id="notes" v-model="notes" aria-describedby="emailHelp" placeholder="Short Note.">
                                      </div>
                                  </div>
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.latitude}}
                                  </label>
                                  <div class="col-9">
                                      <input type="text" v-model="lat" class="form-control m-input m-input--solid readonly" readonly>
                                  </div>
                              </div>
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.latitude}}
                                  </label>
                                  <div class="col-9">
                                      <input type="text" v-model="lng" class="form-control m-input m-input--solid readonly" id="longitude" readonly>
                                  </div>
                              </div>
                          </div>
                          <div class="col-lg-6">
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.location}}
                                  </label>
                                  <div class="col-9 autocomplete_panel">
                                     <gmap-autocomplete
                                      @place_changed="setPlace" ref="autocomplete">
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
  props: ["siteData"],
  data: () => {
    return {
      lat: 53.3498053,
      lng: -6.260309699999993,
      center: {},
      markers: [],
      places: [],
      currentPlace: "Dublin, Ireland",
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
			show_loading: false,
      show_errors: false,
      show_add_messages: "",
      show_loading: false,
      show_add_errors: false,
      name: "",
      sim_number: "",
      router_id: "",
      nvr_id: "",
      notes: "",
      sims_list: "",
      routers_list: "",
      nvrs_list: ""
    }
  },

  watch: {
    siteData() {
      this.updatePropsValue(this.siteData)
    }
  },

  created() {
    this.get_sims();
    this.get_routers();
    this.get_nvrs();
  },

  mounted() {
    this.geolocate();
    this.$refs.autocomplete.$refs.input.value = this.currentPlace
  },

  methods: {
    setPlace(place) {
      this.currentPlace = place;
      const marker = {
        lat: this.currentPlace.geometry.location.lat(),
        lng: this.currentPlace.geometry.location.lng()
      };
      this.lat = this.currentPlace.geometry.location.lat()
      this.lng = this.currentPlace.geometry.location.lng()
      this.markers = []
      this.markers.push({ position: marker });
      this.places.push(this.currentPlace);
      this.center = marker;
    },

    geolocate() {
      this.center = {
        lat: this.lat,
        lng: this.lng
      };
      const marker = {
        lat: this.lat,
        lng: this.lng
      };
      this.markers = []
      this.markers.push({ position: marker });
      this.places.push(this.currentPlace);
      this.center = marker;
    },

    getMarkerPosition(latLng){
      this.lat = latLng.lat()
      this.lng = latLng.lng()
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

    updatePropsValue(router) {
      this.name = router.name
      this.sim_number = router.sim_number
      this.router_id = router.router_id
      this.nvr_id = router.nvr_id
      this.notes = router.notes
      this.notes = router.notes
    },
    saveData (e) {
      this.show_loading = true;

      let map_area = this.$refs.autocomplete.$refs.input.value

      this.$http.post('/sites/new', {
        name: this.name,
        sim_number:  this.sim_number,
        router_id: this.router_id,
        nvr_id: this.nvr_id,
        notes: this.notes,
        location: {
          lat: this.lat,
          lng: this.lng,
          map_area: map_area
        },
        user_id: this.$root.user_id
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
      this.name = "";
      this.sim_number = "";
      this.router_id = "";
      this.nvr_id = "";
      this.notes = "";
      this.show_add_errors = false;
      this.$events.fire("site-added", {})
    }
  }
}
</script>