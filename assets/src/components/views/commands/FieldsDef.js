export default [
  {
    name: '__slot:actions',
    title: 'Actions',
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'rule_name',
    title: 'Rule Name',
    sortField: 'rule_name',
    togglable: true
  },
  {
    name: 'active',
    title: 'Active',
    sortField: 'active',
    togglable: true
  },
  {
    name: 'category',
    title: 'Category',
    sortField: 'category',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'variable',
    title: 'Variable',
    sortField: 'variable',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'value',
    title: 'Value',
    sortField: 'value',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'recipients',
    title: 'Recipients',
    sortField: 'recipients',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'array_to_string'
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