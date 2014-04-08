// dependent on global for imagesrc

(function($) {

  function testContentAttr() {
    // http://jsfiddle.net/westonruter/eAVp2/
    var head = document.getElementsByTagName('head')[0],
        style = document.createElement('style'),
        id = 'test-content-attr';

    style.type = 'text/css';

    var rules = [
      '#' + id + ' { visibility:hidden; position:absolute; } ',
      '#' + id + ':before { content: attr(data-content, string); }'
    ];
    // '#' + id + ':before { content: attr(data-content); }' should pass

    // thanks http://stackoverflow.com/questions/524696/how-to-create-a-style-tag-with-javascript
    if (style.styleSheet)
      style.styleSheet.cssText = rules.join('');
    else
      style.appendChild(document.createTextNode(rules.join('')));

    head.appendChild(style);

    var beforeDiv = document.createElement('div');
    beforeDiv.id = id;
    beforeDiv.setAttribute('data-content', 'hello world');
    document.body.appendChild(beforeDiv);

    var hasBefore = beforeDiv.offsetWidth > 0;

    // Clean up
    style.parentNode.removeChild(style);
    beforeDiv.parentNode.removeChild(beforeDiv);

    return hasBefore;
  }

  function getWindowWidth() {
    if (typeof(window.innerWidth) == 'number')
      return window.innerWidth;
    else // IE6-8
      return document.documentElement.clientWidth;
  }

  $(function() {
    if (!testContentAttr()) {
      // console.log('gotta replace images with javascript');

      $(window).resize(function() {

        /*
        0 = 0
        1 = 768

        */

        var widths = [ 0, 768 ],
            // winWidth = $(window).width(),
            winWidth = getWindowWidth(),
            thresholdIndex;

        // console.log(getWindowWidth());

        for (var x = widths.length - 1; x >= 0; x--) {
          var threshold = widths[x];
          // console.log(x + ": " + threshold + ": " + winWidth);
          if (winWidth >= threshold) {
            thresholdIndex = x;
            break;
          }
        }

        var currentIndex = $('body').data('currentThresholdIndex');
        // if there's a new threshold, load the proper images
        if (currentIndex != thresholdIndex) {
          // console.log('using data-src-' + x);
          $('img[data-src-' + x + '-' + imagesrc + ']').attr('src', function() {
            return $(this).attr('data-src-' + x + '-' + imagesrc);
          });
          $('body').data('currentThresholdIndex', thresholdIndex);
          $('html').removeClass('layout-' + currentIndex).addClass('layout-' + thresholdIndex);
        }
      }).trigger('resize');
    }
  });

})(jQuery);
