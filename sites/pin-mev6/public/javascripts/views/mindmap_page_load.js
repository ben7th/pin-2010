pie.reload_mindmap = function(){
  var old_map = window.mindmap;
  var mindmap_id = old_map.id;
  var editmode = old_map.editmode;
  jQuery("#mindmap-canvas").html('');

  window.mindmap = new pie.mindmap.BasicMapPaper("#mindmap-canvas",{
    id : mindmap_id,
    data_url : '/mindmaps/' + mindmap_id + '.js',
    editmode : editmode
  }).load();

  delete old_map;

  return window.mindmap;
};

pie.load(function(){

  jQuery("#mindmap-canvas").html('');

  var mindmap_id = jQuery('#mindmap-main').attr('data-id');
  var editmode = jQuery('#mindmap-main').is('.editor');

  window.mindmap = new pie.mindmap.BasicMapPaper("#mindmap-canvas",{
    id : mindmap_id,
    data_url : '/mindmaps/' + mindmap_id + '.js',
    editmode : editmode
  }).load();

  document_resize();
  jQuery(window).resize(document_resize);

  //导图重新居中
  jQuery('a.mindmap-recenter')
    .live("mousedown",function(){jQuery(this).addClass("mousedown")})
    .live("mouseup mouseleave",function(){jQuery(this).removeClass("mousedown")});

  //侧边栏显示/隐藏切换
  jQuery('a.toggle-sidebar').live('click',function(){
    jQuery('#mindmap-sidebar').toggle();
    jQuery(this).toggleClass('open');
    document_resize();
  });

  function document_resize(){
    var sidebar_elm = jQuery('#mindmap-sidebar');
    var sidebar_width = sidebar_elm.is(':visible') ? sidebar_elm.width():0;

    var height = jQuery(window).height() - 40 - 30;
    var width = jQuery(window).width() - sidebar_width;

    jQuery('#mindmap-main')
      .css('height',height);
    jQuery('#mindmap-resizer')
      .css('height',height)
      .css('width',width);
  }

});
