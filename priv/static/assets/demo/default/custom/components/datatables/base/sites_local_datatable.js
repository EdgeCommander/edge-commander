var vm = new Vue({
 el: '#sites_main',
  data(){
    return{
      dataTable: null,
      m_form_search: "",
      mapEditView: "",
      headings: [
        {column: "Actions"},
        {column: "Name"},
        {column: "Location"},
        {column: "Sim Number"},
        {column: "Router Name"},
        {column: "NVR Name"},
        {column: "Notes"},
        {column: "Created At"},
      ],
      form_labels: {
        name: "Name",
        location: "Location",
        sim: "SIM",
        router: "Router",
        nvr: "NVR",
        notes: "Notes",
        latitude: "Latitude",
        longitude: "Longitude",
        add_title: "Add Site",
        edit_title: "Edit Site",
        hide_show_title: "Show/Hide Columns",
        add_site_button: "Add Site",
        hide_show_button: "OK",
        submit_button: "Save changes"
      }
    }
  },
  methods: {
      initializeTable: function(){
        sitesDataTable = $('#sites-datatable').DataTable({
          ajax: {
          url: "/sites",
            dataSrc: function(data) {
              return data.sites;
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
            class: "text-center width-60",
            data: function(row, type, set, meta) {
              return '<div class="editSite cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="deleteSite cursor_to_pointer fa fa-trash" data-id="'+ row.id +'"></div>';
            }
          },
          {
            class: "width-200",
            data: function(row, type, set, meta) {
              return row.name;
            }
          },
          {
            class: "width-300",
            data: function(row, type, set, meta) {
              return row.location.map_area;
            }
          },
          {
            class: "text-center width-150",
            data: function(row, type, set, meta) {
              return row.sim_number;
            }
          },
          {
            class: "width-250",
            data: function(row, type, set, meta) {
              return row.router_name;
            }
          },
          {
            class: "width-250",
            data: function(row, type, set, meta) {
              return row.nvr_name;
            }
          },
          {
            class: "width-250",
            data: function(row, type, set, meta) {
              return row.notes;
            }
          },
          {
            class: "text-center width-250",
            data: function(row, type, set, meta) {
              return moment(row.created_at).format('MMMM Do YYYY, H:mm:ss');
            },
          },
          ],
          autoWidth: false,
          info: false,
          bPaginate: false,
          lengthChange: false,
          // stateSave:  true,
        });
        this.dataTable = sitesDataTable;
      },
      search: function(){
        this.dataTable.search(this.m_form_search).draw();
      },
      showHideColumns: function(column){
        var column = this.dataTable.column(column);
        column.visible( ! column.visible() );
        this.resizeScreen();
      },
      sendAJAXRequest: function(settings){
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
      addMap: function() {
        var mapInitialize = function(){
          var initialLat = $('#latitude').val();
          var initialLong = $('#longitude').val();
          initialLat = initialLat?initialLat:53.349805;
          initialLong = initialLong?initialLong:-6.260310;

          var latlng = new google.maps.LatLng(initialLat, initialLong);
          var options = {
            zoom: 15,
            center: latlng,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          };
          map = new google.maps.Map(document.getElementById("map_canvas"), options);
          geocoder = new google.maps.Geocoder();
          marker = new google.maps.Marker({
            map: map,
            draggable: true,
            position: latlng
          });

          google.maps.event.addListener(marker, "dragend", function () {
            var point = marker.getPosition();
            map.panTo(point);
            geocoder.geocode({'latLng': marker.getPosition()}, function (results, status) {
              if (status == google.maps.GeocoderStatus.OK) {
                var latVal = marker.getPosition().lat();
                var lngVal = marker.getPosition().lng();
                $('#latitude').val(latVal.toFixed(6));
                $('#longitude').val(lngVal.toFixed(6));
              }
            });
          });
        }
        mapInitialize();
        var PostCodeid = '#map_area';
        $(PostCodeid).autocomplete({
          source: function (request, response) {
            geocoder.geocode({
              'address': request.term
            }, function (results, status) {
              response($.map(results, function (item) {
                return {
                  label: item.formatted_address,
                  value: item.formatted_address,
                  lat: item.geometry.location.lat(),
                  lon: item.geometry.location.lng()
                };
              }));
            });
          },
          select: function (event, ui) {
            var latVal = ui.item.lat;
            var lngVal = ui.item.lon;
            $('#latitude').val(latVal.toFixed(6));
            $('#longitude').val(lngVal.toFixed(6));
            var latlng = new google.maps.LatLng(latVal, lngVal);
            marker.setPosition(latlng);
            mapInitialize();
          }
        });
      },
      onSiteButton: function() {
        $('.add_site_to_db').modal('show');
        $('.add_site_to_db').on('shown.bs.modal', function () {
          $("#map_area").val("Dublin, Ireland");
          $("#latitude").val("53.349805");
          $("#longitude").val("-6.2603010");
        })
        this.addMap();
      },
      clearForm: function() {
        $("#name").val("");
        $("#notes").val("");
        $('ul#errorOnSite').html("");
        $("#set_to_load").removeClass("loading");
        $("#body-site-dis *").prop('disabled', false);
        $("#siteErrorDetails").addClass("hide_me");
        $("#map_area").val("Dublin, Ireland");
        $("#latitude").val("53.349805");
        $("#longitude").val("-6.2603010");
        this.addMap();
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
      saveModal: function() {
        $('ul#errorOnSite').html("");
        $("#api-wait").removeClass("hide_me");
        $("#body-site-dis *").prop('disabled',true);
        $("#siteErrorDetails").addClass("hide_me");

        var name        = $("#name").val(),
            map_area    = $("#map_area").val(),
            sim_number  = $('#sim_number').find(":selected").val(),
            router_id   = $('#router_id').find(":selected").val(),
            nvr_id      = $('#nvr_id').find(":selected").val(),
            notes       = $("#notes").val(),
            latitude    = $("#latitude").val(),
            longitude   = $("#longitude").val(),
            user_id     = $("#user_id").val();


        var data = {};
            data.name = name;
            data.sim_number = sim_number;
            data.router_id = router_id;
            data.nvr_id = nvr_id;
            data.notes = notes;
            data.location = {
              lat: latitude,
              lng: longitude,
              map_area: map_area
            };
            data.user_id = user_id;

        var settings;

        settings = {
          cache: false,
          data: data,
          dataType: 'json',
          error: this.onError,
          success: this.onSuccess,
          contentType: "application/x-www-form-urlencoded",
          type: "POST",
          url: "/sites/new"
        };
        this.sendAJAXRequest(settings);
      },
      onError: function(jqXHR, status, error) {
        var cList = $('ul#errorOnSite')
        $.each(jqXHR.responseJSON.errors, function(index, value) {
          var li = $('<li/>')
          .text(value)
          .appendTo(cList);
        });
        $("#siteErrorDetails").removeClass("hide_me");
        $("#api-wait").addClass("hide_me");
        $("#body-site-dis *").prop('disabled', false);
        $("#set_to_load").removeClass("loading");
        return false;
      },
      onSuccess: function(result, status, jqXHR) {
        $.notify({
          message: 'Site has been added.'
        },{
          type: 'info'
        });
        $(".modal-backdrop").remove();
        $("#m_modal_1").modal("hide");
        $("#api-wait").addClass("hide_me");
        this.dataTable.ajax.reload();
        this.clearForm();
        return true;
      },
      deleteSite: function() {
        $(document).on("click", ".deleteSite", function() {
          var ruleRow, result;
          result = confirm("Are you sure to delete this Site?");
          if (result === false) {
            return;
          }
          ruleRow = $(this).parents('tr');
          siteID = $(this).attr('data-id');

          var data = {};
          data.id = siteID;
          var settings;

          settings = {
            cache: false,
            data: data,
            dataType: 'json',
            error: function(){return false},
            success: function(){
              this.ruleRow.remove();
              $.notify({
                message: 'Site has been deleted.'
              },{
                type: 'info'
              });
              return true;
            },
            contentType: "application/x-www-form-urlencoded",
            context: {ruleRow: ruleRow},
            type: "DELETE",
            url: "/sites/" + siteID
          };

          var headers, token, xhrRequestChangeMonth;
          token = $('meta[name="csrf-token"]');
          if (token.length > 0) {
            headers = {
            "X-CSRF-Token": token.attr("content")
            };
            settings.headers = headers;
          }
          jQuery.ajax(settings);
      });
    },
    onSiteEditButton: function() {
      $(document).on("click", ".editSite", function(){
         var tr = $(this).closest('tr');
        var row = sitesDataTable.row(tr);
        var data = row.data();

        site_id = $(this).data("id");

       
        $("#saveEditModal").attr('data-id', site_id);
        var lng = data.location.lng
        var lat = data.location.lat
        var map_area = data.location.map_area

        $("#edit_id").val(site_id);
        $("#edit_name").val(data.name);
        $("#edit_map_area").val(map_area);
        $("#edit_sim_number").val(data.sim_number);
        $("#edit_router_id").val(data.router_id);
        $("#edit_nvr_id").val(data.nvr_id);
        $("#edit_notes").val(data.notes);
        $("#edit_longitude").val(lng);
        $("#edit_latitude").val(lat);
        $('#edit_site_to_db').modal('show');
        $('#edit_site_to_db').on('shown.bs.modal', function () {
            editMapInitialize = function(){

            var initialLat = $('#edit_latitude').val();
            var initialLong = $('#edit_longitude').val();
            initialLat = initialLat?initialLat:53.3498053;
            initialLong = initialLong?initialLong:-6.260309699999993;

            var latlng = new google.maps.LatLng(initialLat, initialLong);
            var options = {
              zoom: 15,
              center: latlng,
              mapTypeId: google.maps.MapTypeId.ROADMAP
            };
            map = new google.maps.Map(document.getElementById("edit_map_canvas"), options);
            geocoder = new google.maps.Geocoder();
            marker = new google.maps.Marker({
              map: map,
              draggable: true,
              position: latlng
            });

            google.maps.event.addListener(marker, "dragend", function () {
              var point = marker.getPosition();
              map.panTo(point);
              geocoder.geocode({'latLng': marker.getPosition()}, function (results, status) {
                if (status == google.maps.GeocoderStatus.OK) {
                  var latVal = marker.getPosition().lat();
                  var lngVal = marker.getPosition().lng();
                  $('#edit_latitude').val(latVal.toFixed(6));
                  $('#edit_longitude').val(lngVal.toFixed(6));
                }
              });
            });
          }

          editMapInitialize();
          var PostCodeid = '#edit_map_area';
          $(PostCodeid).autocomplete({
            source: function (request, response) {
              geocoder.geocode({
                'address': request.term
              }, function (results, status) {
                response($.map(results, function (item) {
                  return {
                    label: item.formatted_address,
                    value: item.formatted_address,
                    lat: item.geometry.location.lat(),
                    lon: item.geometry.location.lng()
                  };
                }));
              });
            },
            select: function (event, ui) {
              var latVal = ui.item.lat;
              var lngVal = ui.item.lon;
              $('#edit_latitude').val(latVal.toFixed(6));
              $('#edit_longitude').val(lngVal.toFixed(6));
              var latlng = new google.maps.LatLng(latVal, lngVal);
              marker.setPosition(latlng);
              editMapInitialize();
            }
          });
        })
      });
    },
    updateSitedo: function(){
        $("#body-site-edit-dis *").prop('disabled', true);
        $('ul#errorOnEditSite').html("");
        $("#api-wait").removeClass("hide_me");
        $("#siteEditErrorDetails").addClass("hide_me");

        var siteID = $("#edit_id").val();

        var name        = $("#edit_name").val(),
            map_area    = $("#edit_map_area").val(),
            sim_number  = $('#edit_sim_number').find(":selected").val(),
            router_id   = $('#edit_router_id').find(":selected").val(),
            nvr_id      = $('#edit_nvr_id').find(":selected").val(),
            latitude    = $("#edit_latitude").val(),
            longitude   = $("#edit_longitude").val(),
            notes       = $("#edit_notes").val()

        var data = {};
            data.name = name;
            data.sim_number = sim_number;
            data.router_id = router_id;
            data.nvr_id = nvr_id;
            data.notes = notes;
            data.location = {
              lat: latitude,
              lng: longitude,
              map_area: map_area
            };
            data.id = siteID;

        var settings;

        settings = {
          cache: false,
          data: data,
          dataType: 'json',
          error: this.onEditError,
          success: this.onEditSuccess,
          contentType: "application/x-www-form-urlencoded",
          type: "PATCH",
          url: "/sites/update"
        };
        this.sendAJAXRequest(settings);
    },
    onEditError: function(jqXHR, status, error) {
      $("#api-wait").addClass("hide_me");
      $("#body-site-edit-dis *").prop('disabled', false);
      var cList = $('ul#errorOnEditSite')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      $("#siteEditErrorDetails").removeClass("hide_me");
      return false;
    },
    onEditSuccess: function(result, status, jqXHR) {
    $.notify({
      message: 'Site has been updated.'
    },{
      type: 'info'
    });
    $("#api-wait").addClass("hide_me");
    this.editClearFrom();
    $("#edit_site_to_db").modal("hide");
    this.dataTable.ajax.reload();
    return true;
    },
    editClearFrom: function() {
      $("#edit_rule_name").val("");
      $("#edit_notes").val("");
      $('ul#errorOnEditSite').html("");
      $("#body-site-edit-dis *").prop('disabled', false);
      $("#siteEditErrorDetails").addClass("hide_me");
    },
    resizeScreen: function(){
      $('#double-scroll').doubleScroll();
      var table_width = $("#sites-datatable").width();
      $(".doubleScroll-scroll").width(table_width);
    }
  }, // end of methods
   mounted(){
    this.initializeTable();
    this.resizeScreen();
    this.deleteSite();
    this.onSiteEditButton();
    window.addEventListener('resize', this.resizeScreen);
   }
});
