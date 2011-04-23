pie.load(function(){
  jQuery('.page-show-add-viewpoint .subm .editable-submit').live('click',function(){
    var elm = jQuery(this);
    var psav_elm = elm.closest('.page-show-add-viewpoint');
    var feed_id = psav_elm.attr('data-feed-id');
    var content = psav_elm.find('.add-viewpoint-inputer .inputer').val();

    //   post /feeds/:id/viewpoint params[:content]
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/viewpoint',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var vp_elm = jQuery(res);
        jQuery('.feed-viewpoints').append(vp_elm);
        vp_elm.hide().fadeIn('fast');
        jQuery('.page-show-add-viewpoint').addClass('vp-added');
      }
    })
  });

  var comments_elm = jQuery(
    '<div class="comments darkbg">'+
      '<div class="comment-form">'+
        '<div class="ipt"><textarea class="inputer"/></div>'+
        '<div class="btns">'+
          '<a class="button editable-submit" href="javascript:;">发送</button>'+
          '<a class="button editable-cancel" href="javascript:;">取消</button>'+
        '</div>'+
      '</div>'+
      '<div class="list"></div>'+
    '</div>'
  )

  jQuery('.feed-viewpoints .viewpoint .ops .echo').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var viewpoint_id = vp_elm.attr('data-id');
    var meta_elm = vp_elm.find('.meta');
    if(meta_elm.next('.comments').length == 0){
      meta_elm.after(comments_elm);
      // get /viewpoints/:id/aj-comments
      var list_elm = comments_elm.find('.list');
      list_elm.html('').addClass('aj-loading');
      jQuery.ajax({
        url : '/viewpoints/'+viewpoint_id+'/aj_comments',
        type : 'get',
        success : function(res){
          var comments_list_elm = jQuery(res);
          list_elm.html(comments_list_elm.html()).removeClass('aj-loading');;
        }
      })
    }else{
      comments_elm.remove();
    }
  })

  jQuery('.feed-viewpoints .viewpoint .comments .btns .editable-submit').live('click',function(){
    //post /viewpoints/:id/comments params[:content]
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var viewpoint_id = vp_elm.attr('data-id');
    var content = elm.closest('.comments').find('.ipt .inputer').val();
    
    jQuery.ajax({
      url : '/viewpoints/'+viewpoint_id+'/comments',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var li_elm = jQuery(res).find('li');
        var list_elm = comments_elm.find('.list');
        list_elm.prepend(li_elm);
      }
    })
  })

  jQuery('.feed-viewpoints .comments .btns .editable-cancel').live('click',function(){
    comments_elm.remove();
  })


  //修改观点
  jQuery('.feed-viewpoints .viewpoint .ops .edit').live('click',function(){
    var elm = jQuery(this);
    var vp_elm = elm.closest('.viewpoint');
    var viewpoint_id = vp_elm.attr('data-id');
    var meta_elm = vp_elm.find('.meta');
  });

  //删除观点的评论
  jQuery('.feed-viewpoints .comments .comment .delete').live('click',function(){
    var elm = jQuery(this);
    var comment_elm = elm.closest('.comment')
    var comment_id = comment_elm.attr('data-id');
    if(confirm('确定要删除这条评论吗？')){
      // delete /viewpoint_comments/:id
      jQuery.ajax({
        url : '/viewpoint_comments/'+comment_id,
        type : 'delete',
        success : function(){
          comment_elm.fadeOut();
        }
      })
    }
  })
})