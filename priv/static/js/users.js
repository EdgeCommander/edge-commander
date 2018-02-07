var sendAJAXRequest1 = function(settings) {
  var headers, token, xhrRequestChangeMonth;
  token = $('meta[name="csrf-token"]');
  if (token.length > 0) {
    headers = {
      "X-CSRF-Token": token.attr("content")
    };
    settings.headers = headers;
  }
  return xhrRequestChangeMonth = jQuery.ajax(settings);
};

var updateMyProfile = function() {
  $("#updateMyProfile").on("click", function() {
   
    $('ul#errorOnUpdate').html("");
    $("#api-wait").removeClass("hide_me");
    $("#myProfileErrorDetail").addClass("hide_me");

    var firstname      = $("#firstname").val(),
        lastname       = $("#lastname").val(),
        email          = $("#email").val(),
        password       = $("#password").val(),
        id             = $("#id").val()

    var data = {};
        data.firstname = firstname;
        data.lastname = lastname;
        data.email = email;
        data.id = id;

    if ($("#password").val() != ""){
       data.password = password;
    }       

    var settings;

    settings = {
      cache: false,
      data: data,
      dataType: 'json',
      error: onError,
      success: onSuccess,
      contentType: "application/x-www-form-urlencoded",
      type: "PATCH",
      url: "/v1/update_profile"
    };

    sendAJAXRequest1(settings);
  });
};

var onError, onSuccess;

onError = function(jqXHR, status, error) {
  var cList = $('ul#errorOnUpdate')
  $.each(jqXHR.responseJSON.errors, function(index, value) {
    var li = $('<li/>')
        .text(value)
        .appendTo(cList);
  });
  $("#myProfileErrorDetail").removeClass("hide_me");
  $("#api-wait").addClass("hide_me");
  $("#set_to_load").removeClass("loading");
  return false;
};

onSuccess = function(result, status, jqXHR) {
  $.notify({
    // options
    message: 'Profile Details has been updated.'
  },{
    // settings
    type: 'info'
  });
  $("#api-wait").addClass("hide_me");
  $("#password").val("");
  return true;
};

window.initializeUsers = function() {
  updateMyProfile();
};