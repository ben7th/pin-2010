var MindpinAutocompleter = { };
MindpinAutocompleter.Base = Class.create({
  baseInitialize: function(element, update, options) {
    element          = $(element);
    this.element     = element;
    this.update      = $(update);
    this.hasFocus    = false;
    this.changed     = false;
    this.active      = false;
    this.index       = 0;
    this.entryCount  = 0;
    this.old_element_value = this.element.value;

    this.animation_time = 0.05;

    if(this.setOptions)
      this.setOptions(options);
    else
      this.options = options || { };

    this.options.paramName    = this.options.paramName || this.element.name;
    this.options.tokens       = this.options.tokens || [];
    this.options.frequency    = this.options.frequency || 0.4; //每0.4秒之内最多发送一个请求
    this.options.minChars     = this.options.minChars || 1;
    this.options.onShow       = this.options.onShow ||
    function(element, update){
      if(!update.style.position || update.style.position=='absolute') {
        update.style.position = 'absolute';
        Position.clone(element, update, {
          setHeight: false,
          offsetTop: element.offsetHeight
        });
      }
      Effect.Appear(update,{
        duration:this.animation_time
      });
    }.bind(this);
    this.options.onHide = this.options.onHide ||
    function(element, update){
      new Effect.Fade(update,{
        duration:this.animation_time
      })
    }.bind(this);

    if(typeof(this.options.tokens) == 'string')
      this.options.tokens = new Array(this.options.tokens);
    // Force carriage returns as token delimiters anyway
    if (!this.options.tokens.include('\n'))
      this.options.tokens.push('\n');

    this.observer = null;

    this.element.setAttribute('autocomplete','off');

    Element.hide(this.update);

    Event.observe(this.element, 'blur', this.onBlur.bindAsEventListener(this));
    Event.observe(this.element, 'keydown', this.onKeyDownPress.bindAsEventListener(this));
    Event.observe(this.element, 'keyup', function(){
      if(!this.periodical_executer){
        this.periodical_executer = new PeriodicalExecuter(this._period_request.bind(this), 0.01);
        setTimeout(function(){
          this.periodical_executer.stop();
          this.periodical_executer = null;
        }.bind(this),this.options.frequency*1000);
      }
    }.bindAsEventListener(this))
    if(!pie.cached_username_advice_hash) pie.cached_username_advice_hash = new Hash();
  },

  _period_request:function(){
    var input_str = this.element.value;

    if(this.old_element_value != input_str){
      this.changed = true;
      this.hasFocus = true;

      this.onObserverEvent();
    }
  },

  show: function() {
    if(Element.getStyle(this.update, 'display')=='none') this.options.onShow(this.element, this.update);
    if(!this.iefix &&
      (Prototype.Browser.IE) &&
      (Element.getStyle(this.update, 'position')=='absolute')) {
      new Insertion.After(this.update,
        '<iframe id="' + this.update.id + '_iefix" '+
        'style="display:none;position:absolute;filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);" ' +
        'src="javascript:false;" frameborder="0" scrolling="no"></iframe>');
      this.iefix = $(this.update.id+'_iefix');
    }
    if(this.iefix) setTimeout(this.fixIEOverlapping.bind(this), 50);
  },

  fixIEOverlapping: function() {
    Position.clone(this.update, this.iefix, {
      setTop:(!this.update.style.height)
    });
    this.iefix.style.zIndex = 1;
    this.update.style.zIndex = 2;
    Element.show(this.iefix);
  },

  hide: function() {
    this.stopIndicator();
    if(Element.getStyle(this.update, 'display')!='none') this.options.onHide(this.element, this.update);
    if(this.iefix) Element.hide(this.iefix);
  },

  startIndicator: function() {
    if(this.options.indicator) Element.show(this.options.indicator);
  },

  stopIndicator: function() {
    if(this.options.indicator) Element.hide(this.options.indicator);
  },

  onKeyDownPress: function(event){
    if(this.active)
      switch(event.keyCode) {
        case Event.KEY_TAB:
        case Event.KEY_RETURN:
          this.selectEntry();
          Event.stop(event);
        case Event.KEY_ESC:
          this.hide();
          this.active = false;
          Event.stop(event);
          return;
        case Event.KEY_LEFT:
        case Event.KEY_RIGHT:
          return;
        case Event.KEY_UP:
          this.markPrevious();
          this.render();
          Event.stop(event);
          return;
        case Event.KEY_DOWN:
          this.markNext();
          this.render();
          Event.stop(event);
          return;
      }
    else
    if(event.keyCode==Event.KEY_TAB || event.keyCode==Event.KEY_RETURN ||
      (Prototype.Browser.WebKit > 0 && event.keyCode == 0)) return;
  },

  activate: function() {
    this.changed = false;
    this.hasFocus = true;
    this.getUpdatedChoices();
  },

  onHover: function(event) {
    var element = Event.findElement(event, 'LI');
    if(this.index != element.autocompleteIndex)
    {
      this.index = element.autocompleteIndex;
      this.render();
    }
    Event.stop(event);
  },

  onClick: function(event) {
    var element = Event.findElement(event, 'LI');
    this.index = element.autocompleteIndex;
    this.selectEntry();
    this.hide();
  },

  onBlur: function(event) {
    // needed to make click events working
    setTimeout(this.hide.bind(this), 250);
    this.hasFocus = false;
    this.active = false;
  },

  render: function() {
    if(this.entryCount > 0) {
      for (var i = 0; i < this.entryCount; i++)
        this.index==i ?
        Element.addClassName(this.getEntry(i),"selected") :
        Element.removeClassName(this.getEntry(i),"selected");
      if(this.hasFocus) {
        this.show();
        this.active = true;
      }
    } else {
      this.active = false;
      this.hide();
    }
  },

  markPrevious: function() {
    if(this.index > 0) this.index--;
    else this.index = this.entryCount-1;
    this.getEntry(this.index).scrollIntoView(true);
  },

  markNext: function() {
    if(this.index < this.entryCount-1) this.index++;
    else this.index = 0;
    this.getEntry(this.index).scrollIntoView(false);
  },

  getEntry: function(index) {
    return this.update.firstChild.childNodes[index];
  },

  getCurrentEntry: function() {
    return this.getEntry(this.index);
  },

  selectEntry: function() {
    this.active = false;
    this.updateElement(this.getCurrentEntry());
  },

  //选择了某一项之后应该如何处理，需要根据情况换用不同的实现
  updateElement: function(selectedElement) {
    if (this.options.updateElement) {
      this.options.updateElement(selectedElement);
      return;
    }
  },

  updateChoices: function(choices) {
    if(!this.changed && this.hasFocus) {
      this.update.innerHTML = choices;
      Element.cleanWhitespace(this.update);
      Element.cleanWhitespace(this.update.down());

      if(this.update.firstChild && this.update.down().childNodes) {
        this.entryCount =
        this.update.down().childNodes.length;
        for (var i = 0; i < this.entryCount; i++) {
          var entry = this.getEntry(i);
          entry.autocompleteIndex = i;
          this.addObservers(entry);
        }
      } else {
        this.entryCount = 0;
      }

      this.stopIndicator();
      this.index = 0;

      if(this.entryCount==1 && this.options.autoSelect) {
        this.selectEntry();
        this.hide();
      } else {
        this.render();
      }
    }
  },

  addObservers: function(element) {
    Event.observe(element, "mouseover", this.onHover.bindAsEventListener(this));
    Event.observe(element, "click", this.onClick.bindAsEventListener(this));
  },

  onObserverEvent: function() {
    this.changed = false;
    this.tokenBounds = null;
    if(this.getToken().length>=this.options.minChars) {
      this.getUpdatedChoices();
    } else {
      this.active = false;
      this.hide();
    }
    this.old_element_value = this.element.value;
  },

  getToken: function() {
    var bounds = this.getTokenBounds();
    return this.element.value.substring(bounds[0], bounds[1]).strip();
  },

  getTokenBounds: function() {
    if (null != this.tokenBounds) return this.tokenBounds;
    var value = this.element.value;
    if (value.strip().empty()) return [-1, 0];
    var diff = arguments.callee.getFirstDifferencePos(value, this.old_element_value);
    var offset = (diff == this.old_element_value.length ? 1 : 0);
    var prevTokenPos = -1, nextTokenPos = value.length;
    var tp;
    for (var index = 0, l = this.options.tokens.length; index < l; ++index) {
      tp = value.lastIndexOf(this.options.tokens[index], diff + offset - 1);
      if (tp > prevTokenPos) prevTokenPos = tp;
      tp = value.indexOf(this.options.tokens[index], diff + offset);
      if (-1 != tp && tp < nextTokenPos) nextTokenPos = tp;
    }
    return (this.tokenBounds = [prevTokenPos + 1, nextTokenPos]);
  }
});

MindpinAutocompleter.Base.prototype.getTokenBounds.getFirstDifferencePos = function(newS, oldS) {
  var boundary = Math.min(newS.length, oldS.length);
  for (var index = 0; index < boundary; ++index)
    if (newS[index] != oldS[index])
      return index;
  return boundary;
};

Ajax.MindpinAutocompleter = Class.create(MindpinAutocompleter.Base, {
  initialize: function(element, update, url, options) {
    this.baseInitialize(element, update, options);
    this.options.asynchronous  = true;
    //this.options.onComplete    = this.onComplete.bind(this);
    this.options.defaultParams = this.options.parameters || null;
    this.url                   = url;
  },

  getUpdatedChoices: function() {
    this.startIndicator();

    var entry = encodeURIComponent(this.options.paramName) + '=' +
    encodeURIComponent(this.getToken());

    this.options.parameters = this.options.callback ?
    this.options.callback(this.element, entry) : entry;

    if(this.options.defaultParams)
      this.options.parameters += '&' + this.options.defaultParams;

    //2月28日，增加本地缓存
    //3月1日，因为考虑到用户信息修改等问题，暂时先不用，而且服务端缓存和HTTP缓存已经足够强
    var input_str = this.element.value;
    //    var cached_response_text = pie.cached_username_advice_hash.get(input_str)
    //    if(!cached_response_text){
    //如果值没有缓存，则发起请求
    new Ajax.Request(this.url, Object.extend(Object.clone(this.options),{
      onComplete: function(request) {
        pie.cached_username_advice_hash.set(input_str,request.responseText);
        this.updateChoices(request.responseText);
      }.bind(this)
    }));
  //    }else{
  //      //否则直接取缓存好了
  //      this.updateChoices(cached_response_text);
  //    }
  }
});

// 用于控制站内信列表选中的类 李飞添加
MplistLiCheckBoxSelect = Class.create({
  initialize: function (dom_id){
    this.ul_dom = $(dom_id)
    this.add_checkbox_change_evt()
  },
  check_message_topic_li: function(li){
    li.select("input[type='checkbox']").each(function(check_box){
      check_box.checked = true
      this.check_or_cancel(check_box)
    }.bind(this))
  },
  cancel_check_message_topic_li: function(li){
    li.select("input[type='checkbox']").each(function(check_box){
      check_box.checked = false
      this.check_or_cancel(check_box)
    }.bind(this))
  },
  check_or_cancel:function(input){
    var li = input.up('li')
    if(input.checked == true){
      li.addClassName("checkbox_selected")
    }else if(input.checked == false){
      li.removeClassName("checkbox_selected")
    }
  },
  add_checkbox_change_evt:function(){
    $(this.ul_dom).observe('change',function(evt){
      var element = Event.element(evt)
      if(element.tagName == 'INPUT' && element.readAttribute('type')=='checkbox'){
        this.check_or_cancel(element)
      }
    }.bind(this))
  }
});

MplistLiCheckBoxSelect.select = function(mplist,checked,selector_func){
  $(mplist).childElements().each(function(cld){
    if(cld.tagName=='LI'){
      var li = cld;
      if(selector_func == null || selector_func(li)){
        MplistLiCheckBoxSelect._select(li,checked)
      }else{
        MplistLiCheckBoxSelect._select(li,false)
      }
    }
  });
};

MplistLiCheckBoxSelect._select = function(li,checked){
  li.select("input[type='checkbox']").each(function(check_box){
    check_box.checked = checked
  });
  if(checked){
    li.addClassName("checkbox_selected");
  }else{
    li.removeClassName("checkbox_selected");
  }
}

//MplistLiCheckBoxSelect = Class.create({
//  initialize: function (settings){
//    this.settings = settings
//    this.init()
//    this.add_checkbox_change_evt()
//  },
//  init:function(){
//    var settings = this.settings
//    settings.check_all_btns.each(function(btn){
//      btn.observe('click',function(evt){
//        evt.stop()
//        var lis = this.select_all_message_topic_li()
//        lis.each(function(li){
//          this.check_message_topic_li(li)
//        }.bind(this))
//      }.bind(this))
//    }.bind(this))
//
//    settings.cancel_check_all_btns.each(function(btn){
//      btn.observe('click',function(evt){
//        evt.stop()
//        this.cancel_check_all_message_topic_li()
//      }.bind(this))
//    }.bind(this))
//
//    if(settings.check_read_btns!=null){
//      settings.check_read_btns.each(function(btn){
//        btn.observe('click',function(evt){
//          evt.stop()
//          this.cancel_check_all_message_topic_li()
//          var read_lis = this.select_read_message_topic_li()
//          read_lis.each(function(li){
//            this.check_message_topic_li(li)
//          }.bind(this))
//        }.bind(this))
//      }.bind(this))
//    }
//
//    if(settings.check_unread_btns!=null){
//      settings.check_unread_btns.each(function(btn){
//        btn.observe('click',function(evt){
//          evt.stop()
//          this.cancel_check_all_message_topic_li()
//          var read_lis = this.select_unread_message_topic_li()
//          read_lis.each(function(li){
//            this.check_message_topic_li(li)
//          }.bind(this))
//        }.bind(this))
//      }.bind(this))
//    }
//
//    if(settings.check_used_btns!=null){
//      settings.check_used_btns.each(function(btn){
//        btn.observe('click',function(evt){
//          evt.stop()
//          this.cancel_check_all_message_topic_li()
//          var read_lis = this.select_used_li()
//          read_lis.each(function(li){
//            this.check_message_topic_li(li)
//          }.bind(this))
//        }.bind(this))
//      }.bind(this))
//    }
//
//    if(settings.check_unused_btns!=null){
//      settings.check_unused_btns.each(function(btn){
//        btn.observe('click',function(evt){
//          evt.stop()
//          this.cancel_check_all_message_topic_li()
//          var read_lis = this.select_unused_li()
//          read_lis.each(function(li){
//            this.check_message_topic_li(li)
//          }.bind(this))
//        }.bind(this))
//      }.bind(this))
//    }
//  },
//  check_message_topic_li: function(li){
//    li.select("input[type='checkbox']").each(function(check_box){
//      check_box.checked = true
//      this.check_or_cancel(check_box)
//    }.bind(this))
//  },
//  cancel_check_message_topic_li: function(li){
//    li.select("input[type='checkbox']").each(function(check_box){
//      check_box.checked = false
//      this.check_or_cancel(check_box)
//    }.bind(this))
//  },
//  select_all_message_topic_li: function(){
//    return $(this.settings.ul_dom).select('li')
//  },
//  select_read_message_topic_li: function (){
//    return $(this.settings.ul_dom).select('li div.read').map(function(div){
//      return div.up('li')
//    })
//  },
//  select_unread_message_topic_li: function (){
//    return $(this.settings.ul_dom).select('li div.unread').map(function(div){
//      return div.up('li')
//    })
//  },
//  select_used_li: function(){
//    return $(this.settings.ul_dom).select('li div.used').map(function(div){
//      return div.up('li')
//    })
//  },
//  select_unused_li: function(){
//    return $(this.settings.ul_dom).select('li div.unused').map(function(div){
//      return div.up('li')
//    })
//  },
//  cancel_check_all_message_topic_li: function(){
//    var lis = this.select_all_message_topic_li()
//    lis.each(function(li){
//      this.cancel_check_message_topic_li(li)
//    }.bind(this))
//  },
//  check_or_cancel:function(input){
//    var li = input.up('li')
//    if(input.checked == true){
//      li.addClassName(this.settings.check_add_class_name)
//    }else if(input.checked == false){
//      li.removeClassName(this.settings.check_add_class_name)
//    }
//  },
//  add_checkbox_change_evt:function(){
//    $(this.settings.ul_dom).observe('change',function(evt){
//      var element = Event.element(evt)
//      if(element.tagName == 'INPUT' && element.readAttribute('type')=='checkbox'){
//        this.check_or_cancel(element)
//      }
//    }.bind(this))
//  }
//});

//procedure中的附件显示/隐藏切换
ProcedureAttachmentsHandel = Class.create({
  initialize: function(attrs){
    this.divdom = attrs.divdom;
    this.attachments = attrs.divdom.down('ul');
    this.button_open = attrs.divdom.down('.button_open');
    this.button_close = attrs.divdom.down('.button_close');
    this.button_change = attrs.divdom.down('div.change_style');
    $(this.button_open).observe('click',this.open_attachemnts_by_click.bind(this));
    $(this.button_close).observe('click',this.close_attachemnts_by_click.bind(this));
  },
  open_attachemnts_by_click: function(){
    this.attachments.removeClassName('hide');
    this.button_close.removeClassName('hide');
    this.button_open.addClassName('hide');
    this.button_change.removeClassName('hide');
  },
  close_attachemnts_by_click: function(){
    this.attachments.addClassName('hide');
    this.button_close.addClassName('hide');
    this.button_open.removeClassName('hide');
    this.button_change.addClassName('hide');
  }
});
