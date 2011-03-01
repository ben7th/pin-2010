(function(){
  pie.load(function(){
    $$(".cache_mindmap_image").each(function(dom){
      var gmt = new GetMindmapImage(dom.id,pie.pin_url_for("pin-mindmap-image-cache"));
      gmt.get_mindmap_image();
    });

    var follow_btn = jQuery(".follow_btn a.minibutton");
    var unfollow_btn = jQuery(".unfollow_btn a.minibutton");
    var user_id = follow_btn.attr("data-user-id");
    follow_btn.bind("click",function(evt){
      evt.preventDefault();
      evt.stopPropagation();

      jQuery.ajax({
        type    : 'POST',
        url     : '/contacts/follow',
        data    : 'user_id='+user_id,
        success : function(){
          jQuery('.follow_btn').hide();
          jQuery('.unfollow_btn').show();
        }
      })
    });
    
    unfollow_btn.bind("click",function(evt){
      evt.preventDefault();
      evt.stopPropagation();

      jQuery.ajax({
        type    : 'DELETE',
        url     : '/contacts/unfollow',
        data    : 'user_id='+user_id,
        success : function(){
          jQuery('.follow_btn').show();
          jQuery('.unfollow_btn').hide();
        }
      })
    });


  });
})();
