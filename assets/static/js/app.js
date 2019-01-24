// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import Vue from 'vue'
import VueResource from 'vue-resource'
import VueRouter from 'vue-router'
import Notifications from 'vue-notification'

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"


// Import Vue components
import App from "../components/App"
import settings from "../components/settings"
import commands from "../components/commands"
import routers from "../components/routers"
import nvrs from "../components/nvrs"
import sites from "../components/sites"
import status_report from "../components/status_report"
import api from "../components/api"
import messages from "../components/messages"
import shares from "../components/shares"
import sims from "../components/sims"
import single_sims from "../components/single_sims"
import dashboard from "../components/dashboard"
import single_battery from "../components/single_battery"
import batteries from "../components/batteries"

Vue.config.productionTip = false
Vue.use(VueResource)
Vue.use(VueRouter)
Vue.use(Notifications)

const router = new VueRouter({
  mode: 'history',
  routes: [
    {
      path: '/settings',
      name: 'settings',
      component: settings,
    },
    {
      path: '/commands',
      name: 'commands',
      component: commands,
    },
    {
      path: '/routers',
      name: 'routers',
      component: routers,
    },
    {
      path: '/nvrs',
      name: 'nvrs',
      component: nvrs,
    },
    {
      path: '/sites',
      name: 'sites',
      component: sites,
    },
    {
      path: '/status_report',
      name: 'status_report',
      component: status_report,
    },
    {
      path: '/api',
      name: 'api',
      component: api,
    },
    {
      path: '/messages',
      name: 'messages',
      component: messages,
    },
    {
      path: '/shares',
      name: 'shares',
      component: shares,
    },
    {
      path: '/sims',
      name: 'sims',
      component: sims,
    },
    {
      path: '/sims/:number',
      name: 'single_sims',
      component: single_sims
    },
    {
      path: '/dashboard',
      name: 'dashboard',
      component: dashboard
    },
    {
      path: '/battery/:id',
      name: 'single_battery',
      component: single_battery
    },
    {
      path: '/batteries',
      name: 'batteries',
      component: batteries
    }
  ],
});

let user_id =  $("#app").attr("data-user")

new Vue({
  el: '#app',
  router,
  template: '<App/>',
  data: {
    user_id: user_id
  },
  components: { App }
}).$mount('#app');