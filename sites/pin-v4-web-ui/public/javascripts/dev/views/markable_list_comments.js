/* 
 * ，markable list 的 直接评论显示
 */
MarkableListComments = Class.create({
  initialize : function(list,settings){
    this.list = $(list)
    this.init_settings(settings)
    this.observe_link_event()
  },
  init_settings: function(settings){
    this.markable = settings.markable
  },
  // 如果评论已经展开，则关闭，反之则展开
  observe_link_event : function(){
    this.list.observe('click',function(evt){
      var ele = evt.element();
      if(!ele.hasClassName("comments_link")){return}
      var li = ele.up("li")
      if(li.down(".newest_comments")){
        this.unfold_comments_dom(li);
      }else{
        this.fold_comments_dom(li);
      }
      evt.stop();
    }.bind(this));
  },

  // 收起评论
  unfold_comments_dom : function(li){
    li.down(".newest_comments").remove();
  },

  // 展开评论
  fold_comments_dom : function(li){
    var nc = Builder.node("div",{"class":"newest_comments quote_content"});
    nc.innerHTML="<div class='loadingbox'><div class='loading-img'></div></div>";
    new Insertion.Bottom(li,nc);
    var id = li.readAttribute("id").match(/_(.+)$/)[1];
    this.insert_comments_to_li_dom(nc,id);
  },

  // 添加评论内容到div中
  insert_comments_to_li_dom : function(nc,id){
    new Ajax.Request("/" + this.markable + "/" + id + "/comments/newest",{
      method : "get",
      onSuccess : function(response){
        nc.update(response.responseText);
        // 文本域动态展开效果
        pie.TextareaAdaptHeight.init();
      }
    })
  }

});