(function(){
  pie.load(function(){
    //导图标题现场编辑
    $$("li.mindmap").each(function(item){
      var li_item = jQuery(item);
      var mindmap_id = li_item.attr("id").sub("mindmap_","");
      var children_title = li_item.children(".title");
      children_title.editable("/mindmaps/"+mindmap_id+"/change_title", {
        name : "title",
        indicator : '保存中...',
        method : "PUT",
        type : "text",
        cancel : "取消",
        submit : "保存",
        onblur : 'ignore',
        tooltip : '点击修改标题'
      })
    });
  })
})();


