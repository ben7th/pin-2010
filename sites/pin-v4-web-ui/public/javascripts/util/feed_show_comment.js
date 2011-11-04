// 主题在show页面的评论

pie.load(function(){
  if(jQuery('.page-feed-show-comments').length == 0) return;

  var comments_elm = jQuery('.page-feed-show-comments');
  
  var form_elm = jQuery('.page-feed-show-comments .comment-form');
  var ipter_elm = form_elm.find('textarea.comment-ipter');
  ipter_elm.val('');

  jQuery('.page-feed-show-comments .comment-form a.commit').bind('click',function(){
    var elm = jQuery(this);
    var form_elm = elm.closest('.comment-form');
    
    var content = ipter_elm.val();

    //参数检查
    if(jQuery.string(content).blank()){
      form_elm.find('.submit-info')
        .stop().css('opacity',1).html('请填写评论内容')
        .show().fadeOut(5000);

      pie.inputflash(ipter_elm);
      return;
    }

    var feed_id = form_elm.domdata('id');

    jQuery.ajax({
      url : '/feeds/'+feed_id+'/comments',
      type : 'post',
      data : 'content='+encodeURIComponent(content),
      beforeSend : function(){
        
      },
      success : function(res){
        var new_comment_elm = jQuery(res).find('.comment');

        ipter_elm.val('');
        comments_elm.find('.comments .comment.blank').remove();
        comments_elm.find('.comments').prepend(new_comment_elm);

        new_comment_elm.hide().fadeIn(200);
      }
    })

  })
})


