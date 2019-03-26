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
                            <router-link v-bind:to="'/three_users'" class="nav-link">Three Users</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/activities'" class="nav-link">Activities</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/sharing'" class="nav-link active show">Sharing</router-link>
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
            </div>
           <v-show-hide :vuetableFields="vuetableFields" />
              <add-share-user :shareData="AddUser" />
            <div class="clearfix"></div>
          </div>
          <!--begin: Search Form -->
          <div class="m-form m-form--label-align-right m--margin-bottom-10">
            <div class="row align-items-center">
              <div class="col-md-4 order-1 order-md-2 m--align-right">
              </div>
            </div>
          </div>
          <!--end: Search Form -->
          <div>
          </div>
          <v-horizontal-scroll />
          <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
            <div class="table-responsive">
              <vuetable ref="vuetable" 
                api-url="/members"
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
                <span @click="onActionClicked('delete-item', props.rowData)" class="fa fa-trash cursor"></span>
              </template>
              <template slot="sharee_email" slot-scope="props">
                <span v-html="get_sharee_email(props.rowData)"></span>
              </template>
              <template slot="sharer_email" slot-scope="props">
                <span v-html="get_sharer_email(props.rowData)"></span>
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
import AddUser from "./add_share_user";
import moment from "moment";

export default {
  components: {
    TableWrapper,
    "add-share-user": AddUser
  },
  data() {
    return {
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 60,
      sortOrder: [
        {
          field: 'sharer_email',
          direction: 'asc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      fields: FieldsDef,
      shareData: {}
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
    this.$events.$on('sharing-added', e => this.onAdded())
  },

  methods: {
    onFilterSet (filters) {
      this.moreParams = {
        "search": filters.search
      }
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

    onActionClicked(action, data) {
      if (action == "delete-item") {
        if (window.confirm("Are you sure you want to delete this user account?")) {
          this.$http.delete(`/members/${data.id}`).then(response => {
            this.$notify({group: 'notify', title: 'User account has been deleted.'});
          }, error => {
            this.$notify({group: 'notify',  type: "error", title: 'Something went wrong.'});
          });
          this.$nextTick( () => this.$refs.vuetable.refresh())
        } 
      }
    },

    formatDateTime (value, fmt) {
      return (value == null)
      ? ''
      : moment(value, 'YYYY-MM-DD HH:mm:ss').format(fmt)
    },

    get_sharer_email(rowData){
      return "<span style='font-weight: bold;text-transform: capitalize'>"+rowData.sharer_name+"</span></br>" + rowData.sharer_email;
    },

    get_sharee_email(rowData){
      return "<span style='font-weight: bold;text-transform: capitalize'>"+rowData.sharee_name+"</span></br>" + rowData.sharee_email;
    }


  }
}
</script>
<style lang="scss">
</style>
