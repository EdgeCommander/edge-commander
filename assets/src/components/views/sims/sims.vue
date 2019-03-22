<template>
<div>
    <sim-edit-modal :showSimModal="showSimModal" :simEditData="simEditData"/>
    <div class="m-content">
        <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
            <div class="m-portlet__body" style="padding: 10px;">
                <!--begin: Search Form -->
                <div class="m-form m-form--label-align-right m--margin-bottom-10">
                    <div class="row align-items-center">
                        <div class="col-md-8 order-2 order-md-1">
                            <div class="form-group m-form__group row align-items-center">
                                <div class="col-md-5">
                                    <v-sims-filters />
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4 order-1 order-md-2">
                            <v-show-hide :vuetableFields="vuetableFields" />
                            <add-sim :simData="AddSim" />
                        </div>
                    </div>
                </div>
                    <v-horizontal-scroll />
                <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
                  <div class="table-responsive">
                    <vuetable ref="vuetable" 
                      api-url="/sims/data/json"
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
                    <template slot="actions" slot-scope="props">
                      <span @click="onActionClicked($event, props.rowData)" class="fa fa-edit cursor"></span>
                    </template>
                    <template slot="number" slot-scope="props">
                       <router-link v-bind:to="get_url(props.rowData.number)" class="m-menu__link">
                        {{props.rowData.number}}
                      </router-link>

                    </template>
                      <template slot="allowance" scope="props" class="text-center">
                          {{get_mb_allownce(props.rowData)}}
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
import AddSim from "./add_sim";
import SimFilters from "./sims_filters";
import SimEditModal from "./sim_edit";

export default {
  components: {
    AddSim,
    TableWrapper,
    "v-sims-filters": SimFilters,
    "sim-edit-modal": SimEditModal
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
      simData: {},
      simEditData: {},
      showSimModal: false
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
    this.$events.$on('sims-filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('sim-added', e => this.onSimAdded())
    this.$events.$on('close-sim-modal', eventData => this.onCloseSimModal(eventData))
    this.$events.$on('refresh-sim-table', eventData => this.onRefreshSimTable(eventData))
  },

  methods: {
    onFilterSet (filters) {
      this.moreParams = {
        "search": filters.search
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onRefreshSimTable() {
      this.$nextTick( () => this.$refs.vuetable.refresh())
    },

    onSimAdded () {
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

    onActionClicked(e, data) {
      this.simEditData = data;
      this.showSimModal = true;
    },

    onCloseSimModal(modal) {
      this.simEditData = {};
      this.showSimModal = modal;
    },

    get_url(number) {
      return "/sims/" + number
    },

    get_mb_allownce(rowData){
      let allowance = rowData.allowance
      let addon = rowData.addon
      if(addon == "Unknown"){
        allowance = "-"
      }else if(allowance == '-1.0'){
        allowance = "Unlimited"
      }
      return allowance;
    }
  }
}
</script>
<style lang="scss">
</style>
