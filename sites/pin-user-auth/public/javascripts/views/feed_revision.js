pie.load(function(){
  jQuery('.page-revisions .revision .ops .rollback').live('click',function(){
    var elm = jQuery(this);
    elm.confirm_dialog('确定要恢复吗',function(){
      //确定恢复的是主题的版本，还是观点的版本
      var rev_elm = elm.closest('.revision');
      var rev_id = rev_elm.attr('data-id');
      var feed_id = rev_elm.attr('data-feed-id');

      // PUT /viewpoint_revisions/:id/rollback
      if(rev_elm.hasClass('viewpoint')){
        jQuery.ajax({
          url : "/viewpoint_revisions/"+rev_id+"/rollback",
          type: 'PUT',
          success : function(){
            location.href = "/feeds/" + feed_id;
          }
        })
      }

      // put /feed_revisions/:id/rollback
      if(rev_elm.hasClass('feed')){
        jQuery.ajax({
          url : "/feed_revisions/"+rev_id+"/rollback",
          type: 'PUT',
          success : function(){
            location.href = "/feeds/" + feed_id;
          }
        })
      }

    })
  })
})