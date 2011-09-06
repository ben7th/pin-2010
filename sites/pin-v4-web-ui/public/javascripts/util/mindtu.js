pie.load(function(){
  //导图列表，切换公开私有
  jQuery(document).delegate('.page-olist.mindmaps .mindmap .ops .toggle-private','click',function(){
    var elm = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var mindmap_id = mindmap_elm.attr('data-id');
    
    //put /mindmaps/:id/toggle_private
    jQuery.ajax({
      url : '/mindmaps/'+mindmap_id+'/toggle_private',
      type : 'PUT',
      success : function(res){
        var res_elm = jQuery(res)

        //图标dom
        var new_elm = res_elm.find('.ops .o .toggle-private');
        elm.after(new_elm).remove();

        //状态栏dom
        var new_status_elm = res_elm.find('.status .is-private');
        var old_status_elm = mindmap_elm.find('.status .is-private');


        old_status_elm.after(new_status_elm).remove();
        if(new_status_elm.css('display')!='none'){
          new_status_elm.hide().fadeIn(200);
        }

      }
    })
  });

  //导图列表，删除
  jQuery(document).delegate('.page-olist.mindmaps .mindmap .ops .delete','click',function(){
    var elm = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var mindmap_id = mindmap_elm.attr('data-id');

    //delete /mindmaps/:id
    jQuery(elm).confirm_dialog('确定要删除吗',function(){
      jQuery.ajax({
        url : '/mindmaps/'+mindmap_id,
        type : 'DELETE',
        success : function(res){
          if(jQuery('.page-mindmaps-info-bar').length > 0){
            window.location.href = '/'
          }else{
            mindmap_elm.fadeOut(400,function(){
              mindmap_elm.remove();
            })
          }
        }
      })
    })
  })

  //导图列表，收藏
  jQuery(document).delegate('.page-olist.mindmaps .mindmap .ops .toggle-fav','click',function(){
    var elm = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var mindmap_id = mindmap_elm.attr('data-id');

    //put /mindmaps/:id/toggle_fav
    jQuery.ajax({
      url : '/mindmaps/'+mindmap_id+'/toggle_fav',
      type : 'PUT',
      success : function(res){
        var res_elm = jQuery(res);

        //星标dom
        var new_elm = res_elm.find('.ops .o .toggle-fav');
        elm.after(new_elm).remove();

        //状态栏dom
        var new_status_elm = res_elm.find('.status .faved-by');
        var old_status_elm = mindmap_elm.find('.status .faved-by');

        
        old_status_elm.after(new_status_elm).remove();
        if(new_status_elm.css('display')!='none'){
          new_status_elm.hide().fadeIn(200);
        }
      }
    })
  });
})
