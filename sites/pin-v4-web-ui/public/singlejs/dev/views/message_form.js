// 消息表单的保存以及各个事件处理
DraftMessageHandle = Class.create({
  initialize: function (form_dom){
    this.form = $(form_dom);
    this.form_id = this.form.id;
    this.time_update_str = this.form.readAttribute("data-time_update_str");
    this.url = this.form.readAttribute("data-draft-url");
    this.button_submit = this.form.select("#button_submit")[0];
    this.button_cancel = this.form.select("#button_cancel")[0];
    this.button_save_draft = this.form.select("#button_save_draft")[0];
    this.time_span = this.form.select("#draft_updated_time")[0];

    this.button_edit_title = this.form.down(".edit_title_button");
    this.title_text_field = this.form.down(".title_text_field");

    this.button_edit_participants = this.form.down(".edit_participants_button");
    this.participants_text_field = this.form.down(".participants_text_field");

    //初始化按钮，并给content_value赋值
    this.init_draft_button();

    var cpe = this._create_periodical_executer.bindAsEventListener(this)
    $(this.form).observe('click',cpe);
    $(this.form).observe('keyup',cpe);

    $(this.button_submit).observe('click',function(){
      this.init_draft_button();
    }.bind(this));

    $(this.button_cancel).observe('click',function(){
      this.init_draft_button();
      this.form.up('div').select('a.reply').each(function(a){
        a.removeClassName('hide')
      })
      this.form.remove();
    }.bind(this));

    $(this.button_save_draft).observe('click',
      this._do_save_button_click.bindAsEventListener(this));
    $(this.button_edit_title).observe('click',
      this._do_edit_title_button_click.bindAsEventListener(this));
    $(this.button_edit_participants).observe('click',
      this._do_edit_participants_button_click.bindAsEventListener(this));
  },
  init_draft_button: function(){
    this.form.elements["message_draft"].value = false //保存草稿然后发送信息的时候要把表单中的draft置为false
    this.content_value = this.form.serialize();
    this.button_save_draft.disabled = true;
    $(this.button_save_draft).addClassName('disabled');
  },
  _create_periodical_executer:function(){
    //目前计时器不存在，并且按钮处于未激活状态时，创建表单内容改变监视计时器
    if(!this.periodical_executer){
      //每10毫秒检测表单值改变，并修改保存草稿按钮状态
      this.periodical_executer = new PeriodicalExecuter(function(){
        this.change_button_status();
      }.bind(this),0.01);

      setTimeout(function(){
        if(this._form_value_changed()){
          this._do_sent_save_request();
        }
        this._remove_periodical_executer.bind(this);
      }.bind(this),10000); //10秒不操作自动保存并清除计时器
    }
  },
  _remove_periodical_executer:function(){
    this.periodical_executer.stop();
    this.periodical_executer = null;
  },
  _form_value_changed:function(){
    var form_values = this.form.serialize();
    return this.content_value != form_values;
  },
  change_button_status: function(){
    //表单存在，且值已经改变，且按钮目前是关闭状态时，才激活按钮
    if(this.form && this._form_value_changed() && this.button_save_draft.disabled){
      this.button_save_draft.disabled = false;
      $(this.button_save_draft).removeClassName('disabled');
      this._remove_periodical_executer();
    }
  },
  _do_save_button_click: function(event){
    event.stop();
    this.content_value = this.form.serialize();
    this._do_sent_save_request();
  },
  _do_sent_save_request:function(){
    var url = this.url;
    this.form.elements["message_draft"].value = true
    new Ajax.Request(url, {
      method: 'post',
      parameters: this.form.serialize(),
      onSuccess: function() {
        this.init_draft_button();
        this._update_draft_saved_time();
      }.bind(this)
    });
  },
  _update_draft_saved_time: function(){
    var time_str = new Date().getFormatValue('hh:mm');
    this.time_span.update(this.time_update_str+"<span class='date'>"+ time_str +"</span>");
    this.time_span.highlight();
  },
  _do_edit_title_button_click: function(){
    this.button_edit_title.addClassName("hide");
    this.title_text_field.removeClassName("hide");
  },
  _do_edit_participants_button_click: function(){
    this.button_edit_participants.addClassName("hide");
    this.participants_text_field.removeClassName("hide");
  }
});

////3月1日 李飞添加的用于站内信用户输入自动提示的类
// 3月24日 修改
MessageParticipant = Class.create({
  initialize: function (form){
    this.form = form
    this.settings = {}
    this.settings.autocomplete_dom = form.down("div.autocomplete")
    this.settings.input_dom = form.down("input.add_input")
    this.settings.participants_list = form.down(".message_participants_inputer")
    this.settings.input_name = this.settings.input_dom.readAttribute("data-input_name")
    this.settings.autocomplete_url = this.settings.input_dom.readAttribute("data-autocomplete_url")
    this.settings.autocomplete_param_name = this.settings.input_dom.readAttribute("data-param_name")
    this.message_participants = []
    // 根据参数创建 autocompleter 对象
    this.create_mindpin_autocompleter()
    this.syn_input_and_user_div()
  },

  create_mindpin_autocompleter: function(){
    var settings = this.settings;
    new Ajax.MindpinAutocompleter(settings.input_dom,settings.autocomplete_dom,settings.autocomplete_url,{
      tokens: ",",
      method: "get",
      paramName: settings.autocomplete_param_name,
      updateElement: function(li){
        var user_info = {
          id:li.id,
          name:li.readAttribute('name')
        }
        this.add_user_by_user_info(user_info)
        this.clear_add_participant_input()
      }.bind(this)
    });
    // 退格键删除
    settings.input_dom.observe('keydown',function(evt){
      if(settings.input_dom.value == "" && evt.keyCode == 8){
        this.remove_last_user()
      }
    }.bind(this));
  },

  // 根据用户信息增加 input , user_div 和 $message_participants条目
  add_user_by_user_info: function(user_info){
    var user_id = user_info.id
    if(this.message_participants.indexOf(user_id) == -1){
      this.add_user_div_by_user_info(user_info)
      this.message_participants.push(user_id)
    }
  },

  // 根据用户信息增加 user_div
  add_user_div_by_user_info: function(user_info){
    var user_div = Builder.node('div',{
      'class':'user'
    },[this.user_info_to_input(user_info),
      Builder.node('span',{},user_info.name),
      Builder.node('a',{
        'class':'remove'
      }," X ").observe('click',function(evt){
        evt.stop()
        var user_id = this.user_div_to_user_id(user_div)
        this.remove_user_by_user_id(user_id)
      }.bind(this))
      ]);

    new Insertion.Before(this.settings.input_dom,user_div)
  },

  // 增加一个人后删除输入框
  clear_add_participant_input: function(){
    $(this.settings.input_dom).value = ""
  },

  // 根据用户信息构建 input
  user_info_to_input: function(user_info){
    var input_value = user_info.id
    return Builder.node('input',{
      type:'text',
      'class':'hide',
      name:this.settings.input_name,
      value:input_value
    })
  },

  user_div_to_user_id: function(user_div){
    return user_div.down("input[type='text']").readAttribute('value')
  },

  // 根据用户信息删除对应的 user_div和$message_participants条目
  remove_user_by_user_id: function(user_id){
    if(this.message_participants.indexOf(user_id) != -1){
      this.remove_user_div_by_user_id(user_id)
      this.message_participants = this.message_participants.without(user_id)
    }
  },

  // 删除用户信息对应的 user_div
  remove_user_div_by_user_id: function(user_id){
    this.settings.participants_list.select("div.user").each(function(div){
      if(div.down("input[type='text']").readAttribute('value') == user_id){
        div.remove()
      }
    })
  },

  // 删除 $message_participants 中最后一个用户对应的 user_div 和 $message_participants条目
  remove_last_user: function(){
    var user_id = this.message_participants.last()
    if(user_id){
      this.remove_user_by_user_id(user_id)
    }
  },

  // 回显用
  syn_input_and_user_div: function(){
    var default_participants = this.parse_default_participants()
    default_participants.each(function(user){
      var user_info = {
        id:user.id,
        name:user.name
      }
      this.add_user_by_user_info(user_info)
    }.bind(this))
  },
  parse_default_participants: function(){
    var default_participants = []
    this.form.select(".default_participant").each(function(div){
      var participant = {}
      participant.id = div.id
      participant.name = div.readAttribute("name")
      default_participants.push(participant)
    }.bind(this));
    return default_participants
  }
});

MessageManager = {
  message_form_load : function(){
    $$(".message_form").each(function(form){
      new DraftMessageHandle(form);
      new MessageParticipant(form);
    })
  }
}

pie.load(MessageManager.message_form_load);