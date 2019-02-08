<template>
  <div>
    <div class="m-content">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" style="padding: 10px;">
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right m--margin-bottom-10">
            <div class="row align-items-center">
              <div class="col-md-12">
                <div class="form-group m-form__group row align-items-center">
                  <div class="col-md-12">
                    <div class="m-input-icon m-input-icon--left">
                      <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item">
                            <router-link v-bind:to="'/my_profile'" class="nav-link active show">My Profile</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/three_users'" class="nav-link">Three Users</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/activities'" class="nav-link">Activities</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/sharing'" class="nav-link">Sharing</router-link>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-4 order-1 order-md-2 m--align-right">
              </div>
            </div>
          </div>
          <!--end: Search Form -->
                <div class="heading_panel">
                    <div class="pull-left">
                      <h4>My Profile Details <i class="fa fa-long-arrow-right"></i></h4>
                    </div>
                    <div class="pull-right"></div>
                    <div class="clearfix"></div>
                  </div>
                  <div class="col-sm-6">
                   <div id="myProfileErrorDetail" v-if="my_profile.show_errors">
                      <div class="form-group m-form__group m--margin-top-10">
                          <div class="alert m-alert m-alert--default" role="alert">
                              <ul style="margin:0px">
                                <li v-for="message in my_profile.show_message">{{message}}</li>
                              </ul>
                          </div>
                      </div>
                    </div>
                   <div class="m--margin-top-20">
                    <img class="gravatar pull-left" v-bind:src="my_profile.gravatar_url">
                    <div class="username">
                      <span class="grey">Username </span><strong><span v-html="my_profile.username"></span></strong>
                    </div>
                    <p class="small grey">Manage your avatar with <a href="https://en.gravatar.com/" target="_blank">Gravatar</a> </p>
                  </div>
                  <div class="clearfix"></div>
                  <div class="m-form m-form--fit m-form--label-align-left" style="margin-left:10px">
                      <input type="hidden" id="id"  v-model="user_id">
                      <input type="hidden"  v-model="my_profile.csrf_token">
                      <div class="form-group m-form__group row" style="margin-bottom: 0">
                          <label class="col-3 col-form-label">
                              {{form_labels.fname}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input" v-model="my_profile.firstname">
                          </div>
                      </div>
                      <div class="form-group m-form__group row" style="margin-bottom: 0">
                          <label class="col-3 col-form-label">
                              {{form_labels.lname}}
                          </label>
                          <div class="col-9">
                              <input type="text" class="form-control m-input" v-model="my_profile.lastname">
                          </div>
                      </div>
                      <div class="form-group m-form__group row" style="margin-bottom: 0">
                          <label class="col-3 col-form-label">
                              {{form_labels.email}}
                          </label>
                          <div class="col-9">
                              <input type="email" class="form-control m-input" v-model="my_profile.email">
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.password}}
                          </label>
                          <div class="col-9">
                              <input type="password" class="form-control m-input" v-model="my_profile.password" >
                          </div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                              {{form_labels.api_key}}
                          </label>
                          <div class="col-9" style="padding:10px 15px" v-html="my_profile.api_key"></div>
                      </div>
                      <div class="form-group m-form__group row" style="padding-top:0">
                          <label class="col-3 col-form-label">
                              {{form_labels.api_id}}
                          </label>
                          <div class="col-9" style="padding:10px 15px" v-html="my_profile.api_id"></div>
                      </div>
                      <div class="form-group m-form__group row">
                          <label class="col-3 col-form-label">
                          </label>
                          <div class="col-9">
                            <button type="button" class="btn btn-default" id="updateMyProfile" v-on:click="updateMyProfile()">
                              {{form_labels.submit_button}}
                            </button>
                          </div>
                      </div>
                      <div style="height:20px"></div>
                  </div>
              </div>
              </div>
          
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'
import App from './App.vue'
const app = new Vue(App)

module.exports = {
  name: 'my_profile',
  data: function(){
    return{
      table_records: '',
      dataTable: null,
      sharing_dataTable: null,
      logsDataTable: null,
      add_button_label: "Add New",
      my_profile: {
        show_loading: false,
        show_message: [],
        show_errors: false,
        firstname: "",
        lastname: "",
        email: "",
        password: "",
        api_key: "",
        api_id: "",
        username: "",
        gravatar_url: "",
        csrf_token: "",
      },
      form_labels: {
        fname: "First Name",
        lname: "Last Name",
        email: "Email",
        password: "Password",
        api_key: "Api Key",
        api_id: "Api Id",
        title: "My Profile",
        submit_button: "Save changes",
      },
      user_id: ""
    }
  },
  methods: {
   date_format: function(id){
    let string = $("#" + id).val().split("-")
    return string[2] +"-"+ string[1]  +"-"+ string[0]
   },
   updateMyProfile: function() {
    this.my_profile.show_loading = true;
    this.my_profile.show_errors = true;
    this.$http.patch('/update_profile', {
      firstname: this.my_profile.firstname,
      lastname: this.my_profile.lastname,
      email: this.my_profile.email,
      password: this.my_profile.password,
      id: this.user_id
    }).then(function (response) {
      this.my_profile.show_message = "";
      this.my_profile.show_errors = false;
      this.my_profile.show_loading = false;
      this.my_profile.password = "";
      app.$notify({group: 'notify', title: 'Profile has been updated.'});
    }).catch(function (error) {
      this.my_profile.show_message = error.body.errors;
      this.my_profile.show_errors = true;
      this.my_profile.show_loading = false;
    });
   },
   get_my_prfile: function(){
    this.$http.get('/get_porfile').then(response => {
      this.my_profile.firstname = response.body.firstname;
      this.my_profile.lastname = response.body.lastname;
      this.my_profile.email = response.body.email;
      this.my_profile.api_key = response.body.api_key;
      this.my_profile.api_id = response.body.api_id;
      this.user_id = response.body.id;
      this.my_profile.username = response.body.username;
      this.my_profile.gravatar_url = response.body.gravatar_url;
      this.my_profile.csrf_token = response.body.csrf_token;
    });
   },
   active_menu_link: function(){
    $("li").removeClass(" m-menu__item--active");
    $(".settings").addClass(" m-menu__item--active");
    $("#m_aside_left").removeClass("m-aside-left--on");
    $("body").removeClass("m-aside-left--on");
    $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
   }
  },
  mounted(){
    this.get_my_prfile();
    this.active_menu_link();
  }
}
</script>

<style lang="scss">
</style>
