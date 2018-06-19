var vm = new Vue({
  el: '#sims_details_main',
  data: {
    dataTable: null,
    m_form_search: "",
    show_loading: false,
    SimHeadings: [
      {column: "DateTime"},
      {column: "MB Allowance"},
      {column: "MB Used (Today)"},
      {column: "% Used"},
    ],
    SmsHeadings: [
      {column: "Date"},
      {column: "Type"},
      {column: "Status"},
      {column: "Message"},
    ],
    form_labels: {
      message: "Message",
      send_title: "SMS To",
      send_button: "Send"
    },
    smsMessage: "",
    toNumber: "",
    user_id: "",
    smsMessage_text: ""
  },
  methods: {
    initializeSimsTable: function(){
      simsDataTable = $('#sim-datatable').DataTable({
      ajax: {
      url: "/sims/data/" + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "",
        dataSrc: function(data) {
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
          class: "text-left",
          data: function(row, type, set, meta) {
            return "" + moment(row.date_of_use).format('MMMM Do YYYY, H:mm:ss') +"";
          }
        },
        {
          class: "text-center",
          data: function(row, type, set, meta) {
            allowance_value = row.allowance_in_number
            if (allowance_value == -1.0) {
              allowance_value = "Unlimited";
            }
            return allowance_value;
          }
        },
        {
          class: "text-center",
          data: function(row, type, set, meta) {
            allowance_value = row.allowance_in_number
            current_in_number = row.current_in_number
            if (allowance_value == -1.0) {
              current_in_number = "-";
            }
            return current_in_number;
          }
        },
        {
          class: "text-center",
          data: function(row, type, set, meta) {
            allowance_value = row.allowance_in_number
            percentage_used = row.percentage_used
            if (allowance_value == -1.0) {
              percentage_used = "-";
            }
            return percentage_used;
          }
        }
      ],
      autoWidth: false,
      info: false,
      bPaginate: false,
      lengthChange: false,
      order: [[ 3, "desc" ]],
      scrollX: true,
      // stateSave:  true,
    });
    },
    initializeSmsTable: function(){
      simsDataTable = $('#sms-datatable').DataTable({
      ajax: {
      url: "/sims/sms/" + window.location.href.substring(window.location.href.lastIndexOf('/') + 1) + "",
        dataSrc: function(data) {
          return data.single_sim_sms;
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
          class: "text-left",
          data: function(row, type, set, meta) {
            return "" + moment(row.inserted_at).format('MMMM Do YYYY, H:mm:ss') +"";
          }
        },
        {
          class: "text-center",
          data: function(row, type, set, meta) {
            if(row.type == "MO"){
              return "<span class='m-badge m-badge--metal m-badge--wide'>Incoming</span>";
            }else{
              return "<span class='m-badge m-badge--success m-badge--wide'>Outgoing</span>";
            }
          }
        },
        {
          class: "text-center",
          data: function(row, type, set, meta) {
            return "<span style='text-transform:capitalize'>"+row.status+"</sapn>"
          }
        },
        {
          class: "text-left",
          data: function(row, type, set, meta) {
            str = row.text;
            return str.split("\n").join("<br/>");
          }
        },
      ],
      autoWidth: false,
      info: false,
      bPaginate: false,
      lengthChange: false,
      ordering: false,
      scrollX: true,
      // stateSave:  true,
    });
      this.dataTable = simsDataTable;
    },
    sendAJAXRequest: function(settings) {
      var headers, token, xhrRequestChangeMonth;
      token = $('meta[name="csrf-token"]');
      if (token.length > 0) {
      headers = {
      "X-CSRF-Token": token.attr("content")
      };
      settings.headers = headers;
      }
      return xhrRequestChangeMonth = jQuery.ajax(settings);
    },
    setSimNumber: function(num){
      this.toNumber = num;
    },
    setUserId: function(id){
      this.user_id = id;
    },
    sendSMS: function() {
      this.show_loading = true;
      $("#body-sms-dis *").prop('disabled',true);

      var sms_message  = this.smsMessage_text,
      to_number        = this.toNumber,
      user_id          = this.user_id

      var data = {};
      data.sms_message = sms_message;
      data.sim_number = to_number;
      data.user_id = user_id;

      var settings;

      settings = {
        cache: false,
        data: data,
        dataType: 'json',
        error: this.onSMSError,
        success: this.onSMSSuccess,
        contentType: "application/x-www-form-urlencoded",
        type: "POST",
        url: "/send_sms"
      };
      this.sendAJAXRequest(settings);
    },
    onSMSSuccess: function(result, status, jqXHR) {
      if (result.status != 0) {
      $.notify({
        message: result.error_text
      },{
        type: 'danger'
      });
      } else
      {
      $.notify({
        message: "Your message has been sent."
      },{
        type: 'info'
      });
      }
      $(".modal-backdrop").remove();
      $("#smsModal").modal("hide");
      this.dataTable.ajax.reload();
      this.show_loading = false;
      this.clearForm();
      return true;
    },
    onSMSError: function(jqXHR, status, error) {
      $.notify({
        message: "Something went wrong."
      },{
        type: 'danger'
      });
      this.show_loading = false;
      $("#body-sms-dis *").prop('disabled', false);
      return false;
    },
    clearForm: function() {
      this.smsMessage = "";
      this.smsMessage_text = "";
      $("#body-sms-dis *").prop('disabled', false);
    },
    onSendSMSFocus: function() {
      $('#smsModal').on('shown.bs.modal', function () {
        $('#smsMessage').focus();
      });
    },
    startMORRISChartJS: function () {
      var settingsForMorris;
      var id = window.location.href.substring(window.location.href.lastIndexOf('/') + 1);
      settingsForMorris = {
      cache: false,
      data: {sim_number: id},
      dataType: 'json',
      success: this.onMorrisSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "GET",
      url: "/chartjs/data/" + id
      };

      this.sendAJAXRequest(settingsForMorris);
    },
    addZero: function(i) {
      if (i < 10) {
        i = "0" + i;
      }
      return i;
    },
    getActualFullDate: function() {
      var d = new Date();
      var day = this.addZero(d.getDate());
      var month = this.addZero(d.getMonth()+1);
      var year = this.addZero(d.getFullYear());
      var h = this.addZero(d.getHours());
      var m = this.addZero(d.getMinutes());
      var s = this.addZero(d.getSeconds());
      return year + "-" + month + "-" + day;
    },
    dateExist: function(array, obj) {
      var i = array.length;
      while (i--) {
        if (array[i]["datetime"] == obj) {
          return true;
        }
      }
      return false;
    },
    getUsageValue: function(array, obj) {
      var i = array.length;
      while (i--) {
        if (array[i]["datetime"] == obj) {
          return array[i]["percentage_used"];
        }
      }
      return 0;
    },
    onMorrisSuccess: function (result, status, jqXHR) {

      var labelsZchartjs = [], dataZChartsJS = [];
      var todayDate = vm.getActualFullDate()

      dateExist =  vm.dateExist(result.chartjs_data, todayDate);
      if(dateExist == false){
        var val = vm.getUsageValue(result.chartjs_data, todayDate)
        var data = {percentage_used: val, datetime: todayDate}
        result.chartjs_data.push(data)
      }

      $.each(result.chartjs_data, function( index, element ) {
        labelsZchartjs.push(element.datetime);
        dataZChartsJS.push(element.percentage_used);
      });

      var chartColors = {
        red: 'rgb(255, 99, 132)',
        orange: 'rgb(255, 159, 64)',
        yellow: 'rgb(255, 205, 86)',
        green: 'rgb(75, 192, 192)',
        blue: 'rgb(54, 162, 235)',
        purple: 'rgb(153, 102, 255)',
        grey: 'rgb(231,233,237)'
      };

      var randomScalingFactor = function() {
        return (Math.random() > 0.5 ? 1.0 : -1.0) * Math.round(Math.random() * 100);
      }
      var config = {
        type: 'line',
        data: {
          labels: labelsZchartjs,
          datasets: [{
            label: "",
            fill: false,
            backgroundColor: chartColors.blue,
            borderColor: chartColors.blue,
            data: dataZChartsJS,
          }]
        },
        options: {
          legend: {
            labels: {
              boxWidth: 0,
              fontStyle: "bold",
              fontSize: 18
            }
          },
          responsive: true,
          tooltips: {
            bodyFontStyle: "bold",
            mode: 'label',
          },
          hover: {
            mode: 'nearest',
            intersect: true
          },
          scales: {
            xAxes: [{
              ticks: {
                  autoSkip : true,
                  callback: function(value, index, values) {
                    return new moment(value).format('YYYY-MM-DD');
                  }
              },
              display: true,
              fontStyle: "bold",
              scaleLabel: {
                fontStyle: "bold",
                display: false,
                labelString: 'Date & Time'
              }
            }],
            yAxes: [{
              ticks: {
                  min: 0,
                  max: 100,
                  stepSize: 20
              },
              display: true,
              fontStyle: "bold",
              scaleLabel: {
                fontStyle: "bold",
                display: true,
                labelString: '% Allowance Used'
              }
            }]
          }
        }
      };

      $("#api-wait").addClass("hide_me");
      var ctx = document.getElementById("canvas").getContext("2d");
      var ctx_div = document.getElementById("canvas");
      ctx_div.height = 200;
      window.myLine = new Chart(ctx, config);
      this.resizeTableDiv();
    },
    resizeTableDiv: function() {
      var window_width = $(window).width();
      var objDiv = document.getElementById("iam_canvas");
      var convasHeight = objDiv.scrollHeight + 22;
      $("#sm_datatable_inner").css("min-height", convasHeight).css("max-height", convasHeight).css("overflow-y", "auto");
    },
    resizeSMSTable: function(){
    $('#double-scroll').doubleScroll();
    var table_width = $("#sms-datatable").width();
    $(".doubleScroll-scroll").width(table_width);
   },
   autocompleteInputSms: function(){
      $(function () {
        var availableTags = [
         "Disconnect",
          "Connect",
          "Restart",
          "Reconnect",
          "Status",
          "VPN on",
          "VPN off",
          "Upgrade",
          "Internet on",
          "Internet off",
          "WLAN on",
          "WLAN off",
          "On",
          "Off",
          "#01#",
          "#02#"
        ];
        $("#smsMessage").autocomplete({
          source: availableTags,
          minLength: 0,
          change: function(event, ui) {
            if (ui.item) {
              vm.smsMessage_text = ui.item.value
              vm.smsMessage = ui.item.value
            }
          }
        });
        $('#input_img').on('click', function () {
          $('#smsMessage').autocomplete('search' , '');
        });
        $('#smsMessage').on('keyup', function () {
          value =  $(this).val();
          vm.smsMessage_text = value
        });
      });
    }
  }, // end of methods
  mounted(){
    this.initializeSimsTable();
    this.initializeSmsTable();
    this.onSendSMSFocus();
    this.startMORRISChartJS();
    this.resizeSMSTable();
    window.addEventListener('resize', this.startMORRISChartJS);
    window.addEventListener('resize', this.resizeSMSTable);
  }
});
