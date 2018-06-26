var vm = new Vue({
 el: '#sites_main',
  data: {
    dataTable: null,
    m_form_search: "",
    mapEditView: "",
    show_loading: false,
    show_errors: false,
    show_edit_errors: false,
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
    },
    name: "",
    sim_number: "",
    router_id: "",
    nvr_id: "",
    notes: "",
    map_area: "Dublin, Ireland",
    user_id: "",
    edit_id: "",
    edit_name: "",
    edit_sim_number: "",
    edit_router_id: "",
    edit_nvr_id: "",
    edit_notes: "",
    edit_map_area: ""
  },
  methods: {
      initializeTable: function(){
        sitesDataTable = $('#sites-datatable').DataTable({
          fnInitComplete: function(){
              // Enable TFOOT scoll bars
              $('.dataTables_scrollFoot').css('overflow', 'auto');
              $('.dataTables_scrollHead').css('overflow', 'auto');
              // Sync TFOOT scrolling with TBODY
              $('.dataTables_scrollFoot').on('scroll', function () {
              $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
            });
            $('.dataTables_scrollHead').on('scroll', function () {
              $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
            });
          },
          ajax: {
          url: "/sites/data",
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
            class: "text-center",
            data: function(row, type, set, meta) {
              return '<div class="editSite cursor_to_pointer fa fa-edit" data-id="'+ row.id +'"></div> <div class="deleteSite cursor_to_pointer fa fa-trash" data-id="'+ row.id +'"></div>';
            }
          },
          {
            data: function(row, type, set, meta) {
              return row.name;
            }
          },
          {
            data: function(row, type, set, meta) {
              return row.location.map_area;
            }
          },
          {
            class: "text-center",
            data: function(row, type, set, meta) {
              return row.sim_number;
            }
          },
          {
            data: function(row, type, set, meta) {
              return row.router_name;
            }
          },
          {
            data: function(row, type, set, meta) {
              return row.nvr_name;
            }
          },
          {
            data: function(row, type, set, meta) {
              return row.notes;
            }
          },
          {
            class: "text-center",
            data: function(row, type, set, meta) {
              return moment(row.created_at).format('MMMM Do YYYY, H:mm:ss');
            },
          },
          ],
          autoWidth: false,
          info: false,
          bPaginate: false,
          lengthChange: false,
          scrollX: true,
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
          this.map_area = "Dublin, Ireland"
          $("#latitude").val("53.349805");
          $("#longitude").val("-6.2603010");
        })
        this.addMap();
      },
      onSiteHideShowButton: function() {
        $('.toggle-datatable-columns').modal('show');
      },
      clearForm: function() {
        this.name = "";
        this.sim_number = "";
        this.router_id = "";
        this.nvr_id = "";
        this.notes = "";
        this.map_area = "Dublin, Ireland";
        $('ul#errorOnSite').html("");
        $("#body-site-dis *").prop('disabled', false);
        $("#siteErrorDetails").addClass("hide_me");
        this.map_area = "Dublin, Ireland";
        $("#latitude").val("53.349805");
        $("#longitude").val("-6.2603010");
        this.addMap();
        this.show_errors = false;
      },
      setUserId: function(id){
        this.user_id = id;
      },
      saveModal: function() {
        $('ul#errorOnSite').html("");
        this.show_loading = true;
        this.show_errors = true;
        $("#body-site-dis *").prop('disabled',true);

        // alert(this.sim_number)

        var name        = this.name,
            map_area    = this.map_area,
            sim_number  = this.sim_number,
            router_id   = this.router_id,
            nvr_id      = this.nvr_id,
            notes       = this.notes,
            latitude    = $("#latitude").val(),
            longitude   = $("#longitude").val(),
            user_id     = this.user_id;


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
        vm.sendAJAXRequest(settings);
      },
      onError: function(jqXHR, status, error) {
        var cList = $('ul#errorOnSite')
        $.each(jqXHR.responseJSON.errors, function(index, value) {
          var li = $('<li/>')
          .text(value)
          .appendTo(cList);
        });
        this.show_errors = true;
        this.show_loading = false;
        $("#body-site-dis *").prop('disabled', false);
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
        this.show_loading = false;
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

          vm.sendAJAXRequest(settings);
      });
    },
    getUniqueIdentifier: function(){
      $(document).on("click", ".editSite", function(){
        var tr = $(this).closest('tr');
        var row = sitesDataTable.row(tr);
        var data = row.data();
        site_id = $(this).data("id");
        vm.onSiteEditButton(site_id, data);
      });
    },
    onSiteEditButton: function(site_id, data) {
       
        var lng = data.location.lng
        var lat = data.location.lat
        var map_area = data.location.map_area

        this.edit_id = site_id;
        this.edit_name = data.name;
        this.edit_sim_number = data.sim_number;
        this.edit_router_id = data.router_id;
        this.edit_nvr_id = data.nvr_id;
        this.edit_notes = data.notes;
        this.edit_map_area = map_area;

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
    },
    updateSitedo: function(){
        $("#body-site-edit-dis *").prop('disabled', true);
        $('ul#errorOnEditSite').html("");
        this.show_loading = true;
        this.show_edit_errors = true;

        var siteID = $("#edit_id").val();

        var name        = this.edit_name,
            map_area    = this.edit_map_area,
            sim_number  = this.edit_sim_number,
            router_id   = this.edit_router_id,
            nvr_id      = this.edit_nvr_id,
            latitude    = $("#edit_latitude").val(),
            longitude   = $("#edit_longitude").val(),
            notes       = this.edit_notes

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
        vm.sendAJAXRequest(settings);
    },
    onEditError: function(jqXHR, status, error) {
      this.show_loading = false;
      $("#body-site-edit-dis *").prop('disabled', false);
      var cList = $('ul#errorOnEditSite')
      $.each(jqXHR.responseJSON.errors, function(index, value) {
        var li = $('<li/>')
        .text(value)
        .appendTo(cList);
      });
      return false;
    },
    onEditSuccess: function(result, status, jqXHR) {
    $.notify({
      message: 'Site has been updated.'
    },{
      type: 'info'
    });
    this.show_loading = false;
    this.editClearFrom();
    $("#edit_site_to_db").modal("hide");
    this.dataTable.ajax.reload();
    return true;
    },
    editClearFrom: function() {
      this.edit_name = ""
      this.edit_map_area = ""
      this.edit_sim_number = ""
      this.edit_router_id = ""
      this.edit_nvr_id = ""
      $('ul#errorOnEditSite').html("");
      $("#body-site-edit-dis *").prop('disabled', false);
      this.show_loading = false;
      this.show_edit_errors = false;
    },
    resizeScreen: function(){
      // Enable TFOOT scoll bars
      $('.dataTables_scrollFoot').css('overflow', 'auto');
      $('.dataTables_scrollHead').css('overflow', 'auto');
      // Sync TFOOT scrolling with TBODY
      $('.dataTables_scrollFoot').on('scroll', function () {
        $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
      });
      $('.dataTables_scrollHead').on('scroll', function () {
        $('.dataTables_scrollBody').scrollLeft($(this).scrollLeft());
      });
    }
  }, // end of methods
   mounted(){
    this.initializeTable();
    this.deleteSite();
    this.getUniqueIdentifier();
    this.resizeScreen();
    window.addEventListener('resize', this.resizeScreen);
   }
});
