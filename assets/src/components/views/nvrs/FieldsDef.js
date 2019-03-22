export default [
  {
    name: '__slot:reboot',
    title: 'Reboot',
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
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
    name: 'ip',
    title: 'IP',
    sortField: 'ip',
    togglable: true
  },
  {
    name: 'port',
    title: 'HTTP Port',
    sortField: 'port',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'vh_port',
    title: 'VH Port',
    sortField: 'vh_port',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'sdk_port',
    title: 'SDK Port',
    visible: false,
    sortField: 'sdk_port',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'rtsp_port',
    title: 'RTSP Port',
    sortField: 'rtsp_port',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'username',
    title: 'Username',
    sortField: 'username',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'password',
    title: 'Password',
    sortField: 'password',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'model',
    title: 'Model',
    sortField: 'model',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'firmware_version',
    title: 'Firmware Version',
    sortField: 'firmware_version',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: '__slot:encoder_released_date',
    title: 'Encoder Released Date',
    sortField: 'encoder_released_date',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: '__slot:encoder_version',
    title: 'Encoder Version',
    sortField: 'encoder_version',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: '__slot:encoder_version',
    title: 'Encoder Version',
    sortField: 'encoder_version',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: '__slot:firmware_released_date',
    title: 'Firmware Released Date',
    sortField: 'firmware_released_date',
    togglable: true,
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: '__slot:serial_number',
    title: 'Serial Number',
    sortField: 'serial_number',
    togglable: true,
    visible: false
  },
  {
    name: '__slot:mac_address',
    title: 'Mac Address',
    sortField: 'mac_address',
    togglable: true,
    visible: false
  },
  {
    name: '__slot:status',
    title: 'Status',
    sortField: 'status',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center'
  },
  {
    name: 'is_monitoring',
    title: 'Monitoring',
    sortField: 'is_monitoring',
    togglable: true,
    visible: false,
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
    visible: false,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'formatDateTime|DD-MM-YYYY HH:mm:ss'
  }

]
