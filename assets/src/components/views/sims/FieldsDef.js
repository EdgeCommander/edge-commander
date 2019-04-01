import moment from "moment";
export default [
  {
    name: '__slot:actions',
    title: 'Actions',
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: '__slot:number',
    title: 'Number',
    sortField: 'number',
    togglable: true
  },
  {
    name: 'name',
    title: 'Name',
    sortField: 'name',
    togglable: true
  },
  {
    name: 'status',
    title: 'Status',
    sortField: 'name',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: '__slot:allowance',
    title: 'MB Allowance',
    sortField: 'allowance',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'volume_used',
    title: 'MB Used (Today)',
    sortField: 'volume_used',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'yesterday_volume_used',
    title: 'MB Used (Yest.)',
    sortField: 'yesterday_volume_used',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'percentage_used',
    title: '% Used',
    sortField: 'percentage_used',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'remaning_days',
    title: 'Remaning Days',
    sortField: 'remaning_days',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'sim_provider',
    title: 'Sim Provider',
    sortField: 'sim_provider',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'last_log_reading_at',
    title: 'Last Reading',
    sortField: 'last_log_reading_at',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true,
    callback: 'formatDateTime|DD-MM-YYYY HH:mm:ss'
  },
  {
    name: 'last_bill_date',
    title: 'Last Bill Date',
    sortField: 'last_bill_date',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'formatDateTime|DD-MM-YYYY'
  },
  {
    name: 'last_sms',
    title: 'Last SMS',
    sortField: 'last_sms',
    togglable: true
  },
  {
    name: 'last_sms_date',
    title: 'Last SMS DateTime',
    sortField: 'last_sms_date',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'formatDateTime|DD-MM-YYYY HH:mm:ss'
  },
  {
    name: 'sms_since_last_bill',
    title: '# SMS Since Last Bill',
    sortField: 'sms_since_last_bill',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
  }
]