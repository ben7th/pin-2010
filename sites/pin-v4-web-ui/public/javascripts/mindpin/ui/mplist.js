pie.mplist = {
  init:function(){
    this.selected = null;
    this.over = null;
    this.editing = null;

    this._enabled_el_ids = [];

    document.observe('mplist:loaded',function(){
      //所有mplist的鼠标滑过高亮效果和选择效果
      this.init_mplist_mouse_over_and_out_effects_and_click_select();
    }.bind(this));

    //处理 mplist:select 事件
    document.observe('mplist:select',function(evt){
      mplist_select_handler(evt);
    })

    this.loaded();
  },

  loaded:function(){
    document.fire('mplist:loaded');
  },

  //替换paper内容之前，清除已绑定事件的列表记录
  clear_paper_events_cache:function(){
    $$('#mppaper .mplist').each(function(list){
      this._enabled_el_ids = this._enabled_el_ids.without(list.id)
    }.bind(this))
  },

  init_mplist_mouse_over_and_out_effects_and_click_select:function(){
    //只有有selectable样式的列表才能被选择
    $$('.mplist.mouseoverable').each(function(list){
      //已经绑定了事件的，不重复绑定
      //1月10日 由于id冲突，这里检测重复绑定时直接通过对象检测，但这样可能会导致内存泄漏
      //以后应该修改
      if(!this._enabled_el_ids.include(list)){
        this._init_mouseover(list);
        this._init_mouseout(list);
        this._init_click_select(list);
        this._enabled_el_ids.push(list);
      }
    }.bind(this));
  },
  _init_mouseover:function(list){
    $(list).observe('mouseover',function(evt){
      var to_el = $(evt.toElement);
      //只有从外部移入li时，才触发事件
      if(to_el){
        var li = this._is_in_li(to_el,list)
        if(li){
          //记录当前被鼠标滑过的li，同时防止有两个li同时有mouseover的class
          if(this.over) this.over.removeClassName('mouseover');
          this.over = li
          li.addClassName('mouseover');
        }
      }
    }.bind(this))
  },
  _init_mouseout:function(list){
    $(list).observe('mouseout',function(evt){
      var from_el = $(evt.fromElement);
      var to_el = $(evt.toElement);
      //只有移出li外部时，才触发事件
      // ancestors 表示祖先节点
      if(!to_el || $(from_el).ancestors().include(to_el)){
        var li = this._is_in_li(from_el,list)
        if(li) li.removeClassName('mouseover');
      }
    }.bind(this))
  },
  _init_click_select:function(list){
    $(list).observe('click',function(evt){
      var el = evt.element();
      var li = this._is_in_li(el,list);
      if(li) this._do_select_mplist_li(li);
    }.bind(this))
  },

  _is_in_li:function(el,list){
    //如果el自身是li，则看el的父节点是否是当前list，如果是，返回el
    if(el.tagName == 'LI' && el.parentNode == list) return el;
    //如果el在li之中，则看el之上最近的ul是否是当前list，如果是，返回el之上最近的li
    var li = $(el).up('li');
    if(li && $(el).up('ul') == list) return li
    //以上都不是的话，返回false
    return false;
  },

  //根据传入的el获取所在的mplist li
  _get_mpli:function(el){
    if(el.tagName == 'LI' && el.parentNode.tagName=='UL') return el;
    var li = $(el).up('li');
    if(li && $(el).up('ul')) return li
    return false;
  },

  _do_select_mplist_li:function(li){
    if(!$(li).hasClassName('mouseselected')){
      this._do_mp_select_mplist_li_change_class_name(li);
      //触发事件
      li.fire('mplist:select');
    }
  },
  _do_mp_select_mplist_li_change_class_name:function(li){
    //取消原来的选择
    if(this.selected) $(this.selected).removeClassName('mouseselected');
    //选择新的
    this.selected = li;
    $(li).addClassName('mouseselected');
  },


  //插入一个行新建的表单
  open_new_form:function(new_form_html_str,list,prev_li_or_id){
    var editing_dom = $(Builder.node('li',{'id':'li_new','class':'editing_form'}));

    editing_dom.update(new_form_html_str);

    if(prev_li_or_id){
      var prev = $(prev_li_or_id)
      prev.insert({'after':editing_dom});
    }else{
      $(list).insert(editing_dom);
    }

    //init_rich_text_editor();
    //pie.inline_menu.init();
  },

  //切换到行编辑模式
  open_edit_form:function(li_or_id,editing_html_str){
    //选中行元素，附加样式
    var li = $(li_or_id);
    li.addClassName('editing');
    //生成编辑模式的li元素
    var editing_dom = $(Builder.node('li',{'id':'li_edit_'+li.id,'class':'editing_form'}));
    editing_dom.update(editing_html_str);
    //插入dom
    li.insert({'after':editing_dom});
    
    this.editing_li = li;

    //init_rich_text_editor();
    //pie.inline_menu.init();
  },

  //关闭行编辑模式
  close_edit_form:function(){
    $$('#li_new').each(function(li_new){
      $(li_new).remove();
    }) // TODO 暂时这么写 稍后重构掉

    if(this.editing_li){
      $('li_edit_'+this.editing_li.id).remove();
      $(this.editing_li).removeClassName('editing');
      this.editing_li = null
    }
  },
  
  close_all_new_form: function(list){
    if(list){
      $(list).select('#li_new').each(function(li_new){
        $(li_new).remove();
      })
    }else{
      $$('#li_new').each(function(li_new){
        $(li_new).remove();
      }) //暂时先这样写，稍后重构到ui render方法里，去掉这个ifelse
    }
  },

  //插入li_html_str到list中
  //被rjs调用的方法，参数比较诡异
  insert_li: function(list,li_html_str,prev_li_pattern){
    var li = Builder.node('div').update(li_html_str).firstChild; //转换字符串为dom
    
    if(prev_li_pattern){
      if(prev_li_pattern == 'TOP'){
        $(list).insert({'top':li});
      }else{
        $$(prev_li_pattern).each(function(prev_li){
          prev_li.insert({'after':li});
        });
      }
    }else{
      $(list).insert(li);
    }
    
    $(li).highlight({duration:0.3,afterFinish:function(){pie.mplist.clear_background(li)}});
    
    try{
      //init_rich_text_editor();
      //pie.inline_menu.init();
  
      //pie.tab.show_content_in_tab(list);
      //init_mini_buttons();
    }catch(e){alert()}

    
  },
  
  remove_li: function(_li){
    var li = $(_li)
    $(li).fade({duration:0.3});
    $(li).highlight({startcolor: '#FFECCB',duration:0.3,afterFinish:function(){pie.mplist.clear_background(li)}});
    setTimeout(function() {
      var list = $(li).parentNode;
      $(li).remove();
    }.bind(this), 300);
  },

  update_li: function(li,new_li_html_str){
    this.close_edit_form();
    $(li).update(new_li_html_str);
    //init_rich_text_editor();
    //pie.inline_menu.init();
    $(li).highlight({duration:0.3,afterFinish:function(){pie.mplist.clear_background(li)}});
  },

  clear_background: function(dom){
    dom.setStyle({'backgroundImage':'','backgroundColor':''})
  },

  deal_app_json: function(json_str,prefix,list_id){
    try{
      var json = json_str.evalJSON();
      var html = json.html;
      var li_id = prefix + '_' + json.id;
      $$('#'+list_id).each(function(list){
        if(list.down('#'+li_id)){
          this.update_li($(li_id),html);
        }else{
          var li_html_str = '<li id="'+li_id+'">' + html + '</li>'
          this.insert_li(list,li_html_str,'TOP');
        }
      }.bind(this));
    }catch(e){
      alert(e)
    }
  }
};

(function($) {
  jQuery(document).ready(function() {
    $('.mplist li:even').addClass('even');
    pie.mplist.init();
  });
})(jQuery);


