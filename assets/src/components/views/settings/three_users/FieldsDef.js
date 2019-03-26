export default [
  {
    name: '__slot:actions',
    title: 'Actions',
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'username',
    title: 'Username',
    sortField: 'username',
    togglable: true
  },
  {
    name: 'password',
    title: 'Password',
    sortField: 'password',
    togglable: true
  },
  {
    name: 'bill_day',
    title: 'Bill Day',
    sortField: 'bill_day',
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