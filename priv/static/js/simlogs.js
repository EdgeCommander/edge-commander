initializeSimLogsTable = function() {
  // $('#sim_logs').DataTable();
  $('#sim_logs').DataTable({
    ajax: {
      url: "/get_sims_data",
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
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.volume_used_yesterday;
        }
      },
      {
        data: function(row, type, set, meta) {
          return row.percentage_used;
        }
      }
    ],
    autoWidth: false,
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