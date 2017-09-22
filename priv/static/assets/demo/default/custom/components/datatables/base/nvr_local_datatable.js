
var DatatableDataNVR = function() {
    var r = function(r) {
            $("<div/>").attr("id", "child_data_local_" + r.data.id).appendTo("dd")},
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

var nvr_data;
var logs = $.get( "/get_all_nvrs", function( data ) {
  console.log(data.nvrs);
  nvr_data = data.nvrs;
});

setTimeout(function () {
  DatatableDataNVR.init(nvr_data);
}, 2000);
