<template>
<div>
    <div class="m-content">
        <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
            <div class="m-portlet__body" style="padding: 10px;">
                <!--begin: Search Form -->
                <div class="m-form m-form--label-align-right m--margin-bottom-10">
                    <div class="row align-items-center">
                      <div class="col-xl-9 order-3 order-xl-1">
                            <div class="form-group m-form__group row align-items-center">
                              <v-message-filters />
                              <div class="col-md-8">
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
                            </div>
                        </div>
                        <div class="col-xl-3 order-1 order-xl-3 m--align-right">
                            <v-show-hide :vuetableFields="vuetableFields" />
                            <send-sms :smsData="SendSMS" />
                        </div>
                    </div>
                </div>
                <v-horizontal-scroll />
                <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
                  <div class="table-responsive">
                    <vuetable ref="vuetable" 
                      api-url="/get_all_sms"
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
import SendSMS from "./send_sms";
import MessageFilters from "./message_filters";
import moment from "moment";
import DatePicker from 'vue2-datepicker'

export default {
  components: {
    TableWrapper,
    DatePicker,
    "send-sms": SendSMS,
    "v-message-filters": MessageFilters
  },
  data() {
    return {
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 60,
      sortOrder: [
        {
          field: 'id',
          direction: 'asc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      fields: FieldsDef,
      smsData: {},
      search: "",
      dateTime: "",
      allParams: {},
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
    this.$events.$on('filter-set', eventData => this.onFilterSet(eventData))
    this.$events.$on('router-added', e => this.onAdded())
    this.$events.$on('refresh-table', eventData => this.onRefreshTable(eventData))
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
        "fromDate": this.from_dateTime,
        "toDate": this.to_dateTime,
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
      return (value != "")
        ? moment(value, 'YYYY-MM-DD HH:mm:ss').format(fmt)
        : ''
    },

    return_status (status) {
      if(status == "Received"){
        return '<span title="Received"><svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 18 18" width="18" height="18"><path fill="#4FC3F7" d="M17.394 5.035l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-.427-.388a.381.381 0 0 0-.578.038l-.451.576a.497.497 0 0 0 .043.645l1.575 1.51a.38.38 0 0 0 .577-.039l7.483-9.602a.436.436 0 0 0-.076-.609zm-4.892 0l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-2.614-2.556a.435.435 0 0 0-.614.007l-.505.516a.435.435 0 0 0 .007.614l3.887 3.8a.38.38 0 0 0 .577-.039l7.483-9.602a.435.435 0 0 0-.075-.609z"></path></svg></span>'
      }else if(status == "delivered"){
        return '<span title="Delivered"><svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 18 18" width="18" height="18"><path fill="#4FC3F7" d="M17.394 5.035l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-.427-.388a.381.381 0 0 0-.578.038l-.451.576a.497.497 0 0 0 .043.645l1.575 1.51a.38.38 0 0 0 .577-.039l7.483-9.602a.436.436 0 0 0-.076-.609zm-4.892 0l-.57-.444a.434.434 0 0 0-.609.076l-6.39 8.198a.38.38 0 0 1-.577.039l-2.614-2.556a.435.435 0 0 0-.614.007l-.505.516a.435.435 0 0 0 .007.614l3.887 3.8a.38.38 0 0 0 .577-.039l7.483-9.602a.435.435 0 0 0-.075-.609z"></path></svg></span>'
      }else if(status == "Failed"){
        return "<span title='Failed' style='color:#b51010;font-size:16px;font-weight:bold'>&#10005;</span>"
      }else if(status == "accepted"){
        return '<span title="Not Delivered"><svg id="Layer_1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 15" width="18" height="18"><path fill="#92A58C" d="M10.91 3.316l-.478-.372a.365.365 0 0 0-.51.063L4.566 9.879a.32.32 0 0 1-.484.033L1.891 7.769a.366.366 0 0 0-.515.006l-.423.433a.364.364 0 0 0 .006.514l3.258 3.185c.143.14.361.125.484-.033l6.272-8.048a.365.365 0 0 0-.063-.51z"></path></svg></span>'
      }else{
        return "<span title='Pending'><i class='fa fa-clock-o' style='color:gray;font-size:16px'></i></span>"
      }
    },

    return_type(type){
      if(type == "MO"){
        return "<span class='m-badge m-badge--metal m-badge--wide'>Incoming</span>";
      }else{
        return "<span class='m-badge m-badge--success m-badge--wide'>Outgoing</span>";
      }
    }

  }
}
</script>
<style lang="scss">
</style>
