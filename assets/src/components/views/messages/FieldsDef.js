export default [
  {
    name: 'inserted_at',
    title: 'Send at',
    sortField: 'inserted_at',
    togglable: true,
    callback: 'formatDateTime|DD-MM-YYYY HH:mm:ss'
  },
  {
    name: 'from',
    title: 'From',
    sortField: 'from',
    togglable: true
  },
  {
    name: 'from_name',
    title: 'From: Name',
    sortField: 'from_name',
    togglable: true,
  },
  {
    name: 'to',
    title: 'To',
    sortField: 'to',
    togglable: true
  },
  {
    name: 'to_name',
    title: 'To: Name',
    sortField: 'to_name',
    togglable: true
  },
  {
    name: 'message_id',
    title: 'Message ID',
    sortField: 'message_id',
    togglable: true,
    visible: false
  },
  {
    name: 'type',
    title: 'Type',
    sortField: 'type',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: "return_type"
  },
  {
    name: 'text',
    title: 'Text',
    sortField: 'text',
    togglable: true
  },
  {
    name: 'delivery_datetime',
    title: 'Delivered At',
    sortField: 'delivery_datetime',
    togglable: true,
    callback: 'formatDateTime|DD-MM-YYYY HH:mm:ss'
  },
  {
    name: 'status',
    title: 'Status',
    sortField: 'status',
    callback: 'return_status',
    titleClass: 'text-center',
    dataClass: 'text-center'
  }
]