(function(){

  pie.load(function(){
    //加载导图图片
    $$(".cache_mindmap_image").each(function(dom){
      var gmt = new GetMindmapImage(dom.id,pie.pin_url_for("pin-mindmap-image-cache"));
      gmt.get_mindmap_image();
    });

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

    //导图切换公开私有
    jQuery('.mplist .mpli .pt .toggle').live('click',function(evt){
      var dom = jQuery(evt.target);
      var map_id = dom.attr('data-map-id');
      jQuery.ajax({
        url     : '/mindmaps/'+map_id+'/do_private',
        type    : 'PUT',
        beforeSend : function(){
          dom.addClass('loading');
        },
        success : function(){
          dom.removeClass('loading').toggleClass('private').toggleClass('public');
        }
      })
    });

    //导入导图的表单
    jQuery('.import-mindmap .icon').live('click',function(){
      new Ajax.Request('/mindmaps/import',
      {
        asynchronous:true,
        evalScripts:true,
        method:'get',
        parameters:'authenticity_token=' + pie.auth_token
      })
    });

    // 加载页面后，清空导图创建表单中的内容
    jQuery("form.feed-form-mev6 input.feed-content").attr("value","");
    // 给 创建导图按钮 注册 点击事件
    jQuery("form.feed-form-mev6 .create-mindmap").bind("click",function(evt){
      evt.preventDefault();
      evt.stopPropagation();

      var btn = jQuery("form.feed-form-mev6 .create-mindmap");
      var form = jQuery("form.feed-form-mev6");
      var mode = form.attr("data-mode");
      if(mode == "create_mindmap"){
        var title = jQuery("form.feed-form-mev6 input.feed-content").attr("value");
        title = jQuery.trim(title);
        if(!title){
          alert("没有指定 title");
          return;
        }
        jQuery("form.feed-form-mev6").submit();
      }else if(mode == "import_mindmap"){
        var href = btn.attr("data-href");
        window.location = href;
      }
    });
    // 给 导入导图的流程中 最后显示的缩略图 的关闭按钮 增加事件
    jQuery("form.feed-form-mev6 .close-import-mindmap-image").bind("click",function(evt){
      evt.preventDefault();
      evt.stopPropagation();
      var import_image_div = jQuery("form.feed-form-mev6 .import-mindmap-image");
      import_image_div.hide();
      jQuery("form.feed-form-mev6 input.feed-content").attr("value","");
      jQuery("form.feed-form-mev6").attr("data-mode","create_mindmap")
    });

  })

})();