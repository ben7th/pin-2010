//  计算图片缩放宽度，高度，负margin
//  分两步走：
//  1 如果宽度不足，补齐宽度，计算高度
//  2 如果此时高度不足，补齐高度
//  最后计算margin

pie.load(function(){
  var wallpaper_box_elm = jQuery('.page-anonymous-wallpaper');

  var load_wallpaper = function(){
    var src = wallpaper_box_elm.domdata('img-src');
    wallpaper_box_elm.empty().append('<img style="display:none;" src="'+src+'" />');
    var img_elm = wallpaper_box_elm.find('img');
    img_elm.bind('load',function(){
      img_elm.fadeIn(500);
      i_resize();

      jQuery('.wallpaper-toggle .title').html(wallpaper_box_elm.domdata('title'));
      jQuery('.wallpaper-toggle').fadeIn();
    })
  }

  load_wallpaper();

  jQuery(window).resize(function(){
    i_resize();
  })

  var i_resize = function(){
    var width  = wallpaper_box_elm.width();
    var height = wallpaper_box_elm.height();

    var iw  = wallpaper_box_elm.domdata('width');
    var ih  = wallpaper_box_elm.domdata('height');
    var w1, h1, rw, rh, ml, mt;

    //step 1
    if(iw < width){w1 = width; h1 = ih * width / iw;}
    else{w1 = iw; h1 = ih;}

    //step 2
    if(h1 < height){rh = height; rw = w1 * height / h1;}
    else{rh = h1; rw = w1;}

    //margin
    ml = (width - rw) / 2; mt = (height - rh) / 2;

    var img_elm = wallpaper_box_elm.find('img');
    img_elm.css('width',rw).css('height',rh);
    img_elm.css('margin-left',ml).css('margin-top',mt);
  }

  //GET /login/get_next_wallpaper?id=xxx
  //GET /login/get_prev_wallpaper?id=xxx
  jQuery('.wallpaper-toggle .prev').bind('click',function(){
    var id = wallpaper_box_elm.domdata('id');


    jQuery('body')
      .unbind("ajaxStart")
      .unbind("ajaxComplete");
    var old_img_elm = wallpaper_box_elm.find('img');
    old_img_elm.fadeOut(500,function(){
      old_img_elm.remove();
    })

    jQuery.ajax({
      url  : pie.pin_url_for('pin-user-auth', '/login_get_prev_wallpaper?id='+id),
      type : 'GET',
      success : function(res){
        load_res(res);
      }
    })
  })

  jQuery('.wallpaper-toggle .next').bind('click',function(){
    var id = wallpaper_box_elm.domdata('id');

    jQuery('body')
      .unbind("ajaxStart")
      .unbind("ajaxComplete");
    var old_img_elm = wallpaper_box_elm.find('img');
    old_img_elm.fadeOut(500,function(){
      old_img_elm.remove();
    })

    jQuery.ajax({
      url  : pie.pin_url_for('pin-user-auth', '/login_get_next_wallpaper?id='+id),
      type : 'GET',
      success : function(res){
        load_res(res);
      }
    })
  })
  
  var load_res = function(res){
    wallpaper_box_elm
      .domdata('id',     res.id)
      .domdata('title',  res.title)
      .domdata('width',  res.width)
      .domdata('height', res.height)
      .domdata('img-src',res.src)

    load_wallpaper();
  }

})