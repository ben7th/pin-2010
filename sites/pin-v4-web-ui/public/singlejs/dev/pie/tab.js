pie.tab = {
  init:function(){
    //生成页面上的所有页签，同时避免重复生成
    $$('.tab-panel').each(function(tab_panel){
      this._init_panel(tab_panel);
    }.bind(this));
  },

  _init_panel:function(tab_panel){
    //如果已经生成过了，排除
    if($(tab_panel).hasClassName('tab-packed')) return;
    //生成
    tab_panel.addClassName('tab-packed');
    // 初始化tab栏dom
    this._init_tab_control(tab_panel);
    //最后，把整个页签面板置于初始化状态，选中一个
    var set = tab_panel.down('.tab-panel-set');
    var items = set.childElements();
    items.each(function(x){
      $(x).hide()
    });
    items[0].show();
    var default_tab_item = tab_panel.down('.tab-control .tab-control-li')
    default_tab_item.addClassName('tab-selected');
  },

  // 初始化 tab栏dom
  _init_tab_control:function(tab_panel){
    var set = tab_panel.down('.tab-panel-set');
    var items = set.childElements();
    var ul = tab_panel.down('.tab-control')
    var clis = ul.childElements();
    this._init_tab_control_tab_el(clis,items)
  },

  // 初始化 tab栏 里面的标签的 dom
  _init_tab_control_tab_el:function(clis,items){
    clis.each(function(cli,index){
      // 绑定事件
      cli.observe('click',function(evt){
        evt.stop();
        //dom显示隐藏控制
        items.each(function(x){$(x).hide()});
        $(items[index]).show();
        //页签选中状态控制
        clis.each(function(x){x.removeClassName('tab-selected')})
        cli.addClassName('tab-selected')
        // 异步模式
        var a = cli.down("a")
        if(a){
          var tip = a.readAttribute("data-tip")
          $(items[index]).update(Builder.node("div",{"class":"loadingbox"},[Builder.node("div",{"class":"loading-img"}),Builder.node("div",{"class":"loading-tip"},tip + "载入中")]))
          var url = a.readAttribute("data-url")
          new Ajax.Request(url,{
            method: 'get',
            onSuccess: function(transport){
              $(items[index]).update(transport.responseText)
            }
          })
        }
      }.bind(this));
    }.bind(this))
  },
    //根据传入的内容，点亮对应的页签
  show_content_in_tab:function(dom){
    $(dom).ancestors().each(function(el){
      if($(el).hasClassName('tab-panel')){
        //找到所在的tab-panel
        var tab_panel = el;
        //找到对应的页签
        var tab_control_li = this._get_tab_control_li(tab_panel,dom)
        //点击之
        pie.do_click(tab_control_li)
      }
    }.bind(this))
  },
  show_tab:function(tab_panel,li_index){
    //找到对应的页签
    var tab_control_li = $(tab_panel).down('.tab-control').childElements()[li_index];
    //点击之
    pie.do_click(tab_control_li)
  },
  _get_tab_control_li:function(tab_panel,dom){
    var li_index;
    $(tab_panel).down('.tab-panel-set').childElements().each(function(panel_item,index){
      if(panel_item.contains(dom)) li_index = index;
    });
    var li = tab_panel.down('.tab-control').childElements()[li_index]
    return li;
  }
}