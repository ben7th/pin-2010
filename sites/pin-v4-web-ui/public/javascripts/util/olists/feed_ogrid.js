pie.load(function(){
  if(jQuery('.page-ogrid.collection-feeds').length == 0) return;

  var col_height_array = [0, 0, 0, 0];
  var col_width = 240;
  var padding_bottom = 10;

  jQuery('.page-ogrid.collection-feeds .feed').each(function(){
    var feed_elm = jQuery(this);
    var min_height_col = jQuery.inArray(Math.min.apply(Math,col_height_array),col_height_array);
    var min_height = col_height_array[min_height_col];

    feed_elm.css('top',min_height).css('left', min_height_col*col_width);
    feed_elm.domdata('col', min_height_col);

    col_height_array[min_height_col] = min_height + feed_elm.outerHeight() + padding_bottom;
  });

  jQuery('.page-ogrid.collection-feeds').css('height',Math.max.apply(Math,col_height_array));
  jQuery('.page-ogrid.collection-feeds').animate({'opacity':1},300)
})