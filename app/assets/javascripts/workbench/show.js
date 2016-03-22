$(document).ready(function() {
  if($("#show").length) {
    show();
  }
});

function show() {
  $("[view-bottom]").click(function() {
    $("[data-view='development']").toggle();
  });

  $('.menu-drop').each( function() {
    if($(this).find('a').length < 1) {
      $(this).addClass("disable");
    }
  });

  $('[data-arrow]').each( function() {
    if($(this).is('span')) {
      $(this).addClass("disable");
    }
  });

  $('div.navigation-item').each( function() {
    if($(this).children().length < 1) {
   //   $(this).hide();
    }
  });

  if(!$('#validation-panel li').length) {
    $('#validation-panel').hide();
  }  

  $('.panel').each( function() {
    if($(this).find('.information-panel').length) {
      if(!$(this).find('.information-panel').children().contents().length) {
        $(this).hide();
      }
    }
  }); 

  Mousetrap.bind('left', function() {
    if($('[data-arrow="back"]').children('a').length > 0) {
      location.href = $('[data-arrow="back"] a').attr('href');
    }
  });

  Mousetrap.bind('right', function() {
    if($('[data-arrow="next"]').children('a').length > 0) {
      location.href = $('[data-arrow="next"] a').attr('href');
    }
  });    
}