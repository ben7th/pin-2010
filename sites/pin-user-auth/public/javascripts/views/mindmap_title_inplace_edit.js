(function(){
  pie.load(function(){
    //导图标题现场编辑
    jQuery(".user-mindmaps .mindmap-m").each(function(){
      var elm = jQuery(this);
      var mindmap_id = elm.attr("data-id")
      var children_title = elm.find(".title");
      
      children_title.editable("/mindmaps/"+mindmap_id+"/change_title", {
        name : "title",
        indicator : '保存中...',
        method : "PUT",
        type : "text",
        cancel : "取消",
        submit : "保存",
        onblur : 'ignore'
      })
    });

    //导图切换公开私有
    jQuery('.user-mindmaps .mindmap-m .toggle').live('click',function(){
      var elm = jQuery(this);
      var map_id = elm.attr('data-map-id');
      jQuery.ajax({
        url     : '/mindmaps/'+map_id+'/do_private',
        type    : 'PUT',
        beforeSend : function(){
          elm.addClass('loading');
          pie.show_loading_bar();
        },
        success : function(){
          elm.removeClass('loading').toggleClass('private').toggleClass('public');
        },
        complete : function(){
          pie.hide_loading_bar();
        }
      })
    });

    //删除导图
    jQuery('.user-mindmaps .mindmap-m .delete').live('click',function(){
      var elm = jQuery(this);
      var mindmap_elm = elm.closest('.mindmap-m')
      var map_id = mindmap_elm.attr('data-id');

      elm.confirm_dialog('确定删除这个导图吗',function(){
        jQuery.ajax({
          url     : '/mindmaps/'+map_id,
          type    : 'delete',
          beforeSend : function(){
            pie.show_loading_bar();
          },
          success : function(){
            mindmap_elm.fadeOut(400);
          },
          complete : function(){
            pie.hide_loading_bar();
          }
        })
      });

    })
  })
})();


