pie.load(function(){
  jQuery('.page-revisions .revision .ops .rollback').live('click',function(){
    var elm = jQuery(this);
    elm.confirm_dialog('确定要恢复吗',function(){
      //确定恢复的是主题的版本，还是观点的版本
      var rev_elm = elm.closest('.revision');
      var rev_id = rev_elm.attr('data-id');
      var tag_name = rev_elm.attr('data-name');
      pie.log(1)
      // PUT /tag_detail_revisions/:tag_name/rollback
      if(rev_elm.hasClass('tag')){
        jQuery.ajax({
          url : "/tag_detail_revisions/"+rev_id+"/rollback",
          type: 'PUT',
          success : function(){
            location.href = "/tags/" + tag_name;
          }
        })
      }

    })
  })
})