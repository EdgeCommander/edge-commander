export default [
  {
    name: '__slot:actions',
    title: 'Actions',
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'name',
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'map_area',
    title: 'Location',
    sortField: 'location',
    togglable: true
  },
  {
    name: 'sim_number',
    title: 'Sim Number',
    sortField: 'sim_number',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'router_name',
    title: 'Router Name',
    sortField: 'router_name',
    togglable: true
  },
  {
    name: 'nvr_name',
    title: 'Nvr Name',
    sortField: 'nvr_name',
    togglable: true,
  },
  {
    name: 'notes',
    title: 'Notes',
    sortField: 'notes',
    togglable: true
  },
  {
    name: 'created_at',
    title: 'Created At',
    sortField: 'created_at',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'formatDateTime|DD-MM-YYYY HH:mm:ss'
  }
]