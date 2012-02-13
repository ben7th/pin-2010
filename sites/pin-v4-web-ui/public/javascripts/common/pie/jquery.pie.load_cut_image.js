// 在某个容器中加载图片，并且图片通过调整以不超过容器大小，margin自动留白
pie.load_inner_img = function(src, box_elm, parent_elm, before_resize_func){
  var img_elm = jQuery('<img style="display:none;" src="'+src+'" />');
  parent_elm.show().empty().append(img_elm);

  img_elm.bind('load',function(){
    (before_resize_func || function(){})();

    img_elm.fadeIn(500);
    i_resize(box_elm, img_elm);
  })

  //  计算图片缩放宽度，高度，负margin
  //  分两步走：
  //  1 如果宽度超出，减小宽度，计算高度
  //  2 如果高度超出，减小高度，计算宽度
  //  最后计算margin

  var i_resize = function(elm, img_elm){
    var width  = elm.width();
    var height = elm.height();

    var iw = img_elm.width();
    var ih = img_elm.height();

    var w1, h1, rw, rh, ml, mt;

    //step 1
    if(iw > width){w1 = width; h1 = ih * width / iw;}
    else{w1 = iw; h1 = ih;}

    //step 2
    if(h1 > height){rh = height; rw = w1 * height / h1;}
    else{rh = h1; rw = w1;}

    //margin
    ml = (width - rw) / 2; mt = (height - rh) / 2;

    img_elm.css('width',rw).css('height',rh);
    img_elm.css('margin-left',ml).css('margin-top',mt);
  }
}

// 在某个容器中加载图片，并且图片通过调整以最佳自适应容器大小，填满容器同时避免宽高比变化
pie.load_cut_img = function(src, box_elm, parent_elm, before_resize_func){
  var img_elm = jQuery('<img style="display:none;" src="'+src+'" />');
  parent_elm.show().empty().append(img_elm);

  img_elm.bind('load',function(){
    (before_resize_func || function(){})();

    img_elm.fadeIn(500);
    i_resize(box_elm, img_elm);
  })

  //  计算图片缩放宽度，高度，负margin
  //  分两步走：
  //  1 如果宽度不等，调齐宽度，计算高度
  //  2 如果此时高度不足，补齐高度
  //  最后计算margin

  var i_resize = function(elm, img_elm){
    var width  = elm.width();
    var height = elm.height();

    var iw = img_elm.width();
    var ih = img_elm.height();

    var w1, h1, rw, rh, ml, mt;

    //step 1
    if(iw != width){w1 = width; h1 = ih * width / iw;}
    else{w1 = iw; h1 = ih;}

    //step 2
    if(h1 < height){rh = height; rw = w1 * height / h1;}
    else{rh = h1; rw = w1;}

    //margin
    ml = (width - rw) / 2; mt = (height - rh) / 2;

    img_elm.css('width',rw).css('height',rh);
    img_elm.css('margin-left',ml).css('margin-top',mt);
  }
}