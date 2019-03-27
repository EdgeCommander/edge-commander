import moment from "moment";
export default [
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
  },
  {
    name: 'last_bill_date',
    title: 'Last Bill Date',
    sortField: 'last_bill_date',
    togglable: true,
    titleClass: 'text-center',
    dataClass: 'text-center',
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