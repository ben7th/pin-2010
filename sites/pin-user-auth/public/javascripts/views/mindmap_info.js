pie.load(function(){
  $$(".cache_mindmap_image").each(function(dom){
    var gmt = new GetMindmapImage(dom.id,pie.pin_url_for("pin-mindmap-image-cache"));
    gmt.get_mindmap_image();
  });
  
  var title_dom = jQuery(".title")
  if(title_dom.attr("data-mode") == "edit"){
    var map_id = jQuery(".title").attr("data-map-id")
    jQuery(".title").editable("/mindmaps/"+map_id+"/change_title", {
      name : "title",
      indicator : '保存中...',
      method : "PUT",
      type : "text",
      cancel : "取消",
      submit : "保存",
      onblur : 'ignore',
      tooltip : '点击修改标题'
    });
  }

});