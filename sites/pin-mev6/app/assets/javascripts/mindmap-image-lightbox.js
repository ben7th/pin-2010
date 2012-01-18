pie.mindmap.lightbox = {
  show_overlay : function(R){
    if(null != R.overlay_elm){ return; }
    
    R.overlay_elm = jQuery('<div class="overlay"></div>')
      .hide().fadeIn(300);
      
    R.board_elm.after(R.overlay_elm);
  },
  
  hide_overlay : function(R){
    if(null == R.overlay_elm){ return; }
    
    R.overlay_elm.fadeOut(300,function(){
      R.overlay_elm.remove();
      R.overlay_elm = null;
    })
  }
}

pie.mindmap.image_lightbox = {
  init : function(R){
    var LIGHTBOX = pie.mindmap.lightbox;
    
    // 绑定图片事件 绑定事件 live 需用 R.board_elm
    jQuery(R.board_elm).find('.node .image').live('click', function(){
      var elm = jQuery(this);
      LIGHTBOX.show_overlay(R);
      
      var node_id = elm.closest('.node').data('id');
      var node = R.get(node_id);
      var _title = (null == node) ? '' : node.title;
      
      var init_img_width  = 250;
      var init_img_height = init_img_width * 0.75;
      
      var box_elm = jQuery('<div class="box"></div>')
        .css({'height':init_img_height, 'width':init_img_width})
      
      // 载入图片，并动态调整宽高
      var load_img = function(){  
        var full_image_src = node.image.url.replace('/thumb/','/original/');
        var img_elm = jQuery('<img style="display:none;" src="'+full_image_src+'" />');
        box_elm.append(img_elm);
        img_elm.bind('load',function(){
          img_elm.fadeIn(500);
          
          var iw = img_elm.width();
          var ih = img_elm.height();
          
          //img_elm.css({
          //  'margin-left' : - iw / 2,
          //  'margin-top'  : - ih / 2
          //})
          
          var w1, h1;
          var max_width = 640; var max_height = 480; var _min = 200;
          //step 1 最大宽度640，如果超过则调整比例，使得宽度适应外框
          if(iw > max_width){w1 = max_width; h1 = ih * max_width / iw;}
          else{w1 = iw; h1 = ih;}
          
          var box_w = w1; var box_h = h1;
          var ml = 0; var mt = 0;
          
          //step 2 计算margin
          if(w1 < _min){
            box_w = _min;
            ml = (_min - w1)/2;
          }
          
          if(h1 < _min){
            box_h = _min;
            mt = (_min - h1)/2;
          }
          
          if(h1 > max_height){
            box_h = max_height;
            //mt = (max_height - h1)/2;
          }
          img_elm.css({
            'margin-left' : ml,
            'margin-top'  : mt,
            'width'  : w1,
            'height' : h1
          });
          box_elm.animate({
            'width'  : [box_w, 'easeOutSine'],
            'height' : [box_h, 'easeOutSine']
          },200);
          R.image_lightbox_elm.animate({
            'margin-left' : [- (box_w / 2 + 10), 'easeOutSine'],
            'margin-top'  : [- (box_h / 2 + 50), 'easeOutSine']
          },200);
                      
        })
      }
        
      R.image_lightbox_elm = jQuery('<div class="image-lightbox"></div>')
        .append(box_elm)
        .append(jQuery('<div class="title"></div>').text(_title))
        .append(jQuery('<a class="close" href="javascript:;" title="关闭"></a>'))
        //.append(jQuery('<a class="prev" href="javascript:;" title="上一个"></a>'))
        //.append(jQuery('<a class="next" href="javascript:;" title="下一个"></a>'))
        .hide().delay(300).fadeIn(400, load_img)
        //.delay(200).animate({'top': init_top})
        .appendTo(R.overlay_elm);
        
      R.image_lightbox_elm
        .css('margin-left', -  (init_img_width / 2 + 10))
        .css('margin-top',  - (init_img_height / 2 + 50))
        .data('node-id', node_id);
    });
    
    jQuery('.image-lightbox a.close').live('click', function(){
      R.image_lightbox_elm.fadeOut(400, function(){
        LIGHTBOX.hide_overlay(R);
      });
    });
    
    //TODO 上一个，下一个尚未实现
    
    //jQuery('.image-lightbox a.prev').live('click', function(){
    //  var current_node = R.image_lightbox_elm.data('node-id');
    //})
  }
}