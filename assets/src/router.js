import Vue from 'vue'
import Router from 'vue-router'
import VueResource from "vue-resource"
import Notifications from 'vue-notification'
import VueEvents from "vue-events"

Vue.use(Router)
Vue.use(VueResource)
Vue.use(Notifications)
Vue.use(VueEvents)

import dashboard from './components/views/dashboard.vue'
import sims from './components/views/sims/sims.vue'
import nvrs from './components/views/nvrs/nvrs.vue'
import routers from './components/views/routers/routers.vue'
import sites from './components/views/sites.vue'
import commands from './components/views/commands/commands.vue'
import messages from './components/views/messages/messages.vue'
import batteries from './components/views/batteries/batteries.vue'
import api from './components/views/api/api.vue'
import my_profile from './components/views/settings/my_profile.vue'
import three_users from './components/views/three_users.vue'
import activities from './components/views/settings/activities/activities.vue'
import sharing from './components/views/sharing.vue'
import single_battery from './components/views/single_battery.vue'
import single_sims from './components/views/single_sims.vue'
import status_report from './components/views/reports/status_report.vue'

import ShowHide from "./components/shared/show_hide";
Vue.component("v-show-hide", ShowHide);

import HorizontalScroll from "./components/shared/horizontal_scroll";
Vue.component("v-horizontal-scroll", HorizontalScroll);

export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [
    {
      path: '/dashboard',
      name: 'dashboard',
      component: dashboard
    },
    {
      path: '/sims',
      name: 'sims',
      component: sims
    },
    {
      path: '/nvrs',
      name: 'nvrs',
      component: nvrs
    },
    {
      path: '/routers',
      name: 'routers',
      component: routers
    },
    {
      path: '/sites',
      name: 'sites',
      component: sites
    },
    {
      path: '/commands',
      name: 'commands',
      component: commands
    },
    {
      path: '/messages',
      name: 'messages',
      component: messages
    },
    {
      path: '/batteries',
      name: 'batteries',
      component: batteries
    },
    {
      path: '/api',
      name: 'api',
      component: api
    },
    {
      path: '/my_profile',
      name: 'my_profile',
      component: my_profile
    },
    {
      path: '/three_users',
      name: 'three_users',
      component: three_users
    },
    {
      path: '/activities',
      name: 'activities',
      component: activities
    },
    {
      path: '/sharing',
      name: 'sharing',
      component: sharing
    },
    {
      path: '/battery/:id',
      name: 'single_battery',
      component: single_battery
    },
    {
      path: '/sims/:number',
      name: 'single_sims',
      component: single_sims
    },
    {
      path: '/status_report',
      name: 'status_report',
      component: status_report
    }
  ]
})
