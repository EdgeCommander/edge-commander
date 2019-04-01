import "semantic-ui-css/semantic.css";
import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'

import 'bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css';
import './assets/css/dataTables.semanticui.min.css';
import './assets/theme/base/vendors.bundle.css';
import './assets/theme/style.bundle.css';
import './assets/css/personal.css';

import {Vuetable, VuetablePagination, VuetablePaginationDropDown, VuetablePaginationInfo, VuetableFieldCheckbox} from "vuetable-2";
Vue.component("vuetable", Vuetable);
Vue.component("vuetable-pagination", VuetablePagination);
Vue.component("vuetable-pagination-dropdown", VuetablePaginationDropDown);
Vue.component("vuetable-pagination-info", VuetablePaginationInfo);
Vue.component('vuetable-field-checkbox', VuetableFieldCheckbox);
import * as VueGoogleMaps from 'vue2-google-maps'

Vue.use(VueGoogleMaps, {
	load: {
		key: "AIzaSyBfX46k9qCXNL6WR8wu8Jmb8yF4WxrpuUM",
		libraries: "places"
	}
});

Vue.config.productionTip = false

Vue.mixin({
  methods: {
    setScrollBar: () => {
      let tableWidth = document.querySelector("table.vuetable").offsetWidth;
      let tableWrapper = document.querySelector("div.table-responsive").offsetWidth;
      document.querySelector("div.top-horizontal-scroll").style.width = tableWidth + "px";
      document.querySelector("div.top-scrollbar").style.width = tableWrapper + "px"
    },
    menu_collapse: () => {
      let app = document.getElementById("app");
      app.classList.add("m-brand--minimize");
      app.classList.add("m-aside-left--minimize");
      document.querySelector(".menu_expand").style.display = "block";
      document.querySelector("i.m-menu__link-icon").style.display = "inline";
    },
    menu_expand: () => {
      let app = document.getElementById("app");
      app.classList.remove("m-brand--minimize");
      app.classList.remove("m-aside-left--minimize");
      document.querySelector(".menu_expand").style.display = "none";
      document.querySelector("i.m-menu__link-icon").style.display = "inline";
    },
    m_aside_left_offcanvas_toggle: () => {
      let element = document.getElementById("m_aside_left");
      element.classList.toggle("m-aside-left--on");
    }
  }
})

let user_id = document.getElementById("app").getAttribute("data-user"); 

new Vue({
  router,
  store,
  data: {
    user_id: user_id
  },
  render: h => h(App)
}).$mount('#app')
