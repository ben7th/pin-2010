//主题的排版
//“基于内容进行排版”算法的排版部分

pie.load(function(){
  if(jQuery('.page-ogrid.collection-feeds').length == 0) return;

  var col_height_array = [68, 20];
//  var col_height_array = [20, 20];
  var col_width        = 485;
  var padding_bottom   = 18;

  var timeline_height  = 20;

  //普通feed 文艺feed
  jQuery('.page-ogrid.collection-feeds .feed').each(function(){
    var feed_elm = jQuery(this);
    var min_height_col = jQuery.inArray(Math.min.apply(Math,col_height_array),col_height_array);
    var min_height = col_height_array[min_height_col];

    var col_count = 1;
    col_count = parseInt(col_count);

    feed_elm.css('top',min_height).css('left', min_height_col*col_width);
    feed_elm.domdata('col', min_height_col);

    var i;
    for(i=0;i<col_count;i++){
      //pie.log(i, col_count);
      col_height_array[min_height_col+i] = min_height + feed_elm.outerHeight() + padding_bottom;
    }

    //pie.log(col_height_array)

    //排列连接点
    var timeline_node_elm = feed_elm.find('.timeline-node');
    var arrow_elm = timeline_node_elm.find('.arrow');

    var top_juedui = min_height; //图标应该处于的绝对垂直位置
    var top_juedui_fix = [timeline_height, top_juedui].max(); //图标应该低于已经排布到的最大高度
    var offset = top_juedui_fix - top_juedui; //应该下调的距离

    timeline_height = top_juedui_fix + 36;

    if(min_height_col == 0){
      timeline_node_elm
        .css('top',-16 + offset)
        .css('right',-47) //(950 - 40) / 2 - 16 - 1(border)
        .show();
      arrow_elm.addClass('at-left');
    }else{
      timeline_node_elm
        .css('top',-16 + offset)
        .css('left',-47) //(950 - 40) / 2 - 16 - 1(border)
        .show();
      arrow_elm.addClass('at-right');
    }

    

  });

  jQuery('.page-ogrid.collection-feeds').css('height',Math.max.apply(Math,col_height_array));
  jQuery('.page-ogrid.collection-feeds').animate({'opacity':1},300)
});