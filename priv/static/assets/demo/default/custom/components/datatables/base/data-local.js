
var DatatableDataLocalDemo = function() {
    var e = function(src) {
            a = $(".m_datatable").mDatatable({
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
                columns: [
                {
                    field: "number",
                    title: "Number",
                    width: 150,
                    sortable: !1,
                    selector: !1,
                    template: function(t) {
                      console.log(t);
                      return '<span data-toggle="modal" data-target="#m_modal_4" style="color: blue;text-decoration: underline;cursor: pointer;" href="#" id="show-morris-graph" data-id="' + t.number + '">' + t.number  + '</span>'
                    }
                }, {
                    field: "name",
                    title: "Name",
                    width: 200
                }, {
                    field: "allowance",
                    title: "Allowance",
                    textAlign: "center",
                    responsive: {
                        visible: "lg"
                    }
                }, {
                    field: "volume_used_today",
                    title: "Volume Used Today",
                    textAlign: "center",
                    width: 200
                }, {
                    field: "volume_used_yesterday",
                    title: "Volume Used Yesterday",
                    textAlign: "center",
                    width: 200,
                    responsive: {
                        visible: "lg"
                    }
                },
                {
                  field: "percentage_used",
                  title: "% Used",
                  textAlign: "center"
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

var dupper;
var logs = $.get( "/get_sims_data", function( data ) {
  console.log(data.logs);
  dupper = data.logs;
  // return data.logs;
  // alert( "Load was performed." );
});
 setTimeout(function () {
  DatatableDataLocalDemo.init(dupper);
  $("#clean_moriss_data").on("click", function () {
    console.log("heell");
    $("#m_morris_1").html("");
  });
  $("#child_data_local").on("click", "#show-morris-graph", function(){
    console.log($(this).data("id"));
    var settingsForMorris;
    settings = {
      cache: false,
      data: {sim_number: $(this).data("id")},
      dataType: 'json',
      error: onMorrisError,
      success: onMorrisSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "GET",
      url: "/create_morris_line_data"
    };

    $.ajax(settings);

  });
 }, 2000);


var onMorrisError, onMorrisSuccess;

onMorrisSuccess = function (result, status, jqXHR) {
  new Morris.Line({
    // ID of the element in which to draw the chart.
    element: 'm_morris_1',
    // Chart data records -- each entry in this array corresponds to a point on
    // the chart.
    data: result.morris_data,
    // The name of the data record attribute that contains x-values.
    xkey: 'datetime',
    parseTime: false,
    // A list of names of data record attributes that contain y-values.
    ykeys: ['percentage_used'],
    // Labels for the ykeys -- will be displayed when you hover over the
    // chart.
    labels: ['Used'],
    lineColors: ['#0b62a4']
  });
  console.log(result.morris_data);
};
