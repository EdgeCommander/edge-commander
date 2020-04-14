<template>
  <div id="single_sims">
    <div class="m-content">
        <div class="row">
          <div class="col-sm-12 ">
                <div class="m-portlet m-portlet--mobile" style="margin-bottom: 5px">
                  <div class="row battery_details" style="padding:10px">
                    <div class="col-lg-5 col-md-4" style="padding-top: 10px">
                      <span>Name:</span> {{sim_name}}
                    </div>
                   <div class="col-lg-3 col-md-4" style="padding-top: 10px">
                     <span>Number:</span> {{toNumber}}
                   </div>
                   <div class="col-lg-2 col-md-4" style="padding-top: 10px">
                     <span>Daily SMS Count:</span> <span id="dailySMSCount">{{total_count_daily_sms}}</span>
                   </div>
                    <div class="col-lg-2 btn_back">
                      <router-link v-bind:to="'/sims'" class="btn btn-default">Back to Sims</router-link>
                    </div>
                  </div>
                </div>
            </div>
            <!--begin::Modal-->
            <div class="modal fade" id="m_modal_4" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true" data-backdrop="static" data-keyboard="false">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <img src="../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                        <div class="modal-body">
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close" id="clear_chartsjs">
                      <span aria-hidden="true">
                      &times;
                      </span>
                            </button>
                            <div style="width:100%;" id="iam_canvas">
                                <canvas id="canvas"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!--end::Modal-->
        </div>
        <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
            <div class="m-portlet__body" style="padding: 10px;">
                <div class="m-portlet__body  m-portlet__body--no-padding">
                    <div style="margin: 10px 0">
                        <h3 class="pull-left">
                          SMS History <span style="font-size:12px">(Last 10 SMS) </span>
                        </h3>
                        <div class="pull-right">
                            <button type="button" class="btn btn-primary m-btn m-btn--icon" @click="show_model()">
                              <span><i class="fa fa fa-paper-plane-o"></i><span>Send SMS</span></span>
                            </button>
                        </div>
                        <div class="clearfix"></div>
                    </div>
                    <table id="sms-datatable" class="table table-striped  table-hover table-bordered display nowrap" cellspacing="0" width="100%">
                        <thead>
                            <tr>
                                <th v-for="(item, index) in SmsHeadings" v-bind:class="item.class">{{item.column}}</th>
                            </tr>
                        </thead>
                        <tbody>
                          <tr v-for="sms_data in sms_table_data">
                            <td class="text-left">{{formatDateTime(sms_data.inserted_at)}}</td>
                            <td class="text-center" v-html="get_sms_type(sms_data.type)"></td>
                            <td class="text-center" v-html="get_sms_status(sms_data.status)"></td>
                            <td class="text-left">{{sms_data.text}}</td>
                            <td class="text-center">{{formatDateTime(sms_data.delivery_datetime)}}</td>
                          </tr>
                        </tbody>
                    </table>
                    <router-link v-bind:to="'/messages/'+ number" >
                      Show All
                   </router-link>
                </div>
            </div>
        </div>
    </div>
    <div class="modal fade" id="addModel" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" style="display: none;" aria-hidden="true" data-backdrop="static" data-keyboard="false" ref="vuemodal">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content" style="padding: 0px;">
            <div class="modal-header">
                <h5 class="modal-title" id="exampleModalLabel">
                      {{form_labels.send_title}} {{number}}
                  </h5>
                <div class="cancel">
                    <a href="#" id="discardModal" data-dismiss="modal">X</a>
                </div>
            </div>

            <div class="modal-body" id="body-sms-dis">
                <img src="../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                <div class="m-form m-form--fit m-form--label-align-left">
                    <input type="hidden" id="user_id" v-model="user_id">
                    <input type="hidden" id="toNumber" v-model="toNumber">
                    <div class="form-group m-form__group row">
                        <label class="col-3 col-form-label">
                            {{form_labels.message}}
                        </label>
                        <div class="col-9" id="input_container">
                           <vue-autosuggest :suggestions="filteredOptions" @selected="onSelected" @click="show_all" @keyup="addMessage($event)" :input-props="inputProps"></vue-autosuggest>
                            <a href="javascript:void(0)" @click='toggle = !toggle'> Needs help?</a>
                        </div>
                    </div>
                    <div class="helping_div" v-show='toggle'>
                      <strong>For Dovado Router</strong>
                      <ul>
                          <li><b>Disconnect:</b> Shut down modem connection.</li>
                          <li><b>Connect:</b> Connect modem connection</li>
                          <li><b>Restart:</b> Restarts the router</li>
                          <li><b>Reconnect:</b> Reset connection and connect</li>
                          <li><b>Status:</b> Reports current connection status of the router.</li>
                          <li><b>Upgrade:</b> Upgrade to latest available firmware.</li>
                          <li><b>VPN on and VPN off:</b> Turn on or off VPN access in manual mode.</li>
                          <li><b>WLAN on and WLAN off:</b> Turn on or off WiFi. For 2.4 GHz use WLAN24 and WLAN5 for 5 GHz.</li>
                          <li><b>Internet on and Internet off:</b> Turn on or off LAN access to Internet.</li>
                      </ul>
                      <strong>For Teltonika Router</strong>
                      <ul>
                          <li><b>Reboot:</b> Restarts the router</li>
                          <li><b>Cellstatus:</b> Reports current connection status of the router.</li>
                      </ul>
                    </div>
                </div>
                <!--end::Form-->
            </div>
            <div class="modal-footer">
                <button id="" type="button" class="btn btn-default" @click="sendSMS($event)">
                    {{form_labels.send_button}}
                </button>
            </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import jQuery from 'jquery'
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import moment from "moment";
import {Chart} from 'highcharts-vue'
import { VueAutosuggest } from 'vue-autosuggest';

export default {
  components: {
    TableWrapper,
    highcharts: Chart,
    VueAutosuggest
  },
  data() {
    return {
      selected: '',
      options: [{
      data: ['Disconnect', 'Connect', 'Restart', 'Reconnect', 'Status', 'VPN on', 'VPN off', 'Upgrade', 'Internet on', 'Internet off', 'WLAN on', 'WLAN off', 'WLAN on', 'WLAN off', 'On', 'Off', '#01#', '#02#', 'Reboot', 'Cellstatus']
      }],
      filteredOptions: [],
      inputProps: {
        id: "autosuggest__input",
        onInputChange: this.onInputChange,
        placeholder: "Type SMS command here..."
      },
      toggle: false,
      show_loading: false,
      smsMessage_text: "",
      sim_name: "",
      toNumber: "",
      user_id: this.$root.user_id,
      total_count_daily_sms: 0,
      sms_table_data:[],
      SimHeadings: [
        {column: "DateTime", class: "text-left"},
        {column: "MB Allowance", class: "text-center"},
        {column: "MB Used (Today)", class: "text-center"},
        {column: "% Used", class: "text-center"},
      ],
      SmsHeadings: [
        {column: "Send at", class: "text-left"},
        {column: "Type", class: "text-center"},
        {column: "Status", class: "text-center"},
        {column: "Message", class: "text-left"},
        {column: "Delivered at", class: "text-center"}
      ],
      form_labels: {
        message: "Message",
        send_title: "SMS To",
        send_button: "Send"
      },
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 60,
      sortOrder: [
        {
          field: 'datetime',
          direction: 'desc',
        }
      ],
      number: this.$route.params.number,
      css: TableWrapper,
      moreParams: {
        number: this.$route.params.number
      },
      fields: FieldsDef
    }
  },
  watch: {
    perPage(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.vuetable.refresh();
      });
    },

    paginationComponent(newVal, oldVal) {
      this.$nextTick(() => {
        this.$refs.pagination.setPaginationData(
          this.$refs.vuetable.tablePagination
        );
      });
    }
  },

  beforeUpdate() {
    document.addEventListener("resize", this.setScrollBar());
  },

  mounted() {
    this.$nextTick(function() {
      window.addEventListener('resize', this.setScrollBar);
      this.setScrollBar()
    });
    this.init_sms_table_data(this.number)
    this.get_sim_data()
    this.count_daily_sms()
  },

  methods: {
    onSelected(option) {
      this.smsMessage_text = option.item;
    },

    show_all() {
      this.filteredOptions = [{
        data: this.options[0].data
      }];
    },

    addMessage(e) {
      this.smsMessage_text = e.target.value;
    },

    onInputChange(text) {
      const filteredData = this.options[0].data.filter(item => {
        return item.toLowerCase().indexOf(text.toLowerCase()) > -1;
      }).slice(0, this.limit);

      this.filteredOptions = [{
        data: filteredData
      }];
    },

    show_model(){
      jQuery('#addModel').modal('show')
    },

    sendSMS: function() {
      this.show_loading = true;
      this.$http.post('/sims/'+this.toNumber+'/sms', {
        sms_message: this.smsMessage_text
      }).then(function (response) {
        if (response.body.status != 0) {
          this.$notify({group: 'notify', title: response.body.error_text, type: 'error'});
        }else{
          this.$nextTick(function () {
            let counter = 6
            window.setInterval(() => {
              counter--
              if(counter >= 1){
                this.init_sms_table_data(this.number)
              }
            }, 3000);
          });
          this.$notify({group: 'notify', title: 'Your message has been sent.'});
        }
        jQuery('#addModel').modal('hide')
        this.init_sms_table_data(this.toNumber)
        this.show_loading = false;
        this.clearForm();
      }).catch(function (error) {
        this.show_loading = false;
        this.clearForm();
      });
    },

    clearForm: function() {
      this.smsMessage = "";
      this.smsMessage_text = "";
    },

    init_sms_table_data(number){
      this.$http.get('/sims/sms/' + number).then(response => {
        this.sms_table_data = response.body.single_sim_sms
      });
    },

    get_sim_data: function(){
      this.$http.get('/sims/'+ this.number+'/json').then(response => {
        this.sim_name = response.body.name;
        this.toNumber = response.body.number;
      });
    },

    count_daily_sms: function(){
      this.$http.get('/daily_sms_count/'+ this.number).then(response => {
        this.total_count_daily_sms = response.body.result
      });
    },

    onFilterSet (filters) {
      this.moreParams = {
        "search": filters.search
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onRefreshTable() {
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onAdded () {
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onPaginationData(tablePagination) {
      this.$refs.paginationInfo.setPaginationData(tablePagination);
      this.$refs.pagination.setPaginationData(tablePagination);
    },

    onChangePage(page) {
      this.$refs.vuetable.changePage(page);
    },

    onInitialized(fields) {
      this.vuetableFields = fields;
    },

    showLoader() {
      this.loading = "loading";
    },

    hideLoader() {
      this.loading = "";
    },

    formatDateTime (value) {
      return (value != "")
      ? moment(value).format('DD-MM-YYYY HH:mm:ss')
      : ''
    },

    ensure_allowance(allowance_value){
      if (allowance_value == -1.0) {
        allowance_value = "Unlimited";
      }
      return allowance_value;
    },

    get_volume_used_today(rowData){
      let allowance_value = rowData.allowance_in_number
      let current_in_number = rowData.current_in_number
      if (allowance_value == -1.0) {
        current_in_number = "-";
      }
      return current_in_number;
    },

    get_percentage_used(rowData){
      let allowance_value = rowData.allowance_in_number
      let percentage_used = rowData.percentage_used
      if (allowance_value == -1.0) {
        percentage_used = "-";
      }
      return percentage_used;
    },

    get_sms_type(value){
      if(value == "MO"){
        return "<span class='m-badge m-badge--metal m-badge--wide'>Incoming</span>";
      }else{
        return "<span class='m-badge m-badge--success m-badge--wide'>Outgoing</span>";
      }
    },

    get_sms_status(value){
      if(value == "accepted"){
        value = "Not Delivered"
      }
      return "<span style='text-transform:capitalize'>"+value+"</sapn>"
    }

  }
}
</script>
<style lang="scss">
</style>
