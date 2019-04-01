<template>
  <div class="m-input-icon m-input-icon--left">
      <input type="text" class="form-control m-input m-input--solid" placeholder="Search..." v-model="search" @keyup="vendorFilterGlobal"  autocomplete="off">
      <span class="m-input-icon__icon m-input-icon__icon--left">
      <span> <i class="la la-search"></i></span>
      </span>
  </div>
</template>

<style scoped>
</style>

<script>
export default {
  data () {
    return {
      search: "",
      allParams: {}
    }
  },
  methods: {
    vendorFilterGlobal () {
      this.allParams.search = this.search.toLowerCase()
      this.$events.fire('sims-filter-set', this.allParams)
    }
  }
}
</script>