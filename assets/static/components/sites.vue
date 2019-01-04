<template>
  <div>
  <div class="m-content">
    <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
      <div class="m-portlet__body" style="padding: 10px;">
        <!--begin: Search Form -->
        <div class="m-form m-form--label-align-right m--margin-bottom-10">
          <div class="row align-items-center">
            <div class="col-md-8 order-2 order-md-1">
              <div class="form-group m-form__group row align-items-center">
                <div class="col-md-5">
                  <div class="m-input-icon m-input-icon--left">
                    <input type="text" class="form-control m-input m-input--solid" placeholder="Search..." id="m_form_search" v-model="m_form_search" v-on:keyup="search()">
                    <span class="m-input-icon__icon m-input-icon__icon--left">
                      <span>
                        <i class="la la-search"></i>
                      </span>
                    </span>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-md-4 order-1 order-md-2 m--align-right">
                <a href="javascript:void(0)" id="addSite" class="btn btn-primary m-btn m-btn--icon" v-on:click="onSiteButton">
                    <span>
                        <i class="fa fa-plus-square"></i>
                        <span>
                            {{form_labels.add_site_button}}
                        </span>
                    </span>
                </a>
                <div href="javascript:void(0)" class="btn btn-default grey" v-on:click="onSiteHideShowButton">
                  <i class="fa fa-columns"></i>
                </div>
            </div>
          </div>
        </div>
        <!--end: Search Form -->
        <table id="sites-datatable" class="table table-striped  table-hover table-bordered datatable display nowrap" cellspacing="0" width="100%">
            <thead>
                <tr>
                    <th v-for="(item, index) in headings">{{item.column}}</th>
                </tr>
            </thead>
        </table>
      </div>
    </div>
  </div>
  <!-- end:: modal -->
  <div class="modal fade toggle-datatable-columns" ref="hideShow" style="padding: 0px;"  tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
    <div class="modal-dialog modal-sm" role="document">
        <div class="modal-content" style="padding: 0px;">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">
                    {{form_labels.hide_show_title}}
                </h5>
                <div class="cancel">
                  <a href="#" id="discardModal" data-dismiss="modal" v-on:click="clearForm">X</a>
                </div>
            </div>
            <div class="modal-body" id="body-sim-dis">
                <div class="form-group">
                  <div class="column-checkbox" v-for="(item, index) in headings">
                      <label class="m-checkbox m-checkbox--single m-checkbox--solid m-checkbox--brand" style="width: auto;"><input type="checkbox" class="sites-column" v-bind:data-id="item.id" v-on:change="showHideColumns(item.id)"><span></span> {{item.column}}</label>
                  </div>
                </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-default" data-dismiss="modal">{{form_labels.hide_show_button}}</button>
            </div>
        </div>
    </div>
  </div>
  <div class="modal fade add_site_to_db" ref="addmodal" style="padding: 0px;" id="m_modal_1" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
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
              <div class="modal-body" id="body-site-dis">
                  <img src="/images/loading.gif" id="api-wait" v-if="show_loading">
                  <div id="siteErrorDetails" v-if="show_add_errors">
                      <div class="form-group m-form__group m--margin-top-10">
                          <div class="alert m-alert m-alert--default" role="alert">
                              <ul style="margin:0px">
                                <li v-for="message in show_add_messages">{{message}}</li>
                              </ul>
                          </div>
                      </div>
                  </div>
                  <div class="m-form m-form--fit m-form--label-align-left">
                      <input type="hidden" id="user_id" v-model="user_id">
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
                                      <input name="lat" type="text" class="form-control m-input m-input--solid readonly" id="latitude" readonly>
                                  </div>
                              </div>
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.latitude}}
                                  </label>
                                  <div class="col-9">
                                      <input name="lng" type="text" class="form-control m-input m-input--solid readonly" id="longitude" readonly>
                                  </div>
                              </div>
                          </div>
                          <div class="col-lg-6">
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.location}}
                                  </label>
                                  <div class="col-9">
                                     <input type="text" class="form-control m-input m-input--solid" id="map_area" v-model="map_area" aria-describedby="emailHelp" placeholder="Search Location">
                                  </div>
                              </div>
                              <div class="form-group m-form__group row">
                                  <div class="col-12">
                                     <div id="map_canvas"  style="height:300px;width:100%"></div>
                                  </div>
                              </div>
                          </div>
                      </div>
                  </div>
                  <!--end::Form-->
              </div>
              <div class="modal-footer" style="padding: 11px;">
                  <button type="button" class="btn btn-default" v-on:click="saveModal">
                      {{form_labels.submit_button}}
                  </button>
              </div>
          </div>
      </div>
  </div>
  <div class="modal fade" id="edit_site_to_db" style="padding: 0px;" data-backdrop="static" data-keyboard="false">
      <div class="modal-dialog modal-lg" role="document">
          <div class="modal-content" style="padding: 0px;">
              <div class="modal-header">
                  <h5 class="modal-title" id="exampleModalLabel">
                      {{form_labels.edit_title}}
                  </h5>
                  <div class="cancel">
                      <a href="#" id="discardEditModal" data-dismiss="modal" v-on:click="editClearFrom">X</a>
                  </div>
              </div>
              <div class="modal-body" id="body-site-edit-dis">
                   <img src="/images/loading.gif" id="api-wait" v-if="show_loading">
                  <div id="siteEditErrorDetails" v-if="show_edit_errors">
                      <div class="form-group m-form__group m--margin-top-10">
                          <div class="alert m-alert m-alert--default" role="alert">
                              <ul style="margin:0px">
                               <li v-for="message in show_edit_messages">{{message}}</li>
                              </ul>
                          </div>
                      </div>
                  </div>
                  <div class="m-form m-form--fit m-form--label-align-left">
                      <input type="hidden" id="user_id" v-model="user_id">
                      <input type="hidden" id="edit_id">
                      <div class="row">
                          <div class="col-lg-6">
                               <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.name}}
                                  </label>
                                  <div class="col-9">
                                      <input type="text" class="form-control m-input m-input--solid" id="edit_name"aria-describedby="emailHelp" placeholder="Site Name">
                                  </div>
                              </div>
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.sim}}
                                  </label>
                                  <div class="col-9">
                                      <select class="form-control m-input" id="edit_sim_number">
                                          <option v-bind:value="sim.number" v-for="sim in sims_list">{{sim.number}} {{sim.name}} </option>
                                      </select>
                                  </div>
                              </div>
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.router}}
                                  </label>
                                  <div class="col-9">
                                      <select class="form-control m-input drop-input" id="edit_router_id">
                                            <option v-bind:value="router.id" v-for="router in routers_list">{{router.name}}</option>
                                      </select>
                                  </div>
                              </div>
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.nvr}}
                                  </label>
                                  <div class="col-9">
                                      <select class="form-control m-input drop-input" id="edit_nvr_id">
                                           <option v-bind:value="nvr.id" v-for="nvr in nvrs_list">{{nvr.name}}</option>
                                      </select>
                                  </div>
                              </div>
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.notes}}
                                  </label>
                                  <div class="col-9">
                                      <input type="text" class="form-control m-input m-input--solid" id="edit_notes"aria-describedby="emailHelp" placeholder="Short Note.">
                                  </div>
                              </div>
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.latitude}}
                                  </label>
                                  <div class="col-9">
                                      <input name="lat" type="text" class="form-control m-input m-input--solid readonly" id="edit_latitude" readonly>
                                  </div>
                              </div>
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.longitude}}
                                  </label>
                                  <div class="col-9">
                                      <input name="lng" type="text" class="form-control m-input m-input--solid readonly" id="edit_longitude" readonly>
                                  </div>
                              </div>
                          </div>
                          <div class="col-lg-6">
                              <div class="form-group m-form__group row">
                                  <label class="col-3 col-form-label">
                                      {{form_labels.location}}
                                  </label>
                                  <div class="col-9">
                                     <input type="text" class="form-control m-input m-input--solid" id="edit_map_area" aria-describedby="emailHelp" placeholder="Search Location">
                                  </div>
                              </div>
                              <div class="form-group m-form__group row">
                                  <div class="col-12">
                                     <div id="edit_map_canvas" style="height:300px;width:100%"></div>
                                  </div>
                              </div>
                          </div>
                      </div>
                  </div>
                  <!--end::Form-->
              </div>
              <div class="modal-footer" style="padding: 11px;">
                  <button id="" type="button" class="btn btn-default" v-on:click="updateSitedo">
                      {{form_labels.submit_button}}
                  </button>
              </div>
          </div>
      </div>
  </div>
  <!--end::Modal-->
</div>
</template>

<script>
import Vue from 'vue'
import App from './App.vue'
const app = new Vue(App)

module.exports = {
  name: 'sites',
  data: function(){
    return{
      dataTable: null,
      m_form_search: "",
      mapEditView: "",
      show_loading: false,
      show_add_errors: false,
      show_edit_errors: false,
      sims_list: "",
      routers_list: "",
      nvrs_list: "",
      show_add_messages: "",
      show_edit_messages: "",
      headings: [
        {column: "Actions", id: "actions"},
        {column: "Name", id: "name"},
        {column: "Location", id: "location"},
        {column: "Sim Number", id: "sim_number"},
        {column: "Router Name", id: "router_name"},
        {column: "NVR Name", id: "nvr_name"},
        {column: "Notes", id: "notes"},
        {column: "Created At", id: "created_at"},
      ],
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
      name: "",
      sim_number: "",
      router_id: "",
      nvr_id: "",
      notes: "",
      map_area: "Dublin, Ireland",
      user_id: "",
      edit_id: "",
      edit_name: "",
      edit_sim_number: "",
      edit_router_id: "",
      edit_nvr_id: "",
      edit_notes: "",
      edit_map_area: ""
    }
  },
  methods: {
    initializeTable: function(){
      let sitesDataTable = $('#sites-datatable').DataTable({
        fnInitComplete: function(){
            // Enable TFOOT scoll bars
            $('.dataTables_scrollFoot').css('overflow', 'auto');
            $('.dataTables_scrollHead').css('overflow', 'auto');
            // Sync TFOOT scrolling with TBODY
            $('.dataTables_scrollFoot').on('scroll', function () {
            $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
          });
          $('.dataTables_scrollHead').on('scroll', function () {
            $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
          });
        },
        ajax: {
        url: "/sites/data",
          dataSrc: function(data) {
            return data.sites;
          },
          error: function(xhr, error, thrown) {
            if (xhr.responseJSON) {
              console.log(xhr.responseJSON.message);
            } else {
              console.log("Something went wrong, Please try again.");
            }
          }
        },
        columns: [
        {
          class: "text-center actions",
          data: function(row, type, set, meta) {
            return '<div id="action_btn"><div class="editSite cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="cursor_to_pointer fa fa-trash delSite" data-id="'+ row.id +'"></div></div>';
          }
        },
        {
          class: "name",
          data: function(row, type, set, meta) {
            return row.name;
          }
        },
        {
          class: "location",
          data: function(row, type, set, meta) {
            return row.location.map_area;
          }
        },
        {
          class: "text-center sim_number",
          data: function(row, type, set, meta) {
            return row.sim_number;
          }
        },
        {
          class: "router_name",
          data: function(row, type, set, meta) {
            return row.router_name;
          }
        },
        {
          class: "nvr_name",
          data: function(row, type, set, meta) {
            return row.nvr_name;
          }
        },
        {
          class: "notes",
          data: function(row, type, set, meta) {
            return row.notes;
          }
        },
        {
          class: "text-center created_at",
          data: function(row, type, set, meta) {
            return moment(row.created_at).format('DD-MM-YYYY HH:mm:ss');
          },
        },
        ],
        autoWidth: true,
        info: false,
        bPaginate: false,
        lengthChange: false,
        scrollX: true,
        colReorder: true,
        stateSave:  true
      });
      return this.dataTable = sitesDataTable;
    },
    search: function(){
      this.dataTable.search(this.m_form_search).draw();
    },
    showHideColumns: function(id){
      let column = this.dataTable.columns("." +id);
      if(column.visible()[0] == true){
        column.visible(false);
      }else{
        column.visible(true);
      }
    },
    mapInitialize: function(){
      let initialLat = document.getElementById('latitude').value;
      let initialLong = document.getElementById('longitude').value;
      initialLat = initialLat?initialLat:53.349805;
      initialLong = initialLong?initialLong:-6.260310;

      let latlng = new google.maps.LatLng(initialLat, initialLong);
      let options = {
        zoom: 15,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      let map = new google.maps.Map(document.getElementById("map_canvas"), options);
      let geocoder = new google.maps.Geocoder();
      let marker = new google.maps.Marker({
        map: map,
        draggable: true,
        position: latlng
      });
      google.maps.event.addListener(marker, "dragend", function () {
        let point = marker.getPosition();
        let geocoder = new google.maps.Geocoder();
        map.panTo(point);
        geocoder.geocode({'latLng': marker.getPosition()}, function (results, status) {
          if (status == google.maps.GeocoderStatus.OK) {
            let latVal = marker.getPosition().lat();
            let lngVal = marker.getPosition().lng();
            document.getElementById("latitude").value = latVal.toFixed(6)
            document.getElementById("longitude").value = lngVal.toFixed(6)
          }
        });
      });
   },
   addMap: function() {
    this.mapInitialize();
    let PostCodeid = document.getElementById("map_area");
    let geocoder = new google.maps.Geocoder();
    $(PostCodeid).autocomplete({
      source: function (request, response) {
        geocoder.geocode({
          'address': request.term
        }, function (results, status) {
          response($.map(results, function (item) {
            return {
              label: item.formatted_address,
              value: item.formatted_address,
              lat: item.geometry.location.lat(),
              lon: item.geometry.location.lng()
            };
          }));
        });
      },
      select: function (event, ui) {
        let latVal = ui.item.lat;
        let lngVal = ui.item.lon;
        document.getElementById("latitude").value = latVal.toFixed(6)
        document.getElementById("longitude").value = lngVal.toFixed(6)
        let latlng = new google.maps.LatLng(latVal, lngVal);
        let options = {
          zoom: 15,
          center: latlng,
          mapTypeId: google.maps.MapTypeId.ROADMAP
        };
        let map = new google.maps.Map(document.getElementById("map_canvas"), options);
        let marker = new google.maps.Marker({
          map: map,
          draggable: true,
          position: latlng
        });
        marker.setPosition(latlng);
        module.exports.methods.mapInitialize();
      }
    });
   },
    onSiteButton: function() {
      $(this.$refs.addmodal).modal("show");
      this.map_area = "Dublin, Ireland";
      document.getElementById('latitude').value = "53.349805";
      document.getElementById('longitude').value = "-6.2603010";
      this.addMap();
    },
    onSiteHideShowButton: function(){
      $(this.$refs.hideShow).modal("show");
    },
    saveModal: function() {
      this.show_loading = true;
      this.show_add_errors = true;
      this.$http.post('/sites/new', {
        name: this.name,
        sim_number:  this.sim_number,
        router_id: this.router_id,
        nvr_id: this.nvr_id,
        notes: this.notes,
        location: {
          lat: document.getElementById("latitude").value,
          lng: document.getElementById("longitude").value,
          map_area: this.map_area
        },
        user_id: this.user_id
      }).then(function (response) {
        app.$notify({group: 'notify', title: 'Site has been added'});
        this.show_loading = false;
        this.dataTable.ajax.reload();
        this.clearForm();
        $(this.$refs.addmodal).modal("hide");
      }).catch(function (error) {
        this.show_add_messages = error.body.errors;
        this.show_add_errors = true;
        this.show_loading = false;
      });
    },
    clearForm: function() {
      this.name = "";
      this.sim_number = "";
      this.router_id = "";
      this.nvr_id = "";
      this.notes = "";
      this.map_area = "Dublin, Ireland";
      this.show_add_messages = "";
      this.show_add_errors = false;
      this.map_area = "Dublin, Ireland";
      this.latitude = "53.349805";
      this.longitude = "-6.2603010";
      this.addMap();
    },
    getUniqueIdentifier: function(sitesDataTable){
      $(document).on("click", ".editSite", function(){
        let tr = $(this).closest('tr');
        let row = sitesDataTable.row(tr);
        let data = row.data();
        let site_id = $(this).data("id");
        module.exports.methods.onSiteEditButton(data);
      });
    },
    editMapInitialize: function(){
      let initialLat =  document.getElementById("edit_latitude").value;
      let initialLong = document.getElementById("edit_longitude").value;
      initialLat = initialLat?initialLat:53.3498053;
      initialLong = initialLong?initialLong:-6.260309699999993;

      let latlng = new google.maps.LatLng(initialLat, initialLong);
      let options = {
        zoom: 15,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      let map = new google.maps.Map(document.getElementById("edit_map_canvas"), options);
      let geocoder = new google.maps.Geocoder();
      let marker = new google.maps.Marker({
        map: map,
        draggable: true,
        position: latlng
      });

      google.maps.event.addListener(marker, "dragend", function () {
        let point = marker.getPosition();
        map.panTo(point);
        geocoder.geocode({'latLng': marker.getPosition()}, function (results, status) {
          if (status == google.maps.GeocoderStatus.OK) {
            let latVal = marker.getPosition().lat();
            let lngVal = marker.getPosition().lng();
            document.getElementById("edit_latitude").value = latVal.toFixed(6);
            document.getElementById("edit_longitude").value = lngVal.toFixed(6);
          }
        });
      });
    },
    onSiteEditButton: function(data){
      $("#edit_id").val(data.id);
      $("#edit_name").val(data.name);
      $("#edit_sim_number").val(data.sim_number);
      $("#edit_router_id").val(data.router_id);
      $("#edit_nvr_id").val(data.nvr_id);
      $("#edit_notes").val(data.notes);
      $("#edit_map_area").val(data.location.map_area);

      document.getElementById("edit_longitude").value = data.location.lng;
      document.getElementById("edit_latitude").value = data.location.lat;

      $("#edit_site_to_db").modal("show");
      this.editMapInitialize();
      let PostCodeid =  document.getElementById("edit_map_area");
      $(PostCodeid).autocomplete({
        source: function (request, response) {
          let geocoder = new google.maps.Geocoder();
          geocoder.geocode({
            'address': request.term
          }, function (results, status) {
            response($.map(results, function (item) {
              return {
                label: item.formatted_address,
                value: item.formatted_address,
                lat: item.geometry.location.lat(),
                lon: item.geometry.location.lng()
              };
            }));
          });
        },
        select: function (event, ui) {
          let latVal = ui.item.lat;
          let lngVal = ui.item.lon;
          document.getElementById("edit_latitude").value = latVal.toFixed(6);
          document.getElementById("edit_longitude").value = lngVal.toFixed(6);
          let latlng = new google.maps.LatLng(latVal, lngVal);
          let options = {
            zoom: 15,
            center: latlng,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          };
          let map = new google.maps.Map(document.getElementById("edit_map_canvas"), options);
          let geocoder = new google.maps.Geocoder();
          let marker = new google.maps.Marker({
            map: map,
            draggable: true,
            position: latlng
          });
          marker.setPosition(latlng);
          module.exports.methods.editMapInitialize();
        }
      });
    },
    updateSitedo: function(){
      this.show_loading = true;
      this.show_edit_errors = true;
      let siteID = $("#edit_id").val();
      this.$http.patch('/sites/update', {
        name: $("#edit_name").val(),
        sim_number: $("#edit_sim_number").val(),
        router_id: $("#edit_router_id").val(),
        nvr_id: $("#edit_nvr_id").val(),
        notes: $("#edit_notes").val(),
        location: {
          lat: $("#edit_latitude").val(),
          lng: $("#edit_longitude").val(),
          map_area: $("#edit_map_area").val()
        },
        id: siteID
      }).then(function (response) {
        app.$notify({group: 'notify', title: 'Site has been updated'});
        this.show_loading = false;
        this.dataTable.ajax.reload();
        this.editClearFrom();
        $("#edit_site_to_db").modal("hide");
      }).catch(function (error) {
        this.show_loading = false;
        this.show_edit_messages = error.body.errors;
        this.show_edit_errors = true;
      });
    },
    deleteSite: function(){
    $(document).off("click").on("click", ".delSite", function(){
      let siteRow, result;
      siteRow = $(this).closest('tr');
      let siteID = $(this).data("id");
      result = confirm("Are you sure to delete this Site?");
      if (result === false) {
        return;
      }
      app.$http.delete("/sites/" + siteID, {siteRow: siteRow}).then(function (response) {
        siteRow.remove();
        app.$notify({group: 'notify', title: 'Site has been deleted'});
      }).catch(function (error) {
         return false
      });
    });
   },
    editClearFrom: function() {
      this.edit_name = ""
      this.edit_map_area = ""
      this.edit_sim_number = ""
      this.edit_router_id = ""
      this.edit_nvr_id = ""
      this.show_edit_messages = "";
      this.show_loading = false;
      this.show_edit_errors = false;
    },
    initHideShow: function(){
      $(".sites-column").each(function(){
        let sitesDataTable = $('#sites-datatable').DataTable();
        let that = $(this).attr("data-id");
        let column = sitesDataTable.columns("." +that);
        if(column.visible()[0] == true){
          $(this).prop('checked', true);
        }else{
          $(this).prop('checked', false);
        }
      });
    },
    get_session: function(){
      this.$http.get('/get_porfile').then(response => {
        this.user_id = response.body.id;
      });
    },
    get_sims: function(){
      this.$http.get('/sims/data/json').then(response => {
        this.sims_list = response.body.logs;
      });
    },
    get_routers: function(){
      this.$http.get('/routers/data').then(response => {
        this.routers_list = response.body.routers;
      });
    },
    get_nvrs: function(){
      this.$http.get('/nvrs/data').then(response => {
        this.nvrs_list = response.body.nvrs;
      });
    },
    active_menu_link: function(){
      $("li").removeClass(" m-menu__item--active");
      $(".sites").addClass(" m-menu__item--active");
      $("#m_aside_left").removeClass("m-aside-left--on");
      $("body").removeClass("m-aside-left--on");
      $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
    }
   }, // end of methods\
  created() {
    this.get_session();
    this.get_sims();
    this.get_routers();
    this.get_nvrs();
  },
   mounted(){
    this.deleteSite();
    let table = this.initializeTable();
    this.getUniqueIdentifier(table);
    this.search();
    this.initHideShow();
    this.active_menu_link();
   }
}
</script>
<style lang="scss">
</style>
