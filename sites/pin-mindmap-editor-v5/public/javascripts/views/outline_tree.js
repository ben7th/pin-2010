/* 
 * Outline列表中展开，收起，编辑标题，拖拽等操作
 */
OutlineTree = Class.create({
  initialize : function(list_id,url_prex){
    this.url_prex = url_prex;
    this.list = $(list_id);
    this.mindmap_id = list_id.sub("list_","");
    this.selected_title = null;
    this.text_area = null;
    this.text_area_editing = false;
    // 给所有的加减号，div注册点开，收起的切换事件,以及鼠标移上去，离开操作
    this.plus_and_minus_toggle();
    // 选择操作
    this.select_operate();
    // 初始化text_area
    this.init_textarea();
  },

  // 初始化 文本框
  init_textarea : function(){
    this.text_area = Builder.node("textarea",{
      "class":"edit_text hide"
    });
    // 按下enter键时，保存结果
    this.text_area.observe("keydown",function(evt){
      var code=evt.keyCode;
      switch(code){
        case Event.KEY_RETURN:{
          if(evt.shiftKey){
          }else{
            //(map.__changeTitle.bind(map.focus))();
            this.submit_text_area_value_to_node();
            Event.stop(evt);
            return false;
          }
        }
      }
    }.bind(this));
  },

  // 提交文本框进行的编辑数据
  submit_text_area_value_to_node : function(){
    if(this.text_area.hasClassName('hide')){
      return
    }// 如果这个textarea已经是隐藏状态 直接返回，不作处理
    var outline_title = this.selected_title.down(".outline_title")
    outline_title.innerHTML = this.text_area.value.escapeHTML().replace(/\n/g,"<br/>")
    outline_title.removeClassName("hide");
    this.text_area.addClassName('hide');
    // 同步后台数据
    var node_id = this.selected_title.up("li").id.sub("node_","");
    new Ajax.Request("/"+this.url_prex+"/api/do_title/"+this.mindmap_id,{
      method : "put",
      parameters : {
        "node" : node_id,
        "title" : this.text_area.value
      }
    });
    // 将正在编辑状态设为false
    this.text_area_editing = false;
  },

  // 选择另一条title的时候，处理上一个选择的title
  handle_last_selected_title : function(){
    this.selected_title.removeClassName("selected");
    // 将这个编辑框中的内容与数据库同步
    this.submit_text_area_value_to_node();
  },

  // 选择操作
  select_operate : function(){
    // 第一次点击，是选择操作，高亮显示
    // 如果是在选择状态下，再去点击，就是编辑框显示
    this.list.select(".outline_title_and_sign").each(function(title_and_sign){
      title_and_sign.observe('click',function(evt){
        var height = title_and_sign.getHeight();
        var width = title_and_sign.down(".outline_title").getWidth() + 14;
        // 如果选择的是折叠操作按钮，直接返回
        if(evt.element().hasClassName("foldhandler")){
          if(this.text_area_editing){
            this.submit_text_area_value_to_node();
          }
          return
        }
        // 如果当前选中的标题，不是刚才选中的那个标题，处理刚才那个标题
        if(this.selected_title && this.selected_title != title_and_sign){
          this.handle_last_selected_title();
        }
        this.selected_title = title_and_sign;
        if(title_and_sign.hasClassName("selected")){
          // 如果不是处于编辑状态则显示编辑框，如果已经是处于编辑状态，则不用再次显示编辑框
          if(!this.text_area_editing){
            var outline_title = title_and_sign.down(".outline_title")
            outline_title.addClassName("hide");
            this.text_area.value = outline_title.innerHTML.replace(/<br\/?>/g,"\n").unescapeHTML();

            this.text_area.setStyle({"height":height+"px","width":width+"px"})
            new Insertion.After(outline_title,this.text_area);
            this.text_area.removeClassName('hide');
            this.text_area.select();
            this.text_area.focus();
            this.text_area_editing = true;
          }else if(!evt.element().hasClassName("edit_text")){
            // 使text_area 获取焦点 同时选择编辑框中的为文本，设置文本框正在编辑状态为true
            this.submit_text_area_value_to_node();
          }
        }else{
          title_and_sign.addClassName("selected");
        }
      }.bind(this));
    }.bind(this));
  },

  // 折叠操作
  plus_and_minus_toggle : function(){
    this.list.select(".foldhandler").each(function(sign_div){
      // 点击事件，展开、收起 操作
      sign_div.observe('click',function(){
        sign_div.toggleClassName("outline_plus");
        sign_div.toggleClassName("outline_minus");
        var next_ul = sign_div.up("li").down("ul")
        if(next_ul){
          next_ul.toggleClassName("hide");
        }
        // ajax操作数据库中节点的的flod属性
        new Ajax.Request("/"+this.url_prex+"/api/do_toggle/"+this.mindmap_id,{
          method : "put",
          parameters: {
            "node":sign_div.up("li").id.sub("node_","")
          }
        });
      }.bind(this));
      // 鼠标移上去
      sign_div.observe('mouseover',function(){
        sign_div.addClassName("outline_over");
      });
      // 鼠标离开
      sign_div.observe('mouseout',function(){
        sign_div.removeClassName("outline_over");
        sign_div.removeClassName("outline_down");
      });
      // 鼠标点下去
      sign_div.observe('mousedown',function(){
        sign_div.addClassName("outline_down");
      });
      // 鼠标点击后
      sign_div.observe('mouseup',function(){
        sign_div.removeClassName("outline_down");
      });
    }.bind(this));
  }

});

