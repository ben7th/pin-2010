// 主题在show页面的评论

pie.load(function(){
  if(jQuery('.page-feed-show-comments').length == 0) return;

  var comments_elm = jQuery('.page-feed-show-comments');
  var form_elm     = comments_elm.find('.comment-form');
  var ipter_elm    = form_elm.find('textarea.comment-ipter');
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

  form_elm.find('a.commit').click(function(){
    var content  = jQuery.string(ipter_elm.val()).strip().str;

    //参数检查
    if(jQuery.string(content).blank()){
      form_elm.find('.submit-info')
        .stop().css('opacity',1).html('请填写评论内容')
        .show().fadeOut(5000);

      pie.inputflash(ipter_elm);
      return;
    }

    // 判断是回复评论，还是新增评论
    var reply_comment_id = ipter_elm.data('reply-comment-id');
    var be_replied_elm   = comments_elm.find('.comments .comment[data-id='+reply_comment_id+']');
    
    if(be_replied_elm.length > 0){
      var user_name = be_replied_elm.data('user-name');
      var prefix    = '回复@'+user_name+':';
      var is_reply  = jQuery.string(content).startsWith(prefix);
      if(is_reply){
        // 回复评论
        jQuery.ajax({
          url  : '/post_comments/reply',
          type : 'POST',
          data : {
            'reply_comment_id' : reply_comment_id,
            'content' : content
          },
          success : function(res){
            comment_success(res);
          }
        })

        return;
      }
    }

    // 新增评论
    var feed_id = form_elm.data('feed-id');
    jQuery.ajax({
      url  : '/feeds/'+feed_id+'/comments',
      type : 'POST',
      data : {
        'content' : content
      },
      success : function(res){
        comment_success(res);
      }
    })

  })

  var comment_success = function(res){
    var new_comment_elm = jQuery(res).find('.comment');

    ipter_elm.val('');
    comments_elm.find('.comments .comment.blank').remove();
    comments_elm.find('.comments').prepend(new_comment_elm);

    new_comment_elm.hide().fadeIn(200);

    var next_elm = new_comment_elm.next('.comment');
    if( new_comment_elm.data('user-name') == next_elm.data('user-name') ){
      next_elm.addClass('same-user');
    }
  }

  // 删除评论
  jQuery('.page-feed-show-comments .comment .ops a.delete').live('click', function(){
    var elm = jQuery(this);
    elm.confirm_dialog('确定删除吗', function(){
      var comment_elm = elm.closest('.comment')
      var comment_id  = comment_elm.data('id');
      
      // DELETE
      jQuery.ajax({
        url : '/post_comments/'+comment_id,
        type : 'DELETE',
        success : function(){
          comment_elm.fadeOut(200, function(){
            comment_elm.next('.comment').removeClass('same-user');
            comment_elm.remove();
          })
        }
      })
    })
  })

  //回复评论
  jQuery('.page-feed-show-comments .comment .ops a.reply').live('click', function(){
    var elm = jQuery(this);
    var comment_elm = elm.closest('.comment')
    var user_name = comment_elm.data('user-name');
    var reply_comment_id = comment_elm.data('id');

    var prefix = '回复@'+user_name+':';
    ipter_elm.focus().val(prefix).data('reply-comment-id', reply_comment_id);
  })
})


