/* 
 * 一个javascript组件，用于显示系统公告，或者其他提示信息
 */

pie.NoticeTip = Class.create({
  initialize : function(options){
    this.position = options.position || 'rightBottom';
    this.animate = options.animate;
    this.ajax = options.ajax;
    this.get_response_content(this.ajax);
    this.tip_width = options.width || 'auto';
    this.tip_height = options.height || 'auto';
  },

  // 发起ajax请求，得到相应内容
  get_response_content : function(){
    new Ajax.Request(this.ajax,{
      method : 'get',
      onSuccess : function(response){
        this.create_tip(response.responseText);
      }.bind(this)
    })
  },

  // 创建弹出框
  create_tip : function(content){
    this.tip = Builder.node("div",{
      'class':"tip_box",
      style:"left:0px;top:0px;display:none"
    },
    [Builder.node('div',{
      "class":"tip_container"
    },[
    [ Builder.node("span",{
      "class" : "close_button"
    },['关闭']).observe("click", function(){
      Effect.Fade(this.tip);
    }.bind(this)),
      Builder.node("div",{
        "class":"tip_content"
      })
      ]
      ])
    ]);
    this.tip.down(".tip_content").innerHTML = content;
    var width = document.viewport.getWidth();
    var height = document.viewport.getHeight();
    $(document.body).insert(this.tip);
    this.set_tip_style(width,height);
    this.show_tip_with_effect();
  },

  show_tip_with_effect : function(){
    var effect = this.animate.effect;
    Effect.Methods[effect](this.tip,this.animate.params);
  },

  // 设置tip的样式
  set_tip_style : function(width,height){
    
    var tip_container_width = "",tip_container_height = "";
    if(this.tip_width!="auto"){tip_container_width = this.tip_width+"px";}
    if(this.tip_height!="auto"){tip_container_height = this.tip_height+"px"; }
    this.tip.down("div.tip_container").setStyle({
      width : tip_container_width,
      height : tip_container_height
    })
    
    var position_point = this.get_position_point(width,height);
    this.tip.setStyle({
      top : position_point.top,
      left : position_point.left
    })
  },

  // 设置tip的位置
  get_position_point : function(width,height){
    
    var width_diff = width-this.tip.getWidth();
    var height_diff = height-this.tip.getHeight();
    var position_point = {
      left:"0px",
      top:"0px"
    }
    switch(this.position){
      case "leftTop":
        position_point.top = "0px";
        position_point.left = "0px";
        break;
      case "rightTop":
        position_point.top = "0px";
        position_point.left = width_diff+"px";
        break;
      case "leftBottom":
        position_point.top = height_diff+"px";
        position_point.left = "0px";
        break;
      case "rightBottom":
        position_point.top = height_diff+"px";
        position_point.left = width_diff+"px";
        break;
    }
    return position_point;
  }

});

