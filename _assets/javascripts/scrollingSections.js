// elements assigned to this plugin will be set up so that the page will alert when a new element is scrolled to, and any link that is a hash to an element's ID will be intercepted and scrolled to

$.fn.setupSectionsToScroll = function(options) {

  var $sections = this,
  current_page_index = 0,
  $current_section,
  $window = $(window),
  popstate_lock = true,
  scroll_check_lock = false,
  scroll_check_binded = false,
  scroll_check_page_lock = false,
  halfwaypoint = $window.height() / 2,
  settings = $.extend({
    // offsetY defaults to the first section in the list
    offsetY: $sections.length ? $sections.first().offset().top * -1 : 0,
    hashSuffix: '_hash'
  }, options);

  function set_new_page(index, temp_lock_popstate) {
    temp_lock_popstate = typeof temp_lock_popstate !== 'undefined' ? temp_lock_popstate : popstate_lock;
    current_page_index = index;
    $current_section = $sections.eq(current_page_index);
    $('body').trigger('new_page', [ current_page_index ]);
    // if (history.pushState && setHash) {
    //   history.pushState(null, null, '#' + $current_section.attr('id'));
    // }
    popstate_lock = temp_lock_popstate;
    // document.location.hash = $current_section.attr('id').replace(settings.hashSuffix, '');
    var baseUrl = window.location.href.split('#')[0];
    window.location.replace(baseUrl + '#' + $current_section.attr('id').replace(settings.hashSuffix, ''));
  }

  function scroll_to_page_by_id(id) {
    scroll_check_page_lock = true;
    id += settings.hashSuffix;

    set_new_page($sections.index($sections.filter(id)));

    scroll_to_id(id, settings.offsetY, function() {
      scroll_check_page_lock = false;
    });

    // $.scrollTo(id, { axis: 'y', duration: 300, offset: settings.offsetY, onAfter: function() {
    //   scroll_check_page_lock = false;
    //   // console.log('scroll_check_page_lock is false');
    // }});
  }

  function process_scroll_check() {
    scroll_check_lock = false;

    if (!scroll_check_page_lock) {
      var current_section_top = $current_section.offset().top,
      current_section_bottom = current_section_top + $current_section.outerHeight(),
      window_top = $window.scrollTop(),
      scrolled_from_top_of_current_section = (current_section_top - halfwaypoint - window_top) * -1,
      left_to_scroll_in_current_section = current_section_bottom - window_top - halfwaypoint;
      // console.log('--------------------');
      // console.log('halfwaypoint: ' + halfwaypoint);
      // console.log('window top: ' + window_top);
      // console.log('current page top: ' + curTop);
      // console.log('current page bottom: ' + current_section_bottom);
      // console.log('left to scroll: ' + left_to_scroll_in_current_section);
      // console.log('scrolled from top: ' + scrolled_from_top_of_current_section);

      $('body').trigger('scroll_check', [ window_top ]);

      if (left_to_scroll_in_current_section < 0) { // scrolling to next page
        if (current_page_index < $sections.length - 1) {
          set_new_page(current_page_index + 1, true);
          // console.log('scrolled to next page');
        }
      }
      else if (scrolled_from_top_of_current_section < 0) { //scrolling to prev page
        if (current_page_index > 0) {
          set_new_page(current_page_index - 1, true);
          // console.log('scrolled to prev page');
        }
      }
    }
  }

  var check_scroll_for_page = function() {
    if (scroll_check_lock) // we don't want to overlap timeouts
      return;

    scroll_check_lock = true;
    setTimeout(process_scroll_check, 100);
  };

  function set_selected_page_by_scroll() {
    if (!scroll_check_binded) { // make sure to only bind this once
      $window.on('scroll', check_scroll_for_page);
      scroll_check_binded = true;
    }
  }

  function is_on_screen(elm) {
    var viewportHeight = $(window).height(),
        scrollTop = $(window).scrollTop(),
        elementTop = $(elm).offset().top;

    return (elementTop > scrollTop) && (elementTop < (viewportHeight + scrollTop));
  }

  if ($sections.length) {
    // rename all IDs for sections to get rid of hash jump
    $sections.attr('id', function() {
      return this.id + settings.hashSuffix;
    });

    if (document.location.hash != '') {
      scroll_to_page_by_id(document.location.hash);
    }

    set_selected_page_by_scroll();

    // Scroll to section on current page. Section must have ID equal to the hash.
    $('a[href^="#"]').on('click', function() {
      scroll_to_page_by_id($(this).attr('href'));
      return false;
    });

    $window.on('resize', function() {
      halfwaypoint = $window.height() / 2;
    });

    // $window.on('popstate', function(e) {
    //   if (!popstate_lock) {
    //     if (document.location.hash != '') {
    //       scroll_to_page_by_id(document.location.hash);
    //     }
    //   }
    //   popstate_lock = false;
    // });
  }

  return this.each(function(i) {
    // determine current section
    if (is_on_screen(this)) {
      set_new_page(i);
      return false;
    }
  });
};
