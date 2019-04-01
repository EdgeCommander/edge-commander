export default [
  {
    name: '__slot:actions',
    title: 'Actions',
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: '__slot:name',
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'source_url',
    title: 'URL',
    sortField: 'source_url',
    togglable: true
  },
  {
    name: 'active',
    title: 'Active',
    sortField: 'active',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
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