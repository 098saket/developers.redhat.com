var app = window.app = {};

/* 
  Website Cache
*/
app.cache = {};

/* 
  Website Init 
*/ 
app.init = function() {
  
  $(document).foundation();

  /*
    initialize All sliders
  */
  
    app.slider = Swipe(document.getElementById('slider'), {
      auto : 0,
      transitionEnd : function() {
        var idx = app.slider.getPos();
        $('.slider-pager-active').removeClass('slider-pager-active');
        $('.slider-pager a:eq('+idx+')').addClass('slider-pager-active');
      }
    });

    if(app.slider) {
      var numSlides = app.slider.getNumSlides(),
          pagerHtml = "";

      for (var i = 0; i < numSlides; i++) {
        pagerHtml+="<a href='#"+i+"'>"+(i+1)+"</a>";
      }

      $('.slider-pager').html(pagerHtml);
      $('.slider-pager a:first').addClass('slider-pager-active');

      /* Bind Arrows and pager */
      $('.slider-controls').on('click','a',function(e){
        var direction = $(this).data('direction');
        app.slider[direction]();
        e.preventDefault();
      });

      $('.slider-pager').on('click','a',function(e){
        e.preventDefault();
        var idx = this.href.split('#').pop();
        app.slider.slide(idx);
      });
    }


  /*
    Toggle mobile Nav
  */
  $('.nav-toggle').click(function(){
    $('body').toggleClass('nav-open');
  });

  /*
    Mobile Nav dropdown
  */ 
  $('li.has-dropdown').on('click touchend',function(e){
    $(this).toggleClass('sub-nav-open');
  });

  /*
    Developer Materials Slider Filter
  */
  $('form.filters input[type=range]').on('change mousemove',function() {
    // we bind to change and mousemove because Firefox doesn't fire change until mouse is dropped.
    // convert step and total to number of options
    var el = $(this),
        step = el.attr('step'),
        max = el.attr('max') || 100,
        value = this.value,
        labels = el.data('labels').split(','),
        idx = value / step;
    el.next('.skill-display').text( labels[idx] );
  });

  /*
    Developer Materials Rating Filter
  */
  $('input[name="filter-rating"]').on('change input',function() {
    var val = this.value;
    $('.filter-rating-active').removeClass('filter-rating-active');
    $('input[name="filter-rating"]').each(function() {
      if(this.value <= val) {
        $(this).parent().addClass('filter-rating-active');
      }
    });
  });

  /*
    Developer Materials form Reset
  */
  $('.filters-clear').on('click',function(e){
    e.preventDefault();
    app.clearFilters($(this));
  });

  /*
    Show Solutions
  */
  $('[data-open-solution]').on('click',function(e){
    e.preventDefault();
    var el = $(this),
        num = el.data('open-solution'),
        overlay = $('[data-solution='+num+']'),
        position = el.position(),
        offset = el.offset(),
        parentPosition = el.closest('.row').offset(),
        height = el.height(),
        width = el.width();

    $('.solution-open').removeClass('solution-open');
    el.addClass('solution-open');
    
    // Toggle visibility of the ones we want
    $('.solution-overlays').show();
    overlay.show();
    $('[data-solution]').not(overlay).hide();

    // Move the overlay vertically
    $('.solution-overlays').css({
      top : position.top + (height / 2)
    });

    // Move the arrow over
    $('.solution-overlays span.arrow').css({
      left: position.left  + (width / 2)
    });

    // Make the slider for this overlay work
    app.createSlider(overlay.find('.slider'));

    // Bind to close it
    $('body').on('click','.fn-close-overlay',function(e) {
      e.preventDefault();
      $('.solution-overlays').hide();
      $('.solution-open').removeClass('solution-open');
    });

  })


  /*
    Upstream Solutions
  */
  $('.upstream-toggle-more').on('click',function(e){
    e.preventDefault();
    var el = $(this);

    el.toggleClass('upstream-toggle-open');
    el.prev('.upstream-more-content').slideToggle();
  });

};


/*
  Clear All Filters
*/
app.clearFilters = function($el) {
  var form = $('form.filters');
  form[0].reset();
  form.find('input[type=range]').each(function(i,el){
    $(el).attr('value',0);
  });
  $('form.filters input:checked').removeAttr('checked');
  $('.filter-rating-active').removeClass('filter-rating-active');
};

app.createSlider = function($el) {
  var slider = Swipe($el[0], {
    auto : 0,
    transitionEnd : function() {
      $('.current-slide').text(slider.getPos() + 1);
      // $('.slider-pager-active').removeClass('slider-pager-active');
      // $('.slider-pager a:eq('+idx+')').addClass('slider-pager-active');
    }
  });
  // unbind the next/ prev icons
  $('.solutions-slider-controls a').unbind();

  // Bind the next / prev icons
  $('.solutions-slider-controls a').on('click',function(e){
    e.preventDefault();
    var el = $(this);
    var direction = (el.hasClass('next') ? 'next' : 'prev');
    slider[direction]();
  });

  // Update text
  $('span.current-slide').text('1');
  $('.total-slides').text(slider.getNumSlides());


  return slider;
};

app.sso = function() {
  var jbssoserverbase = (document.location.href.indexOf("-stg.") != -1) ? "https://sso-stg.jboss.org" : "https://sso.jboss.org";

  // you can uncomment and fill next variable with another URL to be used for return from SSO login.
  // Full URL of current page is used normally. 
  var _jbssobackurl = window.location.href;
  // you can uncomment and fill next variable with another URL to be used for logout link.
  // Global SSO logout URL is used normally if not defined. 
  var _jbssologouturl = window.location.origin + '/login';
  // postfix appended to returned info snippets before they are placed into HTML 
  var _jbssoinfopostfix = ' |';
  
  // Loads this..
  $.ajax({
    // https://sso.jboss.org/logininfo
    url : jbssoserverbase + "/logininfo?backurl=" + escape(_jbssobackurl) +"&lourl="+ escape(_jbssologouturl),
    context : document.body,
    dataType : "jsonp",
    type : "GET",
    success : function(data, textStatus) {
      
      if (data && data.session) {
        // user is logged in!
        var response = $(data.part1),
            img = response.find('img'),
            name = response[2].innerText;
        $('a.logged-in-name').text(name).prepend(img).show();
        $('[data-dropdown="login"]').hide();

      }
    }
  });
}

$(function() {
  app.init();
  app.sso();
});