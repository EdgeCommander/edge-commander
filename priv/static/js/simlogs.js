var initializeSimLogsTable;
initializeSimLogsTable = function() {
  // $('#sim_logs').DataTable();
  $('#sim_logs').DataTable({
    ajax: {
      url: "/sims",
      dataSrc: function(data) {
        console.log(data);
        return data.logs;
      },
      error: function(xhr, error, thrown) {
        if (xhr.responseJSON) {
          console.log(xhr.responseJSON.message);
        } else {
          console.log("Something went wrong, Please try again.");
        }
      }
    },
    columns: [
      {
        data: function(row, type, set, meta) {
          return row.number;
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.name;
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.allowance;
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.volume_used_today;
        }, sWidth: "200px"
      },
      {
        data: function(row, type, set, meta) {
          return row.volume_used_yesterday;
        }, sWidth: "200px"
      },
      {
        data: function(row, type, set, meta) {
          return row.percentage_used;
        }, sWidth: "200px"
      },
      {
        data: function(row, type, set, meta) {
          console.log(row);
          var days_left = (row.allowance_in_number - row.current_in_number) / (row.current_in_number - row.yesterday_in_number)
          return days_left;
        }
      }
    ],
    autoWidth: false,
    sScrollX: "100%",
    sScrollXInner: "110%",
    bScrollCollapse: true,
    info: false,
    bPaginate: true,
    pageLength: 50,
    "language": {
      "emptyTable": "No data available"
    },
    order: [[0, "desc"]],
  });
};


window.initializeSimLogs = function() {
  initializeSimLogsTable();
};