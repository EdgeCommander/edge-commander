<template>
  <div>
    <div class="m-content">
      <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
        <div class="m-portlet__body" style="padding: 10px;">
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right m--margin-bottom-10">
            <div class="row align-items-center">
              <div class="col-md-12">
                <div class="form-group m-form__group row align-items-center">
                  <div class="col-md-12">
                    <div class="m-input-icon m-input-icon--left">
                      <ul class="nav nav-pills" role="tablist">
                        <li class="nav-item">
                            <router-link v-bind:to="'/my_profile'" class="nav-link">My Profile</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/activities'" class="nav-link active show">Activities</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/sharing'" class="nav-link">Sharing</router-link>
                        </li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-4 order-1 order-md-2 m--align-right">
              </div>
            </div>
          </div>
          <!--end: Search Form -->
          <div class="heading_panel">
            <div class="pull-left">
              <h4>Activity Logs <i class="fa fa-long-arrow-right"></i></h4>
            </div>
            <div class="pull-right">
              <div class="row">
                <div class="col-sm-6">
                     <div class="form-group m-form__group row">
                    <label class="col-lg-2 col-form-label">
                        From:
                    </label>
                    <div class="col-lg-10">
                       <date-picker v-model="from_dateTime" ref="datepicker" @change="handleChange" lang="en" date  value-type="format"></date-picker>
                    </div>
                    </div>
                </div>
                <div class="col-sm-6">
                     <div class="form-group m-form__group row">
                    <label class="col-lg-1 col-form-label">
                        To:
                    </label>
                    <div class="col-lg-10">
                       <date-picker v-model="to_dateTime" ref="datepicker" @change="handleChange" lang="en" date  value-type="format"></date-picker>
                    </div>
                    </div>
                </div>
              </div>
            </div>
            <div class="clearfix"></div>
          </div>
          <v-horizontal-scroll />
            <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
              <div class="table-responsive">
                <vuetable ref="vuetable" 
                  api-url="/user_logs"
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
                <template slot="browser" slot-scope="props">
                  <span v-html="get_browser(props.rowData)"></span>
                </template>
                <template slot="country" slot-scope="props">
                  <span v-html="get_country(props.rowData)"></span>
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
import moment from "moment";
import DatePicker from 'vue2-datepicker'

export default {
  components: {
    TableWrapper,
    DatePicker
  },
  data() {
    return {
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 60,
      sortOrder: [
        {
          field: 'inserted_at',
          direction: 'asc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      fields: FieldsDef,
      dateParams: {},
      lang: {
        days: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        months: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        pickers: [],
        placeholder: {
          dateRange: 'Select Date Range'
        }
      },
      from_dateTime: moment().subtract(7, "days").format("YYYY-MM-DD"),
      to_dateTime: moment().format("YYYY-MM-DD")
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
  },

  methods: {
    handleChange(val) {
      this.moreParams = {
        "fromDate": this.from_dateTime,
        "toDate": this.to_dateTime,
      }
      this.$nextTick( () => this.$refs.vuetable.refresh())
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

    formatDateTime (value, fmt) {
      return (value == null)
      ? ''
      : moment(value, 'YYYY-MM-DD HH:mm:ss').format(fmt)
    },

    get_country(rowData){
      let country = rowData.country
      let country_code = rowData.country_code
      if(country != null){
        return '<img src="https://www.countryflags.io/'+country_code+'/shiny/16.png"> '+rowData.country;
      }else{
        return "---"
      }
    },

    get_browser(rowData){
      let browser = rowData.browser
      let platform = rowData.platform
      let browser_icon
      if(browser == 'IE'){
          browser_icon = "internet-explorer"
      }else{
        browser_icon = browser.toLowerCase()
      }
      return '<i class="fa fa-'+browser_icon+'" aria-hidden="true"></i> ' +browser + ' on ' + platform ;
    }


  }
}
</script>

<style lang="scss">
</style>
