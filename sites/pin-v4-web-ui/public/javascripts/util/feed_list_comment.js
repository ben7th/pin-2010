//主题在列表中的评论
pie.load(function(){

  var comment_form_str =
    '<div class="page-comment-form">'+
      '<div class="ipt"><textarea class="inputer"/></div>'+
      '<div class="btns">'+
        '<a class="button editable-submit" href="javascript:;">发送</a>'+
        '<a class="button editable-cancel" href="javascript:;">取消</a>'+
      '</div>'+
    '</div>';

  var prefix = '.page-feeds .feed ';

  // 针对观点的评论
  jQuery(document).delegate(prefix + 'a.add-comment','click',function(){
    var elm = jQuery(this);
    var feed_elm = elm.closest('.feed');
    var comments_elm = feed_elm.find('.comments');
    if(feed_elm.find('.page-comment-form').length == 0){
      comments_elm.after(comment_form_str);
    }
  });

  //取消
  jQuery(prefix + '.page-comment-form .btns .editable-cancel').live('click',function(){
    var elm = jQuery(this);
    var feed_elm = elm.closest('.feed');
    var form_elm = feed_elm.find('.page-comment-form');

    form_elm.remove();
  })

  // 确定，提交
  jQuery(prefix + '.page-comment-form .btns .editable-submit').live('click',function(){
    //post /viewpoints/:id/comments params[:content]
    var elm = jQuery(this);
    var feed_elm = elm.closest('.feed');
    var feed_id = feed_elm.domdata('id');

    var form_elm = feed_elm.find('.page-comment-form');
    var content = form_elm.find('.ipt .inputer').val();

    jQuery.ajax({
      url : '/feeds/'+feed_id+'/comments',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      success : function(res){
        var new_one_comment_elm = jQuery(res);
        var comments_elm = feed_elm.find('.comments');
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
      // delete /feed_comments/:id
      jQuery.ajax({
        url : '/feed_comments/'+comment_id,
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
    var feed_elm = elm.closest('.feed');
    var comments_elm = feed_elm.find('.comments');

    if(feed_elm.find('.page-comment-form').length == 0){
      comments_elm.after(comment_form_str);
    }

    feed_elm.find('.page-comment-form .inputer').focus().val('回复@'+user_name+':');
  })

});