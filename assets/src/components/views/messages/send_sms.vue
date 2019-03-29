<template>
  <div style="float: right; margin-right: 5px;">
  	<a href="javascript:void(0)"  class="btn btn-primary m-btn m-btn--icon" @click="show_model()">
	  <span>
	      <i class="fa fa-plus-square"></i>
	      <span>Send SMS</span>
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

                <div class="modal-body" id="body-sms-dis">
                    <img src="../../../assets/images/loading.gif" id="api-wait" v-if="show_loading">
                    <div class="m-form m-form--fit m-form--label-align-left">
                        <div class="form-group m-form__group row">
                            <label class="col-3 col-form-label">
                                {{form_labels.sim}}
                            </label>
                            <div class="col-9">
                                <select class="form-control m-input" id="toNumber" v-model="toNumber" >
                                  <option v-bind:value="sim.number" v-for="sim in sims_list">{{sim.number}} {{sim.name}} </option>
                                </select>
                            </div>
                        </div>
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
import VueTelInput from 'vue-tel-input'
import { VueAutosuggest } from 'vue-autosuggest';

export default {
  components: {
    VueAutosuggest
  },
  props: ["smsData"],
  data: () => {
    return {
      selected: '',
      options: [{
      data: ['Disconnect', 'Connect', 'Restart', 'Reconnect', 'Status', 'VPN on', 'VPN off', 'Upgrade', 'Internet on', 'Internet off', 'WLAN on', 'WLAN off', 'WLAN on', 'WLAN off', 'On', 'Off', '#01#', '#02#', 'Reboot', 'Cellstatus']
      }],
      filteredOptions: [],
      inputProps: {
        id: "autosuggest__input",
        placeholder: "Type SMS command here..."
      },
      sims_list: "",
      form_labels: {
        sim: "SIM",
        message: "Message",
        submit_button: "Send",
        add_title: "Send SMS",
        hide_show_title: "Show/Hide Columns",
        add_sms_button: "Send SMS",
        hide_show_button: "OK"
      },
			show_loading: false,
      show_errors: false,
      show_add_messages: "",
      show_add_errors: false,
      smsMessage: "",
      toNumber: "",
      smsMessage_text: "",
      toggle: false
    }
  },

  watch: {
    smsData() {
      this.updatePropsValue(this.smsData)
    }
  },
  mounted(){
    this.get_sims();
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

    updatePropsValue(router) {
      this.smsMessage_text = router.sms_message
      this.toNumber = router.sim_number
    },
    saveData (e) {
      this.show_loading = true;
      this.$http.post('/send_sms', {
        sms_message: this.smsMessage_text,
        sim_number:  this.toNumber,
        user_id: this.$root.user_id
      }).then(function (response) {
        if (response.body.status != 0) {
          this.$notify({group: 'notify', title: response.body.error_text, type: 'error'});
        }else{
          this.$notify({group: 'notify', title: 'Your message has been sent.'});
        }
        this.clearForm()
        jQuery('#addModel').modal('hide')
      }).catch(function (error) {
        this.show_loading = false;
        this.clearForm();
      });
    },

    show_model(){
		  jQuery('#addModel').modal('show')
    },

    clearForm () {
      this.smsMessage_text = "";
      this.toNumber = "";
      this.show_add_errors = false;
      this.$events.fire("router-added", {})
    },

    get_sims: function(){
      this.$http.get('/all_sim').then(response => {
        this.sims_list = response.body.sims;
      });
    },
  }
}
</script>