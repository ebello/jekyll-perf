String.prototype.no_index = function(){return this.replace(/index\.html$/g, '');};
String.prototype.trim_slashes = function(){return this.replace(/\/$/g, '').replace(/^\//, '');};

var preload = [],
retina = window.devicePixelRatio >= 2,
imagesrc = retina ? 'high' : 'low',
deferreddatasrc = retina ? 'data-high' : 'data-low',
deferredsvgsrc = 'data-svg';

// deferredsvgsrc = Modernizr.svg ? 'data-svg' : 'data-nosvg';

function preloadImages() {
  // preload images sequentially
  getImages(preload);
}

// https://gist.github.com/html/1698093
var loadImageCache = {};
function eachStep(collection, callback, endcallback){
  if(collection.length == 0){
    return endcallback && endcallback();
  }

  jQuery.when(callback(collection[0])).always(function(){
    eachStep(collection.slice(1), callback, endcallback);
  });
}

function loadImage(imageSrc) {
  var deferred = jQuery.Deferred();
  if (typeof loadImageCache[imageSrc] === "undefined") {
    preloader = new Image();
    preloader.onload = function() {
      // console && console.log("Loaded image " + this.src);
      deferred.resolve(this.src)
    };
    preloader.onerror = function() {
      // console && console.log("Can not load an image " + this.src);
      deferred.reject(this.src)
    };
    preloader.src = imageSrc;

    loadImageCache[imageSrc] = true;
  }else{
    // console && console.log("Image cached " + imageSrc);
    deferred.resolve(imageSrc);
  }

  return deferred;
};

function getImages(collection, callback){
  eachStep(collection, function(src){
    // console && console.log("Trying to preload image " + src);
    return loadImage(src);
  }, function(){
    // console && console.log("Done preloading");
    if (callback && typeof(callback) === "function") {
      callback();
    }
  });
}

function loadDeferredImages(context) {
  $('img[data-low]', context).each(function() {
    $(this).attr('src', $(this).attr(deferreddatasrc));
  });
  $('img[data-svg]', context).each(function() {
    $(this).attr('src', $(this).attr(deferredsvgsrc));
  });
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
