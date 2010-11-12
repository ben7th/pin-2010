RemarkManager = {
  reply_to:function(user_id,user_name){
    RemarkManager.cancel_reply()
    $$("form.comment_form").each(function(form){
      var div = Builder.node("div",{},[
        Builder.node("span",{
          "class":"user_name"
        },"回复 @" + user_name),
        Builder.node("a",{},"取消").observe("click",function(){
          RemarkManager.cancel_reply()
        })
        ]);
      var reply_user_div = form.down("div.reply_user")
      new Insertion.Top(reply_user_div,div)
      form.down("input[name*='[reply_to]']").value = user_id
    });
  },
  cancel_reply:function(){
    $$("form.comment_form").each(function(form){
      form.down("input[name*='[reply_to]']").value = ""
      var div = form.down("div.reply_user")
      div.update("")
    });
  },
  form_reset:function(){
    $$("form.comment_form").each(function(form){
      form.reset();
      form.down("textarea").fire("dom:value_change")
    });
  },

  form_submit_failure : function(form){
    text = form.down("textarea");
    if(text.value.blank()){
      this.show_effect(text);
      return false;
    }
    return true;
  },
  
  show_effect : function(text){
    out_div = text.up("div");
    out_div.setStyle({
      position:"relative"
    });
    var width = (text.getWidth()-3)+"px";
    var height = (text.getHeight()-3)+"px";
    var label = out_div.down("label")
    var top = label ? label.getHeight()+2 : 2;
    out_div.insert("<div id='null_content_tip' style='position:absolute;background-color:#FFE2AF;width:"+width+";height:"+height+";top:"+top+"px;left:2px;'></div>");
    Effect.Pulsate($('null_content_tip'),{
      afterFinish : function(o){
        $('null_content_tip').remove();
      }
    });
  }

};


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
