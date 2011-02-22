(function($){
  $(function(){
    
    // 给创建按钮注册 点击事件，当点击时，创建导图
    $("a.new_mindmap").bind("click",function(evt){
      evt.preventDefault();
      evt.stopPropagation();

      var title = $("form.create_mindmap input#mindmap_title").attr("value");
      title = $.trim(title);
      if(!title){
        alert("没有指定 title");
        return;
      }

      $("form.create_mindmap").submit();
      return;
    });

  });
})(jQuery);


