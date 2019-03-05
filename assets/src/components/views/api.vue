<template>
  <div id="api_main">
  <div class="m-content">
    <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" id="double-scroll" style="padding: 10px; overflow: auto">
            <div class="col-sm-12">
                <div class="m-form m-form--fit m-form--label-align-left" style="margin-left:10px">
                    <input type="hidden" id="id"  value="<%= @user.id %>">
                    <div class="form-group m-form__group row">
                        <label class="col-sm-2 col-form-label" style="font-size: 16px">
                            <strong>API ID & Key</strong>
                        </label>
                        <div class="col-sm-3" style="padding-left: 5px">
                            <input type="text" class="form-control m-input m-input--solid" v-model="api_id">
                        </div>
                        <div class="col-sm-7" style="padding-left: 5px">
                            <input type="text" class="form-control m-input m-input--solid" v-model="api_key">
                        </div>
                    </div>
                    <div style="height:20px"></div>
                </div>
            </div>
            <div id="swagger-ui"></div>
        </div>
    </div>
  </div>
</div>
</template>
<script>

import Vue from 'vue'
import $ from "jquery";

import swagger from '../../assets/swagger.json';

import batteries from './batteries.vue';
import App from '../../App.vue'
const app = new Vue(App)

export default {
  name: 'api',
  data: function(){
    return{
      api_key: "",
      api_id: ""
    }
  },
  methods: {
    get_session: function(){
    this.$http.get('/get_porfile').then(response => {
      this.api_key = "Key: "+response.body.api_key;
      this.api_id = "ID: "+response.body.api_id;
    });
   },
   swagger_api: function(){
        var url = window.location.origin + '/swagger/swagger.json';
      const swagger_url = new URL(window.location);
      swagger_url.pathname = swagger_url.pathname.replace("index.html", "swagger.json");
      swagger_url.hash = "";
      const ui = SwaggerUIBundle({
        url:  url,
        dom_id: '#swagger-ui',
        deepLinking: false,
        plugins: [
          SwaggerUIBundle.plugins.DownloadUrl,
          SwaggerUIStandalonePreset
        ],
        layout: "StandaloneLayout"
      })
      window.ui = ui
    },
    resizeScreen: function(){
      // $('#double-scroll').doubleScroll();
      // var table_width = $("#swagger-ui").width();
      // $(".doubleScroll-scroll").width(table_width);
    },
    select_menu_link: function(){
      $("li").removeClass(" m-menu__item--active");
      $(".api").addClass(" m-menu__item--active");
      $("#m_aside_left").removeClass("m-aside-left--on");
      $("body").removeClass("m-aside-left--on");
      $(".m-aside-left-overlay").removeClass("m-aside-left-overlay");
    }
  },
  mounted(){
   this.get_session();
    this.resizeScreen();
    this.swagger_api();
    window.addEventListener('load', this.swagger_api);
    window.addEventListener('resize', this.resizeScreen);
    this.select_menu_link();
  }
}
</script>

<style lang="scss">
</style>
