export default [
  {
    name: 'datetime',
    title: 'Reading DateTime',
    sortField: 'datetime',
    togglable: true,
    callback: 'formatDateTime|DD-MM-YYYY HH:mm:ss'
  },
  {
    name: 'voltage',
    title: 'Battery voltage (V)',
    sortField: 'voltage',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'divide_value'
  },
  {
    name: 'i_value',
    title: 'Battery current (A)',
    sortField: 'i_value',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'divide_value'
  },
  {
    name: 'vpv_value',
    title: 'Panel voltage (V)',
    sortField: 'vpv_value',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
    callback: 'divide_value'
  },
  {
    name: 'ppv_value',
    title: 'Panel power (W)',
    sortField: 'ppv_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'serial_no',
    title: 'Serial#',
    sortField: 'serial_no',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'cs_value',
    title: 'State of operation',
    sortField: 'cs_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'err_value',
    title: 'Error code',
    sortField: 'err_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'il_value',
    title: 'Load current (A)',
    titleClass: 'text-center',
    dataClass: 'text-center',
    sortField: 'il_value',
    togglable: true,
    callback: 'divide_value'
  },
  {
    name: 'mppt_value',
    title: 'MPPT',
    sortField: 'mppt_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'load_value',
    title: 'Load',
    sortField: 'load_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h19_value',
    title: 'Yield total (Wh)',
    titleClass: 'text-center',
    dataClass: 'text-center',
    sortField: 'h19_value',
    togglable: true,
    callback: 'multiply_value'
  },
  {
    name: 'h20_value',
    title: 'Yield today (Wh)',
    titleClass: 'text-center',
    dataClass: 'text-center',
    sortField: 'h20_value',
    togglable: true,
    callback: 'multiply_value'
  },
  {
    name: 'h21_value',
    title: 'Maximum power today (W)',
    sortField: 'h21_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h22_value',
    title: 'Yield yesterday (W)',
    sortField: 'h22_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true,
    callback: 'multiply_value'
  },
  {
    name: 'h23_value',
    title: 'Maximum power yesterday (W)',
    sortField: 'h23_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'consumed_amphours',
    title: 'Consumed amphours',
    sortField: 'consumed_amphours',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'soc_value',
    title: 'Soc',
    sortField: 'soc_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'time_to_go',
    title: 'Time To Go',
    sortField: 'time_to_go',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'alarm',
    title: 'Alarm',
    sortField: 'alarm',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'relay',
    title: 'Relay',
    sortField: 'relay',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h1_value',
    title: 'Deepest Discharge',
    sortField: 'h1_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h2_value',
    title: 'Last Discharge',
    sortField: 'h2_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h3_value',
    title: 'Average Discharge',
    sortField: 'h3_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h4_value',
    title: 'Charge Cycles',
    sortField: 'h4_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h5_value',
    title: 'Full Discharges',
    sortField: 'h5_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h6_value',
    title: 'Total Drawn',
    sortField: 'h6_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h7_value',
    title: 'Minimum Voltage',
    sortField: 'h7_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h8_value',
    title: 'Maximum Voltage',
    sortField: 'h8_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h9_value',
    title: 'Time Since Last Full Charge',
    sortField: 'h9_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h10_value',
    title: 'Automatic Syncs',
    sortField: 'h10_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  },
  {
    name: 'h11_value',
    title: 'Low Voltage Alarms',
    sortField: 'h11_value',
    titleClass: 'text-center',
    dataClass: 'text-center',
    togglable: true
  }
]