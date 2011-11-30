pie.load(function(){

  //导图列表，切换公开私有
  jQuery(document).delegate('.page-olist.mindmaps .mindmap .m-ops .do-private','click',function(){
    var elm         = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var mindmap_id  = mindmap_elm.domdata('id');
    
    //put /mindmaps/:id/toggle_private
    jQuery.ajax({
      url : '/mindmaps/'+mindmap_id+'/toggle_private',
      type : 'PUT',
      success : function(res){
        var is_private = (res == 'true');

        //图标dom
        if(is_private){
          elm.addClass('private').removeClass('public');
        }else{
          elm.removeClass('private').addClass('public');
        }
      }
    })
  });

  //导图列表，删除
  jQuery(document).delegate('.page-olist.mindmaps .mindmap .m-ops .delete','click',function(){
    var elm         = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var mindmap_id  = mindmap_elm.domdata('id');

    //delete /mindmaps/:id
    jQuery(elm).confirm_dialog('确定要删除吗',function(){
      jQuery.ajax({
        url : '/mindmaps/'+mindmap_id,
        type : 'DELETE',
        success : function(res){
          if(jQuery('.page-mindmaps-top').length > 0){
            mindmap_elm.fadeOut(400,function(){
              mindmap_elm.remove();
            })
          }else{
            window.location.href = '/'
          }
        }
      })
    })
  })

  //导图列表，收藏
  jQuery(document).delegate('.page-olist.mindmaps .mindmap .m-ops .do-fav','click',function(){
    var elm         = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var mindmap_id  = mindmap_elm.domdata('id');

    var count_elm   = mindmap_elm.find('.fav-star .count')

    //put /mindmaps/:id/toggle_fav
    jQuery.ajax({
      url : '/mindmaps/'+mindmap_id+'/toggle_fav',
      type : 'PUT',
      success : function(res){
        var is_fav = (res == 'true');
        if(is_fav){
          elm.addClass('faved').removeClass('not-faved');
          count_elm.html(parseInt(count_elm.html()) + 1);
        }else{
          elm.removeClass('faved').addClass('not-faved');
          count_elm.html(parseInt(count_elm.html()) - 1);
        }
      }
    })
  });

  //刷新缩略图
  jQuery(document).delegate('.page-olist.mindmaps .mindmap .refresh-thumb','click',function(){
    var elm         = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var mindmap_id  = mindmap_elm.domdata('id');

    var image_elm   = mindmap_elm.find('.thumb img')


    //put  /mindmaps/:id/refresh_thumb
    jQuery.ajax({
      url : '/mindmaps/'+mindmap_id+'/refresh_thumb?size_param=500x500',
      type : 'PUT',
      success : function(res){
        image_elm.attr('src', res);
      }
    })
  })

})
