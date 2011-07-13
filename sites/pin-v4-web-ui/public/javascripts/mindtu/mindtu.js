pie.load(function(){
  //导图列表，切换公开私有
  jQuery(document).delegate('.page-user-mindmaps .ops .toggle-private','click',function(){
    var elm = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var mindmap_id = mindmap_elm.attr('data-id');
    
    //put /mindmaps/:id/toggle_private
    jQuery.ajax({
      url : '/mindmaps/'+mindmap_id+'/toggle_private',
      type : 'PUT',
      success : function(res){
        elm.removeClass('public').removeClass('private').addClass(res);
      }
    })
  });

  jQuery(document).delegate('.page-user-mindmaps .ops .delete','click',function(){
    var elm = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var mindmap_id = mindmap_elm.attr('data-id');

    //delete /mindmaps/:id
    jQuery(elm).confirm_dialog('确定要删除吗',function(){
      jQuery.ajax({
        url : '/mindmaps/'+mindmap_id,
        type : 'DELETE',
        success : function(res){
          mindmap_elm.fadeOut(400,function(){
            mindmap_elm.remove();
          })
        }
      })
    })
  })

})



