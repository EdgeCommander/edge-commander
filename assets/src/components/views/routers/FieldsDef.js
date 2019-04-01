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
    name: 'ip',
    title: 'IP',
    sortField: 'ip',
    togglable: true
  },
  {
    name: 'username',
    title: 'Username',
    sortField: 'username',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'password',
    title: 'Password',
    sortField: 'password',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'is_monitoring',
    title: 'Monitoring',
    sortField: 'is_monitoring',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    formatter (value) {
      return value === true ? 'Yes' : 'No'
    }
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