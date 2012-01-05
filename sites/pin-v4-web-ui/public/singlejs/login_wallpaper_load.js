//  计算图片缩放宽度，高度，负margin
//  分两步走：
//  1 如果宽度不足，补齐宽度，计算高度
//  2 如果此时高度不足，补齐高度
//  最后计算margin

pie.load(function(){
  var wallpaper_box_elm = jQuery('.page-anonymous-wallpaper');

  var load_wallpaper = function(){
    var src = wallpaper_box_elm.data('img-src');
    wallpaper_box_elm.empty().append('<img style="display:none;" src="'+src+'" />');
    var img_elm = wallpaper_box_elm.find('img');
    jQuery('.wallpaper-toggle .title').html(wallpaper_box_elm.data('title'));

    img_elm.bind('load',function(){
      img_elm.fadeIn(500);
      i_resize();
      jQuery('.wallpaper-toggle').fadeIn();
    })
  }
	
  load_wallpaper();

  var i_resize = function(){
    var width  = wallpaper_box_elm.width();
    var height = wallpaper_box_elm.height();

    var iw  = wallpaper_box_elm.data('width');
    var ih  = wallpaper_box_elm.data('height');
		
    var w1, h1, rw, rh, ml, mt;

    //step 1
    if(iw < width){w1 = width; h1 = ih * width / iw;}
    else{w1 = iw; h1 = ih;}

    //step 2
    if(h1 < height){rh = height; rw = w1 * height / h1;}
    else{rh = h1; rw = w1;}

    //margin
    ml = (width - rw) / 2; mt = (height - rh) / 2;

    wallpaper_box_elm.find('img').css({
			'width'        : rw,
			'height'       : rh,
			'margin-left'  : ml,
			'margin-right' : mt
		});
  }
  
  jQuery(window).resize(i_resize);
	
	// 翻上一页和下一页
  jQuery('.wallpaper-toggle .prev').bind('click',function(){
    var id = wallpaper_box_elm.data('id');

    pie.dont_show_loading_bar();
    jQuery.ajax({
      url  : '/login/wallpapers/'+id+'/prev',
      type : 'GET',
			beforeSend : remove_old_img,
      success : load_res
    })
  })

  jQuery('.wallpaper-toggle .next').bind('click',function(){
    var id = wallpaper_box_elm.data('id');

    pie.dont_show_loading_bar();
    jQuery.ajax({
      url  : '/login/wallpapers/'+id+'/next',
      type : 'GET',
			beforeSend : remove_old_img,
      success : load_res
    })
  })
  
	var remove_old_img = function(){
    var old_img_elm = wallpaper_box_elm.find('img');
    old_img_elm.fadeOut(500,function(){
      old_img_elm.remove();
    });
	}
	
  var load_res = function(res){
    wallpaper_box_elm
      .data('id',      res.id)
      .data('title',   res.title)
      .data('width',   res.width)
      .data('height',  res.height)
      .data('img-src', res.src)

    load_wallpaper();
  }

})