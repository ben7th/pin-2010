RssFeedTip = Class.create({
  initialize:function(a){

    this.tip_title = a.readAttribute("data-tip-title")
    this.url = a.readAttribute("data-submit-url")
    this.method = a.readAttribute("data-submit-method")
    this.a = a

    a.observe('click',function(evt){
      var body = $(document.body)
      var tip = body.down(".rss-feed-tip")
      if(!tip){
        tip = Builder.node("div",{
          "class":"rss-feed-tip"
        })
        new Insertion.Bottom(body,tip)
      }
      this.tip = tip
      this._create_tip_innerHTML()
      this.tip.confirm_target = this.a
      tip.setStyle({
        top:evt.pointerY() + "px",
        left:evt.pointerX() + "px"
      })
      evt.stop()
    }.bind(this))
  },
  _create_tip_innerHTML:function(){
    var title = Builder.node("div",{
      "class":"tip-title"
    },this.tip_title)
    var action = Builder.node("div",{
      "class":"tip-action"
    },[
    Builder.node("span",{
      "class":"ui-button-span"
    },Builder.node("input",{
      "class":"ui-button",
      "type":"button",
      "value":"确定"
    }).observe("click",function(evt){
      new Ajax.Request(this.url,{
        asynchronous:true,
        evalScripts:true,
        method:this.method,
        onSuccess:function(request){
          var a = evt.element().up(".rss-feed-tip").confirm_target
          var count_dom = a.up(".subscription").previous(".subscriber_count")
          var count = parseInt(count_dom.innerHTML)
          count_dom.update(count + 1)
          this.tip.update("")
          a.replace("<span>已订阅</span>")
        }.bind(this),
        parameters:'authenticity_token=' + encodeURIComponent(pie.form_authenticity_token)
      });
    }.bind(this))),
      Builder.node("span",{
        "class":"ui-button-span"
      },Builder.node("input",{
        "class":"ui-button",
        "type":"button",
        "value":"取消"
      }).observe("click",function(evt){
        this.tip.update("")
      }.bind(this)))])
    this.tip.update("")
    new Insertion.Bottom(this.tip, title)
    new Insertion.Bottom(this.tip, action)
  }
});

pie.load(function(){
  $$("li.rss_feed .subscription a.rss_feed_submit").each(function(a){
    new RssFeedTip(a)
  })
});


// rss_item 的内容展开
RssItemDescriptionController = Class.create({
  initialize: function (dom,options){
    this.ul = dom;
    this.options = options;
    // 给ul注册事件，找到点击的li，并根据这个点击进行折叠展开操作
    this.ul.observe('click',function(event){
      var click_element = event.element();
      var brief_div = this.find_brief_div(click_element);
      if(brief_div!=null){
        this.operate_the_div_items(brief_div);
      }
    }.bind(this));
    // 给ul注册事件，寻找选中的rss_item_div 并且给它添加selected属性
    this.ul.observe('click',function(event){
      this.ul.select('.rss_item_div').each(function(li){
        li.removeClassName('selected')
      })
      var click_element = event.element();
      var rss_item_li = click_element.up('li');
      rss_item_li.select('.rss_item_div')[0].addClassName('selected');
    }.bind(this));

    // 给每一个item_div 中的折叠按钮注册折叠事件
    this.ul.select('.rss_item_div .description .action .fold_button').each(function(flod_button){
      flod_button.observe('click',function(){
        this.operate_the_div_items(flod_button.up('.rss_item_div').select('.brief')[0]);
      }.bind(this));
    }.bind(this));
    // 给 保持未读 注册事件
    this.ul.select('.rss_item_div .description .action .keep_unread').each(function(input){
      input.observe("click",function(){
        var rss_item_div = input.up("div.rss_item_div")
        if(input.checked){
          this.set_item_unread(rss_item_div)
        }else{
          this.set_item_read(rss_item_div)
        }
      }.bind(this))
    }.bind(this));
  },

  find_brief_div: function(click_element){
    if(click_element.classNames().include('brief')){
      return click_element;
    }else{
      var brief_div = click_element.up('.brief');
      if(brief_div!=null){
        return brief_div;
      }
    }
  },
  operate_the_div_items:function(brief_div){
    var rss_item_div = brief_div.up('.rss_item_div');
    var truncate_description = brief_div.select('.truncate_description')[0];
    var description = rss_item_div.select('.description')[0];
    if(!rss_item_div.classNames().include("no_logged")){
      if(description.classNames().include("hide") && !rss_item_div.down("input.keep_unread").checked){
        this.set_item_read(rss_item_div);
      }
    }
    description.toggleClassName('hide');
    truncate_description.toggleClassName('hide');
  },
  set_item_read:function(rss_item_div){
    if(rss_item_div.classNames().include("unread")){
      rss_item_div.removeClassName('unread');
      rss_item_div.addClassName('read');
      var item_id = rss_item_div.up('li').id.sub("rss_item_","")
      new Ajax.Request('/rss_items/'+item_id+'/readings',{
        method:'post',
        parameters:''
      });
    }
  },
  set_item_unread:function(rss_item_div){
    if(rss_item_div.classNames().include("read")){
      rss_item_div.removeClassName('read');
      rss_item_div.addClassName('unread');
      var item_id = rss_item_div.up('li').id.sub("rss_item_","")
      new Ajax.Request('/rss_items/'+item_id+'/readings/unread',{
        method:'delete',
        parameters:''
      });
    }
  }
});

// text_field域的提示功能类
TextFieldTip = Class.create({
  initialize:function(dom,text){
    this.dom = dom;
    this.text_field = dom.select('.url_text_field_of_feed')[0];
    this.submit_button = dom.select('.submit_button_need_control')[0];
    this.submit_button.disabled = true;
    this.text_value = text;
    this.text_field.value = text;
    // 给text_field注册获取焦点事件，根据输入框中是否有内容输入进行操作
    this.text_field.observe('focus',function(){
      this.change_text_field_value_by_input();
    }.bind(this));

    // 失去焦点之后，如果没有输入内容,输入框中依然存在显示
    // 没用内容的话，按钮也是无法点击的
    // 有内容的话，按钮可以点击
    this.text_field.observe('blur',function(){
      this.reset_tip_control_button();
    }.bind(this));

    // 当键盘有输入的时候，改变text_field的样式，使字体颜色变深
    this.text_field.observe('keypress',function(){
      this.chang_text_feild_style();
    }.bind(this));
  },

  // 根据输入框中是否有内容输入进行操作
  change_text_field_value_by_input:function(){
    if(this.text_field.value==this.text_value){
      this.text_field.value = "";
    }
  },

  // 如果鼠标移开，在其他地方点击的时候，这个输入框里面没有内容，则把提示重新显示出来
  reset_tip_control_button:function(){
    if(this.text_field.value.strip()==""){
      this.text_field.addClassName('quiet')
      this.text_field.value = this.text_value;
      this.submit_button.disabled = true;
    }
  },

  // 如果输入了东西
  chang_text_feild_style:function(){
    if(this.text_field.value.strip()==""){
      this.submit_button.disabled = false;
    }
    this.text_field.removeClassName('quiet')
  }

});