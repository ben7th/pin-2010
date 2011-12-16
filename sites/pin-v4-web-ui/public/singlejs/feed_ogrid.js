//主题的排版
//“基于内容进行排版”算法的排版部分

pie.load(function(){
  if(jQuery('.page-ogrid.collection-feeds').length == 0) return;

  var COL_HEIGHT_ARRAY = [68, 20];
  var COL_WIDTH        = 485;
  var PADDING_BOTTOM   = 18;
  var TIMELINE_HEIGHT  = 20;
  var NODE_HEIGHT      = 36;

  var load_feeds = function(feed_elms){
    feed_elms.each(function(){
      var feed_elm = jQuery(this);
      
      var min_height_index = jQuery.array(COL_HEIGHT_ARRAY).min_index();
      var min_height       = COL_HEIGHT_ARRAY[min_height_index];

      feed_elm
        .css('top',  min_height)
        .css('left', min_height_index * COL_WIDTH);

      feed_elm
        .domdata('col', min_height_index);

      COL_HEIGHT_ARRAY[min_height_index] = min_height + feed_elm.outerHeight() + PADDING_BOTTOM;

      //排列连接点
      var timeline_node_elm = feed_elm.find('.timeline-node');
      var arrow_elm = timeline_node_elm.find('.arrow');

      var top_juedui = min_height; //图标应该处于的绝对垂直位置
      var top_juedui_fix = jQuery.array([TIMELINE_HEIGHT, top_juedui]).max(); //图标应该低于已经排布到的最大高度
      var offset = top_juedui_fix - top_juedui; //应该下调的距离

      TIMELINE_HEIGHT = top_juedui_fix + NODE_HEIGHT;

      if(min_height_index == 0){
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

    jQuery('.page-ogrid.collection-feeds').css('height', jQuery.array(COL_HEIGHT_ARRAY).max());
  }

  //普通feed 文艺feed
  load_feeds(jQuery('.page-ogrid.collection-feeds .feed'));

  jQuery('.page-ogrid.collection-feeds').animate({'opacity':1},300,function(){
    jQuery('.page-ogrid-feeds-load-more').fadeIn(200);
    jQuery('.page-ogrid-feeds-load-more a.load').bind('click',function(){

      var next_page = parseInt(jQuery('.page-ogrid-feeds-load-more').domdata('next-page'));

      jQuery.ajax({
        url  : window.location.href,
        data : {'page':next_page},
        type : 'GET',
        success : function(res){
          jQuery('.page-ogrid-feeds-load-more').domdata('next-page', next_page+1);

          var feed_elms = jQuery(res).find('.feed');
          
          feed_elms.hide().appendTo(jQuery('.page-ogrid.collection-feeds'));
          load_feeds(feed_elms);
          feed_elms.fadeIn(300);
        }
      })
    })
  });
});