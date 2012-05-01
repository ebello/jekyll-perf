(function($){

  function indexOfJsonArray(array, key, val) {
    for(var i = 0; i < array.length; i++)
    {
      if(array[i][key] == val)
      {
        return i;
      }
    }
  }
  
})(jQuery);