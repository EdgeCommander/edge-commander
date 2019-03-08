import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import $ from "jquery";
import 'bootstrap'
import 'bootstrap/dist/css/bootstrap.min.css';
import './assets/css/dataTables.semanticui.min.css';
import './assets/theme/base/vendors.bundle.css';
import './assets/theme/style.bundle.css';
import DataTable from "datatables.net";
import './assets/css/personal.css';
import './assets/js/custom.js';

Vue.config.productionTip = false

let user_id =  $("#app").attr("data-user")

new Vue({
  router,
  store,
  data: {
    user_id: user_id
  },
  render: h => h(App)
}).$mount('#app')
