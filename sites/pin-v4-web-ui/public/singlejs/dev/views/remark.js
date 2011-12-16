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
    out_div.insert("<div id='null_content_tip' style='position:absolute;background-color:#FFE2AF;width:"+width+";height:"+height+";top:"+(out_div.down("label").getHeight()+2)+"px;left:2px;'></div>");
    Effect.Pulsate($('null_content_tip'),{
      afterFinish : function(o){
        $('null_content_tip').remove();
      }
    });
  }

};