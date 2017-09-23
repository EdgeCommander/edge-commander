
var DatatableDataNVR = function() {
    var r = function(r) {
          console.log(r.detailCell);
          console.log(r);
          if (r.data.extra != null) {
            // todo create table here
            r.detailCell.html(
                "<table class='ui celled striped table' style='width: 40%;'>\
                      <thead>\
                        <tr>\
                          <th colspan='2'>\
                            Device Information\
                          </th>\
                        </tr>\
                      </thead>\
                      <tbody>\
                        <tr>\
                          <td>Firmware Version</td>\
                          <td>"+ r.data.firmware_version +"</td>\
                        </tr>\
                        <tr>\
                          <td>Model</td>\
                          <td>"+ r.data.model +"</td>\
                        </tr>\
                        <tr>\
                          <td>Device Name</td>\
                          <td>"+ r.data.extra.device_name +"</td>\
                        </tr>\
                        <tr>\
                          <td>Device Type</td>\
                          <td>"+ r.data.extra.device_type +"</td>\
                        </tr>\
                        <tr>\
                          <td>Device Id</td>\
                          <td>"+ r.data.extra.device_id +"</td>\
                        </tr>\
                        <tr>\
                          <td>Encorder Released Date</td>\
                          <td>"+ r.data.extra.encoder_released_date +"</td>\
                        </tr>\
                        <tr>\
                          <td>Encoder Version</td>\
                          <td>"+ r.data.extra.encoder_version +"</td>\
                        </tr>\
                        <tr>\
                          <td>Firmware Released Date</td>\
                          <td>"+ r.data.extra.firmware_released_date +"</td>\
                        </tr>\
                        <tr>\
                          <td>Mac Address</td>\
                          <td>"+ r.data.extra.mac_address +"</td>\
                        </tr>\
                        <tr>\
                          <td>Serial Number</td>\
                          <td>"+ r.data.extra.serial_number +"</td>\
                        </tr>\
                      </tbody>\
                    </table>"
            );
          } else {
            r.detailCell.html("No data available.");
          }
        },
        e = function(src) {
            a = $(".m_nvr_datatable").mDatatable({
                data: {
                    type: "local",
                    source: src,
                    pageSize: 50
                },
                layout: {
                    theme: "default",
                    class: "",
                    scroll: !1,
                    height: 950,
                    footer: !1
                },
                sortable: !0,
                filterable: !1,
                pagination: !0,
                detail: {
                    title: "Load sub table",
                    content: r
                },
                columns: [
                {
                    field: "id",
                    title: "",
                    width: 20,
                    sortable: !1,
                    textAlign: "center"
                },
                {
                    field: "name",
                    title: "Name",
                    width: 150,
                    sortable: !1,
                    selector: !1,
                }, {
                    field: "ip",
                    title: "IP",
                    width: 150
                }, {
                    field: "username",
                    title: "Username",
                    textAlign: "center",
                    width: 100,
                    responsive: {
                        visible: "lg"
                    }
                }, {
                    field: "password",
                    title: "Password",
                    textAlign: "center",
                    width: 150
                }, {
                    field: "is_monitoring",
                    title: "Monitoring",
                    textAlign: "center",
                    width: 100,
                    template: function(t) {
                      console.log(t);
                      if (t.is_monitoring) {
                        return "Yes";
                      } else{
                        return "No";
                      }
                    },
                }, {
                    field: "created_at",
                    title: "Created At",
                    textAlign: "center",
                    template: function(t) {
                      console.log(t);
                      return "" + moment(t.created_at).format('MMMM Do YYYY, H:mm:ss') +"";
                    },
                    width: 200
                }
              ]
            }),
            i = a.getDataSourceQuery();
        $("#m_form_search").on("keyup", function(e) {
            console.log($(this).val().toLowerCase());
            a.search($(this).val().toLowerCase())
        }).val(i.generalSearch)
    };
    return {
        init: function(logs) {
          console.log('test');
            e(logs)
        }
    }
}();

// var nvr_data;
// var logs = $.get( "/get_all_nvrs", function( data ) {
//   console.log(data.nvrs);
//   nvr_data = data.nvrs;
// });

// setTimeout(function () {
//   DatatableDataNVR.init(nvr_data);
// }, 2000);


var get_NVR_data = function() {
  return $.ajax({
    url: "/get_all_nvrs",
    cache: false,
    dataType: 'json',
    contentType: "application/x-www-form-urlencoded",
    type: "GET",
  })
}

$.when(get_NVR_data()).done(function(data){
  DatatableDataNVR.init(data.nvrs);
  console.log(data.nvrs);
});
