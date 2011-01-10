pie.mindmap_save_module = {
  /**
   * 2009-1-8 jerry
   * 改为细粒度保存之后，可能（但不确定）会出现客户端请求提交顺序和服务端请求处理顺序不同的问题
   * 从而导致导图编辑中可能会出现难以预期的问题，导致数据的损坏
   * 为了避免这一问题，修改为当导图不处于等待提交的状态时，所有record并不提交，而是放入队列
   * 当等待提交状态改变时，提交整个队列。同时服务器端按照顺序处理操作指令请求
   *
   * 操作顺序
   * 如果当前不是编辑模式，方法直接退出
   * 如果当前是DEMO，直接退出
   * 如果当前编辑器不在READY状态，先把操作记录放入队列，然后退出
   *
   */
  _save:function(record){
    if(!this.editmode) return;
    if(this.id == 'demo') return;

    if(record!=null) this.opQueue.push(record);
    if(!this.ready_to_request) return;

    var pars =
      'map=' + this.id + '&' +
      'revision=' + this.revision + '&' +
      'operations=' + encodeURIComponent(this.opQueue.toJSON());
    
    new Ajax.Request("/mindmaps/do",{
      parameters:pars,
      method:"PUT",
      onCreate:function(){
        this.ready_to_request=false;
        this.show_notice_info('正在自动保存...')
        this.opQueue = [];
      }.bind(this),
      onSuccess:function(trans){
        this.revision = trans.responseText.evalJSON().revision;
        this.ready_to_request=true;
        this.close_info();
        if(this.opQueue.length > 0) this._save();
      }.bind(this),
      onFailure:function(trans){
        this.__on_save_error()
      }.bind(this)
    });
  },

  __on_save_error:function(){
    //第一步 闪烁提示
    this.show_error_info('数据保存失败').pulsate();
    //第二步 白板遮盖锁定
    this.lock_mindmap();

    var info_dialog = Builder.node('div',{},[
      Builder.node('h3',{'class':'f_box'},'数据保存失败'),
      Builder.node('div',{'class':'mindmap_save_error'},[
        Builder.node('div',{},'由于网络原因，导图保存失败。'),
        Builder.node('a',{'href':'/mindmaps/'+this.id+'/edit'},'请点击这里重新载入。'),
        Builder.node('div',{},'或手动刷新页面')
      ])
    ]);

    //第三步 提示刷新
    jQuery.facebox(info_dialog);
    jQuery('#facebox_overlay').unbind('click');
  },
  lock_mindmap:function(){
    if(!this.lock_whiteboard){
      this.lock_whiteboard = new pie.mindmap.LockWhiteBoard(this);
    }
    //第二步 白板遮盖
    this.lock_whiteboard.show();
  },

  show_notice_info:function(text){
    this._build_info_label();
    this.save_status_label.notice(text);
    return this.save_status_label;
  },
  show_error_info:function(text){
    this._build_info_label();
    this.save_status_label.error(text);
    return this.save_status_label;
  },
  close_info:function(){
    setTimeout(function(){
      this.save_status_label.fade();
    }.bind(this),1000);
  },
  _build_info_label:function(){
    if(!this.save_status_label){
      this.save_status_label = new pie.mindmap.InfoLabel(this);
    }
  }
}

pie.mindmap.InfoLabel = Class.create({
  initialize:function(mindmap){
    try{
      this.map = mindmap;
      this._build_dom();
    }catch(e){alert(e)}
  },
  _build_dom:function(){
    var parent_dom = this.map.observer.el.parentNode;
    this.el = Builder.node('div',{'class':'info-label','style':'display:none;'},'');
    Element.insert(parent_dom,this.el);
  },
  pulsate:function(){
    new Effect.Pulsate(this.el,{pulses:50,duration:60,from:1.0,to:0.2});
  },
  fade:function(){
    $(this.el).fade({duration:0.2});
    return this;
  },
  show:function(text){
    this.el.innerHTML = text;
    $(this.el).appear({duration:0.2});
    return this;
  },
  notice:function(text){
    $(this.el).addClassName('notice');
    this.show(text)
    return this;
  },
  error:function(text){
    $(this.el).addClassName('error');
    this.show(text)
    return this;
  },
  clear:function(){
    $(this.el).removeClassName('notice').removeClassName('success').removeClassName('error');
    return this;
  }
});

pie.mindmap.LockWhiteBoard=Class.create({
  initialize:function(mindmap){
    try{
      this.map = mindmap;
      this._build_dom();
    }catch(e){alert(e)}
  },
  _build_dom:function(){
    this.el = Builder.node('div',{'class':'lock-white-board','style':'display:none;'});
    $(this.el).setStyle({opacity:0.6});
    
    var paper_dom = this.map.paper.el;
    Element.insert(paper_dom,this.el);
  },
  show:function(){
    var paper_dom = this.map.paper.el;
    $(this.el).clonePosition(paper_dom,{setLeft:false,setTop:false}).show();
  }
});


