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

  //导图列表，收藏
  jQuery(document).delegate('.page-user-mindmaps .ops .toggle-fav','click',function(){
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

//针对导图的评论
pie.load(function(){

  var comment_form_str =
    '<div class="comment-form">'+
      '<div class="ipt"><textarea class="inputer"/></div>'+
      '<div class="btns">'+
        '<a class="button editable-submit" href="javascript:;">发送</a>'+
        '<a class="button editable-cancel" href="javascript:;">取消</a>'+
      '</div>'+
    '</div>';

  var prefix = '.page-user-mindmaps .mindmap ';

  // 针对观点的评论
  jQuery(document).delegate(prefix + 'a.add-comment','click',function(){
    var elm = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var comments_elm = mindmap_elm.find('.comments');
    if(mindmap_elm.find('.comment-form').length == 0){
      comments_elm.after(comment_form_str);
    }
  });

  //取消
  jQuery(prefix + '.comment-form .btns .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var form_elm = mindmap_elm.find('.comment-form');

    form_elm.remove();
  })

  // 确定，提交
  jQuery(prefix + '.comment-form .btns .editable-submit').live('click',function(){
    //post /viewpoints/:id/comments params[:content]
    var elm = jQuery(this);
    var mindmap_elm = elm.closest('.mindmap');
    var mindmap_id = mindmap_elm.attr('data-id');

    var form_elm = mindmap_elm.find('.comment-form');
    var content = form_elm.find('.ipt .inputer').val();

    jQuery.ajax({
      url : '/mindmaps/'+mindmap_id+'/comments',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var new_one_comment_elm = jQuery(res);
        var comments_elm = mindmap_elm.find('.comments');
        comments_elm.show().append(new_one_comment_elm);
        new_one_comment_elm.hide().fadeIn(200);
        form_elm.remove();
      }
    })
  });

  //删除观点的评论
  jQuery(prefix + '.comments .comment .delete').live('click',function(){
    var elm = jQuery(this);
    var comments_elm = elm.closest('.comments');
    var comment_elm = elm.closest('.comment');
    var comment_id = comment_elm.attr('data-id');

    elm.confirm_dialog('确定要删除这条评论吗',function(){
      // delete /viewpoint_comments/:id
      jQuery.ajax({
        url : '/comments/'+comment_id,
        type : 'delete',
        success : function(){
          comment_elm.fadeOut(200,function(){
            comment_elm.remove();
            if(comments_elm.find('.comment').length == 0){
              comments_elm.remove();
            }
          });
        }
      })
    });
  });

  //回复其他人的评论
  jQuery(prefix + '.comments .comment .reply').live('click',function(){
    var elm = jQuery(this);
    var user_name = elm.closest('.comment').attr('data-creator-name');
    var mindmap_elm = elm.closest('.mindmap');
    var comments_elm = mindmap_elm.find('.comments');

    if(mindmap_elm.find('.comment-form').length == 0){
      comments_elm.after(comment_form_str);
    }

    mindmap_elm.find('.comment-form .inputer').val('回复@'+user_name+':').focus();
  })

});
