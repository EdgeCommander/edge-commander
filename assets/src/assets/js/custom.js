$( document ).ready(function() {
	$(".menu_collapse").click(function(){
	  $("#app").addClass("m-brand--minimize m-aside-left--minimize")
	  $(".menu_expand").css("display", "block")
	  $(".vue_links .m-menu__link-icon").css("display", "inline")
	});

	$(".menu_expand").click(function(){
	  $("#app").removeClass("m-brand--minimize m-aside-left--minimize")
	  $(".menu_expand").css("display", "none")
	  $(".vue_links .m-menu__link-icon").css("display", "")
	});

	$("#m_aside_left_offcanvas_toggle").click(function(){
    $("#m_aside_left").toggleClass("m-aside-left--on")
  });

});