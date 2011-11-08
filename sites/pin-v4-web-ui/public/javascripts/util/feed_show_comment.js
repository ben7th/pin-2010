// 主题在show页面的评论

pie.load(function(){
  if(jQuery('.page-feed-show-comments').length == 0) return;

  var comments_elm = jQuery('.page-feed-show-comments');
  
  var form_elm = jQuery('.page-feed-show-comments .comment-form');
  var ipter_elm = form_elm.find('textarea.comment-ipter');
  ipter_elm.val('');

  // 发评论

  /* 此处分为 新增评论 和 回复评论 两个分支逻辑
   * 网页上的回复是比较繁琐的过程，当符合以下条件时，判断为是正在回复一条评论
   * 1 回复框上能够取得 data-reply-comment-id
   * 2 根据该 data-reply-comment-id 能够在当前页面显示的评论列表内找到对应评论的 dom
   * 3 当前评论框内的内容，以 '回复@用户名' 开头
   *
   * 不符合条件的，都认为是普通的新增评论
   */

  jQuery('.page-feed-show-comments .comment-form a.commit').bind('click',function(){
    var elm = jQuery(this);
    var form_elm = elm.closest('.comment-form');
    var content = ipter_elm.val().strip();

    //参数检查
    if(jQuery.string(content).blank()){
      form_elm.find('.submit-info')
        .stop().css('opacity',1).html('请填写评论内容')
        .show().fadeOut(5000);

      pie.inputflash(ipter_elm);
      return;
    }

    // 判断是回复评论，还是新增评论
    var reply_comment_id = ipter_elm.domdata('reply-comment-id');
    var be_replied_elm = comments_elm.find('.comments .comment[data-id='+reply_comment_id+']');
    if(be_replied_elm.length > 0){
      var user_name = be_replied_elm.domdata('user-name');
      var prefix = '回复@'+user_name+':';
      var is_reply = jQuery.string(content).startsWith(prefix);
      if(is_reply){
        pie.log('reply');

        // 回复评论
        jQuery.ajax({
          url : '/post_comments/reply',
          type : 'post',
          data : 'reply_comment_id='+reply_comment_id+'&content='+encodeURIComponent(content),
          beforeSend : function(){

          },
          success : function(res){
            comment_success(res);
          }
        })

        return;
      }
    }



    // 新增评论
    var feed_id = form_elm.domdata('feed-id');
    jQuery.ajax({
      url : '/feeds/'+feed_id+'/comments',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      beforeSend : function(){

      },
      success : function(res){
        comment_success(res);
      }
    })

  })

  function comment_success(res){
      var new_comment_elm = jQuery(res).find('.comment');

      ipter_elm.val('');
      comments_elm.find('.comments .comment.blank').remove();
      comments_elm.find('.comments').prepend(new_comment_elm);

      new_comment_elm.hide().fadeIn(200);

      var next_elm = new_comment_elm.next('.comment');
      if( new_comment_elm.domdata('user-name') == next_elm.domdata('user-name') ){
        next_elm.addClass('same-user');
      }
  }

  // 删除评论
  jQuery('.page-feed-show-comments .comment .ops a.delete').live('click',function(){
    var elm = jQuery(this);
    elm.confirm_dialog('确定删除吗',function(){
      var comment_elm = elm.closest('.comment')

      var comment_id = comment_elm.domdata('id');
      
      // DELETE
      jQuery.ajax({
        url : '/post_comments/'+comment_id,
        type : 'delete',
        success : function(){
          comment_elm.fadeOut(200,function(){
            comment_elm.next('.comment').removeClass('same-user');
            comment_elm.remove();
          })
        }
      })
    })
  })

  //回复评论
  jQuery('.page-feed-show-comments .comment .ops a.reply').live('click',function(){
    var elm = jQuery(this);
    var comment_elm = elm.closest('.comment')
    var user_name = comment_elm.domdata('user-name');
    var reply_comment_id = comment_elm.domdata('id');

    var prefix = '回复@'+user_name+':';
    ipter_elm.focus().val(prefix).domdata('reply-comment-id',reply_comment_id);
  })
})


