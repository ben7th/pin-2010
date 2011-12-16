/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
ChangeThemeWithFloatDiv = Class.create({
  initialize : function(link_dom){
    this.link_dom = link_dom;
    this.link_dom.observe('click',function(event){
      this.show_select_theme_div(event);
    }.bind(this))
  },

  // 如果没有div则创建一个div,并确定这个div的位置
  show_select_theme_div : function(event){
    var body = $(document.body);
    var tip = body.down(".change-theme-tip")
    if(!tip){
      tip = Builder.node("div",{
        "class":"change-theme-tip"
      })
      new Insertion.Bottom(body,tip)
    }
    this.tip = tip;
    this.insert_content_to_tip();
    this.tip.setStyle({
      top : event.pointerY() + "px",
      left : event.pointerX()-300 + "px",
      position : 'absolute',
      background : '#FFF'
    });
    event.stop();
  },

  insert_content_to_tip : function(){
    new Ajax.Request('/preference/ajax_theme_change',{
      method:'get',
      onSuccess:function(response){
        this.tip.update(response.responseText)
        var action = Builder.node("div",{
          "class":"tip-action"
          },[Builder.node("span",{
            "class":"ui-button-span"
          },Builder.node("input",{
            "class":"ui-button","type":"button","value":"取消"
          }).observe("click",function(evt){
            this.tip.update("");
          }.bind(this)))]);
        new Insertion.Bottom(this.tip, action);
        return true;
      }.bind(this)
    })
  }

});

