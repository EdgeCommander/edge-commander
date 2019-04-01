export default [
  {
    name: '__slot:browser',
    title: 'Browser',
    sortField: 'browser',
    togglable: true
  },
  {
    name: 'ip',
    title: 'IP address',
    sortField: 'ip',
    togglable: true
  },
  {
    name: '__slot:country',
    title: 'Country',
    sortField: 'country',
    togglable: true
  },
  {
    name: 'inserted_at',
    title: 'Date & Time',
    sortField: 'inserted_at',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'formatDateTime|DD-MM-YYYY HH:mm:ss'
  },
  {
    name: 'event',
    title: 'Event',
    sortField: 'event',
    togglable: true,
    dataClass: 'event',
  }
]