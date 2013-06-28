/**
 * @license Copyright 2013 Test License.
 */

(function($){

  var preload = [],
  deferreddatasrc = 'data-low',
  deferredsvgsrc = Modernizr.svg ? 'data-svg' : 'data-nosvg';
  
  if (window.devicePixelRatio >= 2) {
    deferreddatasrc = 'data-high';
  }

  function loadDeferredImages(context) {
    $('img[data-low]', context).each(function() {
      $(this).attr('src', $(this).attr(deferreddatasrc));
    });
    $('img[data-svg]', context).each(function() {
      $(this).attr('src', $(this).attr(deferredsvgsrc));
    });
  }

  function preloadImages() {
    // preload images sequentially
    $(document.createElement("img")).load(function() {
      if (preload[0]) this.src = preload.shift();
    }).trigger("load");
  }

  function indexOfJsonArray(array, key, val) {
    for(var i = 0; i < array.length; i++)
    {
      if(array[i][key] == val)
      {
        return i;
      }
    }
  }

  $(function() {
    loadDeferredImages();
  });
  
})(jQuery);