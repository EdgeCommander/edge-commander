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
    name: '__slot:source_url',
    title: 'Open URL',
    sortField: 'source_url',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'last_voltage',
    title: 'Last Voltage (V)',
    sortField: 'name',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'divide_value'
  },
  {
    name: 'last_seen',
    title: 'Last Seen',
    sortField: 'created_at',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'formatDateTime|DD-MM-YYYY HH:mm:ss'
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