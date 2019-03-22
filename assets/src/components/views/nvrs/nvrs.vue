<template>
<div>
    <edit-modal :showNvrModal="showNvrModal" :nvrEditData="nvrEditData"/>
    <div class="m-content">
        <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
            <div class="m-portlet__body" style="padding: 10px;">
                <!--begin: Search Form -->
                <div class="m-form m-form--label-align-right m--margin-bottom-10">
                    <div class="row align-items-center">
                        <div class="col-md-8 order-2 order-md-1">
                            <div class="form-group m-form__group row align-items-center">
                                <div class="col-md-5">
                                    <v-nvrs-filters />
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4 order-1 order-md-2">
                            <v-show-hide :vuetableFields="vuetableFields" />
                            <add-nvr :nvrData="AddNVR" />
                        </div>
                    </div>
                </div>
                    <v-horizontal-scroll />
                <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
                  <div class="table-responsive">
                    <vuetable ref="vuetable" 
                      api-url="/nvrs/data"
                      :fields="fields"
                      pagination-path=""
                      data-path="data"
                      :per-page="perPage"
                      :sort-order="sortOrder"
                      :append-params="moreParams"
                      @vuetable:pagination-data="onPaginationData"
                      @vuetable:initialized="onInitialized"
                      @vuetable:loading="showLoader"
                      @vuetable:loaded="hideLoader"
                      :css="css.table"
                    >
                    <template slot="name" slot-scope="props">
                        <span class="pull-left">{{props.rowData.name}}</span>
                        <a v-bind:href="get_url(props.rowData)" target="_blank" class="pull-right"><span class="fa fa-external-link"></span></a>
                    </template>
                    <template slot="encoder_released_date" slot-scope="props">
                        {{get_encoder_released_date(props.rowData)}}
                    </template>
                    <template slot="encoder_version" slot-scope="props">
                        {{get_encoder_version(props.rowData)}}
                    </template>
                    <template slot="firmware_released_date" slot-scope="props">
                        {{get_firmware_released_date(props.rowData)}}
                    </template>
                    <template slot="serial_number" slot-scope="props">
                        {{get_serial_number(props.rowData)}}
                    </template>
                    <template slot="mac_address" slot-scope="props">
                        {{get_mac_address(props.rowData)}}
                    </template>
                    <template slot="status" slot-scope="props">
                      <div v-html="get_status(props.rowData)"></div>
                    </template>
                    <template slot="reboot" slot-scope="props">
                      <button class="btn btn-default cursor_to_pointer rebootNVR" data-id="12" style="font-size:10px;padding: 5px;" @click="onActionClicked('reboot-nvr', props.rowData)">Reboot</button>
                    </template>
                    <template slot="actions" slot-scope="props">
                      <span @click="onActionClicked('edit-item', props.rowData)" class="fa fa-edit cursor"></span>&nbsp;
                      <span @click="onActionClicked('delete-item', props.rowData)" class="fa fa-trash cursor"></span>
                    </template>
                    </vuetable>
                  </div>
                  <div style="height: 10px"></div>
                  <div class="">
                    <div class="pull-left">
                      <div class="field perPage-margin">
                      <label>Per Page:</label>
                        <select class="ui simple dropdown" v-model="perPage">
                            <option :value="60">60</option>
                            <option :value="100">100</option>
                            <option :value="500">500</option>
                            <option :value="1000">1000</option>
                        </select>
                      </div>
                      <vuetable-pagination-info ref="paginationInfo"></vuetable-pagination-info>
                    </div>
                    
                    <component :is="paginationComponent" ref="pagination" :css="css.pagination"
                      @vuetable-pagination:change-page="onChangePage"
                    ></component>
                    <div class="clearfix"></div>

                  </div>
                </div>
            </div>
        </div>
    </div>
    
</div>
</template>

<script>
import FieldsDef from "./FieldsDef.js";
import TableWrapper from "./TableWrapper.js";
import AddNVR from "./add_nvr";
import NvrFilters from "./nvrs_filters";
import editModal from "./nvr_edit";
import moment from "moment";

export default {
  components: {
    TableWrapper,
    "add-nvr": AddNVR,
    "v-nvrs-filters": NvrFilters,
    "edit-modal": editModal
  },
  data() {
    return {
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 60,
      sortOrder: [
        {
          field: 'name',
          direction: 'asc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      fields: FieldsDef,
      nvrData: {},
      nvrEditData: {},
      showNvrModal: false
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
    this.$events.$on('nvrs-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('nvr-added', e => this.onNvrAdded())
    this.$events.$on('close-nvr-modal', eventData => this.onCloseModal(eventData))
    this.$events.$on('refresh-nvr-table', eventData => this.onRefreshTable(eventData))
  },

  methods: {
    onFilterSet (filters) {
      this.moreParams = {
        "search": filters.search
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onRefreshTable() {
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onNvrAdded () {
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

    get_url(rowData) {
      return "http://"+ rowData.ip + ":" + rowData.port
    },

    onActionClicked(action, data) {
      if (action == "delete-item") {
        if (window.confirm("Are you sure you want to delete this NVR?")) {
          this.$http.delete(`/nvrs/${data.id}`).then(response => {
            this.$notify({group: 'notify', title: 'NVR has been deleted.'});
          }, error => {
            this.$notify({group: 'notify',  type: "error", title: 'Something went wrong.'});
          });
          this.$nextTick( () => this.$refs.vuetable.refresh())
        } 
      }

      if (action == "reboot-nvr") {
        if (window.confirm("Are you sure you want to reboot this NVR?")) {
          this.$http.get(`/nvrs/${data.id}`).then(response => {
            this.$notify({group: 'notify', title: 'Nvr has been reboot successfully.'});
          }, error => {
            this.$notify({group: 'notify',  type: "error", title: 'Something went wrong.'});
          });
          this.$nextTick( () => this.$refs.vuetable.refresh())
        } 
      }

      if (action == "edit-item") {
        this.nvrEditData = data;
        this.showNvrModal = true;
      }
    },

    onCloseModal(modal) {
      this.nvrEditData = {};
      this.showNvrModal = modal;
    },

    get_encoder_released_date(rowData) {
      if(rowData.extra == null){
        return ""
      }else{
        return rowData.extra.encoder_released_date
      }
    },

    get_encoder_version(rowData) {
      if(rowData.extra == null){
        return ""
      }else{
        return rowData.extra.encoder_version
      }
    },

    get_firmware_released_date(rowData) {
      if(rowData.extra == null){
        return ""
      }else{
        return rowData.extra.firmware_released_date
      }
    },

    get_serial_number(rowData) {
      if(rowData.extra == null){
        return ""
      }else{
        return rowData.extra.serial_number
      }
    },

    get_mac_address(rowData) {
      if(rowData.extra == null){
        return ""
      }else{
        return rowData.extra.mac_address
      }
    },

    get_status(rowData) {
      if(rowData.extra == null){
        return ""
      }else{
        let reason;
        if(rowData.nvr_status == false){
          reason  = rowData.extra.reason;
          if(reason == ''){
            reason = "no reason found.";
          }
          return "<span style='color:#d9534d'>Offline</span> <span>(" + reason + ")</span>";
        }else{
          return "<span style='color:#5cb85c'>Online</span>";
        }
      }
    },

    formatDateTime (value, fmt) {
      return (value == null)
        ? ''
        : moment(value, 'YYYY-MM-DD HH:mm:ss').format(fmt)
    }

  }
}
</script>
<style lang="scss">
</style>
