pie.load(function(){

  var load_cover = function(cover_elm){
    var cover_src = cover_elm.domdata('src');
    var a_elm = cover_elm.find('a');

    if(!jQuery.string(cover_src).blank()){
      pie.load_cut_img(cover_src, cover_elm, a_elm, function(){
        cover_elm.removeClass('nil');
      });
    }
  }

  //版头
  var cover_elm = jQuery('.page-index-top .wallpaper');
  pie.load_cut_img(cover_elm.domdata('src'),cover_elm,cover_elm);

  // 微博
  load_cover(jQuery('.page-index-top .weibo .cover'));

  // 主题条目
  jQuery('.page-index-top .feeds .cover').each(function(){
    load_cover(jQuery(this));
  });

  // 收集册
  jQuery('.page-index-top .collections .cover').each(function(){
    load_cover(jQuery(this));
  });

})