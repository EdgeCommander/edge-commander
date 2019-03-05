import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'

import $ from "jquery";

import 'bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css';
import './assets/vendors/base/vendors.bundle.css';
import './assets/css/dataTables.semanticui.min.css';
import './assets/demo/default/base/style.bundle.css';
import DataTable from "datatables.net";

import './assets/css/personal.css';

Vue.config.productionTip = false

let user_id =  $("#app").attr("data-user")

$( document ).ready(function() {
	$(".menu_collapse").click(function(){
	  $("#app").addClass("m-brand--minimize m-aside-left--minimize")
	  $(".menu_expand").css("display", "block")
	  $(".vue_links .m-menu__link-icon").css("display", "inline")
	});

	$(".menu_expand").click(function(){
	  $("#app").removeClass("m-brand--minimize m-aside-left--minimize")
	  $(".menu_expand").css("display", "none")
	  $(".vue_links .m-menu__link-icon").css("display", "")
	});
});

new Vue({
  router,
  store,
  data: {
    user_id: user_id
  },
  render: h => h(App)
}).$mount('#app')
