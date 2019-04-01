<template>
<div class="top-scrollbar">
  <div class="top-horizontal-scroll"></div>
</div>
</template>

<style scoped>
.top-scrollbar {
  width: 100%;
  height: 20px;
  overflow-x: scroll;
  overflow-y: hidden;
  margin-left: 14px;

  .top-horizontal-scroll {
    height: 20px;
  }
}
</style>

<script>
export default {
  mounted() {
    document.querySelector("div.top-scrollbar").addEventListener('scroll', this.handleScroll);
    document.querySelector("div.table-responsive").addEventListener('scroll', this.tableScroll);
  },
  methods: {
    handleScroll () {
      document.querySelector("div.table-responsive").scrollLeft = document.querySelector("div.top-scrollbar").scrollLeft
    },

    tableScroll() {
      document.querySelector("div.top-scrollbar").scrollLeft = document.querySelector("div.table-responsive").scrollLeft
    }
  }
}
</script>