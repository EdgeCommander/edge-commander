export default {
	table: {
		tableWrapper: '',
		tableHeaderClass: 'mb-0',
		tableBodyClass: 'mb-0',
		tableClass: 'table table-striped  table-hover table-bordered datatable display nowrap dataTable no-footer',
		loadingClass: 'loading',
		ascendingIcon: 'fa fa-chevron-up',
		descendingIcon: 'fa fa-chevron-down',
		ascendingClass: 'sorted-asc',
		descendingClass: 'sorted-desc',
		sortableIcon: 'fa fa-sort',
		detailRowClass: 'vuetable-detail-row',
		handleIcon: 'fa fa-bars text-secondary',
		renderIcon(classes, options) {
			return `<i class="${classes.join(' ')}"></span>`
		}
	  },
	  pagination: {
	    infoClass: 'pull-left',
	    wrapperClass: 'vuetable-pagination pull-right',
	    activeClass: 'btn-primary',
	    disabledClass: 'disabled',
	    pageClass: 'btn btn-border',
	    linkClass: 'btn btn-border',
	    icons: {
	      first: '',
	      prev: '',
	      next: '',
	      last: '',
	    },
	  }
};
