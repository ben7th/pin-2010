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

pie.mindmap_undo = function(){
  var old_map = window.mindmap;
  var mindmap_id = old_map.id;
  var editmode = old_map.editmode;
  old_map.nodeMenu.unload();
  if(editmode){
    //清空已显示的数据
    jQuery("#mindmap-canvas").html('');

    window.mindmap = new pie.mindmap.BasicMapPaper("#mindmap-canvas",{
      id : mindmap_id,
      data_url : '/mindmaps/' + mindmap_id + '.js',
      editmode : editmode
    }).undo_load();

    delete old_map;
  }
}

pie.mindmap_redo = function(){
  var old_map = window.mindmap;
  var mindmap_id = old_map.id;
  var editmode = old_map.editmode;
  old_map.nodeMenu.unload();
  if(editmode){
    //清空已显示的数据
    jQuery("#mindmap-canvas").html('');

    window.mindmap = new pie.mindmap.BasicMapPaper("#mindmap-canvas",{
      id : mindmap_id,
      data_url : '/mindmaps/' + mindmap_id + '.js',
      editmode : editmode
    }).redo_load();

    delete old_map;
  }
}

//思维导图全局加载
pie.load(function(){
  jQuery("#mindmap-canvas").html('');

  var mindmap_id = jQuery('#mindmap-main').attr('data-id');
  var editmode = jQuery('#mindmap-main').is('.editor');
  var is_widgetmode = jQuery('#mindmap-main').is('.widget');

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
  jQuery(document).delegate('a.toggle-sidebar','click',function(){
    jQuery('#mindmap-sidebar').toggle();
    jQuery(this).toggleClass('open');
    document_resize();
  });

  //undo
  jQuery(document).delegate('.mindmap-paper-toolbar .mindmap-ops .mindmap-undo','click',function(){
    var elm = jQuery(this);
    if(!elm.hasClass('lock')){
      pie.mindmap_undo();
    }
  })

  //redo
  jQuery(document).delegate('.mindmap-paper-toolbar .mindmap-ops .mindmap-redo','click',function(){
    var elm = jQuery(this);
    if(!elm.hasClass('lock')){
      pie.mindmap_redo();
    }
  })

  jQuery(document).delegate('.mindmap-paper-toolbar .ops-intro .hide-it, .mindmap-paper-toolbar .ops-intro .show-it','click',function(){
    var elm = jQuery(this);
    elm.closest('.ops-intro').toggleClass('close');
  })

  //widget模式
  if(is_widgetmode){
    jQuery('.page-mindmap-widget-btns').show();
  }

  function document_resize(){
    var sidebar_elm = jQuery('#mindmap-sidebar');
    var sidebar_width = sidebar_elm.is(':visible') ? sidebar_elm.width():0;

    var height;
    if(is_widgetmode){
      height = jQuery(window).height();
    }else{
      height = jQuery(window).height() - 30;
    }
    var width = jQuery(window).width() - sidebar_width;

    jQuery('#mindmap-main')
      .css('height',height);
    jQuery('#mindmap-resizer')
      .css('height',height)
      .css('width',width);
  }

});
