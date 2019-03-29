<template>
<div>
    <edit-modal :showModal="showModal" :editData="editData"/>
    <div class="m-content">
        <div class="m-portlet m-portlet--mobile" style="margin-bottom: 0">
            <div class="m-portlet__body" style="padding: 10px;">
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
                            <router-link v-bind:to="'/three_users'" class="nav-link  active show">Three Users</router-link>
                        </li>
                        <li class="nav-item">
                            <router-link v-bind:to="'/activities'" class="nav-link">Activities</router-link>
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
                <!--begin: Search Form -->
                <div class="m-form m-form--label-align-right m--margin-bottom-10">
                    <div class="row align-items-center">
                        <div class="col-md-8 order-2 order-md-1">
                            <div class="form-group m-form__group row align-items-center">
                                <div class="col-md-5">
                                    <h4>Three Users <i class="fa fa-long-arrow-right"></i></h4>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4 order-1 order-md-2">
                            <v-show-hide :vuetableFields="vuetableFields" />
                            <add-three-user :userData="AddUser" />
                        </div>
                    </div>
                </div>
                 <v-horizontal-scroll />
                <div id="table-wrapper" :class="['vuetable-wrapper ui basic segment', loading]">
                  <div class="table-responsive">
                    <vuetable ref="vuetable" 
                      api-url="/three_accounts"
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
                      <span @click="onActionClicked('edit-item', props.rowData)" class="fa fa-edit cursor"></span>&nbsp;
                      <span @click="onActionClicked('delete-item', props.rowData)" class="fa fa-trash cursor"></span>
                    </template>
                    </vuetable>
                  </div>
                  <div style="height: 10px"></div>
                  <div class="">
                    <div class="pull-left" style="display: none;">
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
import AddUser from "./add_three_user";
import EditModal from "./three_user_edit";
import moment from "moment";

export default {
  components: {
    TableWrapper,
    "add-three-user": AddUser,
    "edit-modal": EditModal
  },
  data() {
    return {
      paginationComponent: "vuetable-pagination",
      loading: "",
      vuetableFields: false,
      perPage: 500,
      sortOrder: [
        {
          field: 'username',
          direction: 'asc',
        }
      ],
      css: TableWrapper,
      moreParams: {},
      fields: FieldsDef,
      userData: {},
      editData: {},
      showModal: false
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
    this.$events.$on('close-modal', eventData => this.onCloseModal(eventData))
    this.$events.$on('refresh-table', eventData => this.onRefreshTable(eventData))
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
        if (window.confirm("Are you sure you want to delete this three user?")) {
          this.$http.delete(`/three_accounts/${data.id}`).then(response => {
            this.$notify({group: 'notify', title: 'Three user has been deleted.'});
          }, error => {
            this.$notify({group: 'notify',  type: "error", title: 'Something went wrong.'});
          });
          this.$nextTick( () => this.$refs.vuetable.refresh())
        } 
      }
      if (action == "edit-item") {
        this.editData = data;
        this.showModal = true;
      }
    },

    onCloseModal(modal) {
      this.editData = {};
      this.showModal = modal;
    },

    formatDateTime (value, fmt) {
      return (value == null)
        ? ''
        : moment(value, 'YYYY-MM-DD HH:mm:ss').format(fmt)
    },

    array_to_string (value) {
      return value.toString();
    }

  }
}
</script>
<style lang="scss">
</style>
