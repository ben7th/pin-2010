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

    var pars =
      'map=' + this.id + '&' +
      'revision=' + encodeURIComponent(Object.toJSON(this.revision)) + '&' +
      'operation=' + encodeURIComponent(Object.toJSON(record));
    
    var info_label;

    new Ajax.Request("/mindmaps/do",{
      parameters:pars,
      method:"PUT",
      onCreate:function(){
        info_label = new pie.mindmap.InfoLabel(this).notice('正在自动保存...');
      }.bind(this),
      onSuccess:function(trans){
        info_label.close();
      }.bind(this),
      onFailure:function(trans){
        var code = trans.responseText.evalJSON().code;
        switch(code){
          case '1':{
            this.__on_node_not_exist();
          }break;
          case '2':{
            this.__on_mindmap_not_save();
          }break;
          default:{
            this.__on_other_error();
          }
        }
      }.bind(this)
    });

    this.revision.local += 1;
    pie.log(this.revision);
  },

  __on_node_not_exist:function(){
    new pie.mindmap.InfoLabel(this).error('节点不存在或已删除。').hold(5);
  },

  __on_mindmap_not_save:function(){
    var map = pie.MindmapPageLoader.reload_map();
    new pie.mindmap.InfoLabel(map).error('导图数据保存失败，自动重新载入。').hold(5);
  },

  __on_other_error:function(){
    //第一步 闪烁提示
    new pie.mindmap.InfoLabel(this).error('网络或服务发生异常。').pulsate();

    //第二步 白板遮盖锁定
    this.lock_mindmap();

    var info_dialog = Builder.node('div',{},[
      Builder.node('h3',{'class':'f_box'},'网络或服务发生异常'),
      Builder.node('div',{'class':'mindmap_save_error'},[
        Builder.node('div',{},'由于网络或其他原因，导图上一步操作失败。'),
        Builder.node('a',{'href':'/mindmaps/'+this.id+'/edit'},'请点击这里重新载入导图。'),
        Builder.node('div',{},'或手动刷新页面')
      ])
    ]);

    //第三步 提示刷新
    jQuery.facebox(info_dialog);
    jQuery('#facebox_overlay').unbind('click');
  },

  coop_break:function(){
   //第一步 闪烁提示
    new pie.mindmap.InfoLabel(this).error('网络或服务发生异常。').pulsate();

    //第二步 白板遮盖锁定
    this.lock_mindmap();

    var info_dialog = Builder.node('div',{},[
      Builder.node('h3',{'class':'f_box'},'协同编辑导致的编辑中断'),
      Builder.node('div',{'class':'mindmap_save_error'},[
        Builder.node('div',{},'其他人正在编辑导图，导图内容已被修改，你的编辑被中断'),
        Builder.node('a',{'href':'/mindmaps/'+this.id+'/edit'},'请点击这里重新载入导图。'),
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
  }
}

pie.mindmap.InfoLabel = Class.create({
  initialize:function(mindmap){
    this.map = mindmap;
    this._remove_all_label_dom();
    this.el = this._build_dom();
  },
  _remove_all_label_dom:function(){
    var parent_dom_id = this.map.observer.el.parentNode.id;
    jQuery('#'+parent_dom_id+' .info-label').remove();
  },

  _build_dom:function(){
    var parent_dom = this.map.observer.el.parentNode;
    var el = Builder.node('div',{'class':'info-label','style':'display:none;'},'');
    Element.insert(parent_dom, el);
    return el;
  },

  hold:function(second){
    setTimeout(function(){
      $(this.el).fade({duration:0.2});
    }.bind(this),second*1000)
  },
  
  pulsate:function(){
    new Effect.Pulsate(this.el, {pulses:50, duration:60, from:1.0, to:0.2});
    return this;
  },

  close:function(){
    $(this.el).fade({duration:0.2});
    return this;
  },

  notice:function(text){
    $(this.el).addClassName('notice').update(text).appear({duration:0.2});
    return this;
  },

  error:function(text){
    $(this.el).addClassName('error').update(text).appear({duration:0.2});
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


