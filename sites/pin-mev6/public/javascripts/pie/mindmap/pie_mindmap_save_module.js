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
   * 如果当前编辑器不在READY状态，先把操作记录放入保存数组，然后退出
   *
   */
  _save:function(record){
    if(!this.editmode) return;
    if(this.id == 'demo') return;

    var mindmap = this;

    mindmap.ajax_save_opers = mindmap.ajax_save_opers || [];
    mindmap.ajax_save_opers.push(record);

    //不在ready状态则放入数组后退出
    if(mindmap.on_ajax_save == true){
      return;
    }

    mindmap.__do_ajax_save();
  },

  __do_ajax_save:function(){
    var mindmap = this;

    var id = mindmap.id;
    var ajax_save_opers = mindmap.ajax_save_opers;
    var opers_length = ajax_save_opers.length;

    var revision = mindmap.revision;

    //在ready状态则保存
    var pars =
      'map=' + id + '&' +
      'revision=' + encodeURIComponent(Object.toJSON(revision)) + '&' +
      'operations=' + encodeURIComponent(Object.toJSON(ajax_save_opers));

    mindmap.ajax_save_opers = [];


    var info_label;
    jQuery.ajax({
      url : "/mindmaps/do",
      data : pars,
      type : 'PUT',
      beforeSend : function(){
        info_label = new pie.mindmap.InfoLabel(mindmap).notice('正在自动保存...');
        mindmap.on_ajax_save = true;
        
        //保存过程中都不能点
        mindmap.toolbar.undo_jq.addClass('lock');
        mindmap.toolbar.redo_jq.addClass('lock');
      },
      success : function(res){
        info_label.close();
        mindmap.revision.remote = res.revision;
        //进行了任何操作以后，点亮undo按钮
        mindmap.toolbar.undo_jq.removeClass('lock');
        //进行了任何操作以后，锁定redo按钮
        mindmap.toolbar.redo_jq.addClass('lock');
      },
      error : function(res){
        var code = res.responseText.evalJSON().code;
        switch(code){
          case '1':{
            mindmap.__on_node_not_exist();
          }break;
          case '2':{
            mindmap.__on_mindmap_not_save();
          }break;
          case '3':{
            mindmap.__on_revision_not_valid();
          }break;
          case '4':{
            mindmap.__on_access_not_valid();
          }break;
          default:{
            mindmap.__on_other_error();
          }
        }
      },
      complete : function(){
        pie.log(mindmap.revision);
        mindmap.on_ajax_save = false;

        if(mindmap.ajax_save_opers.length > 0){
          mindmap.__do_ajax_save();
        }
      }
    });

    //每多一个操作，本地版本+1
    mindmap.revision.local += opers_length;
    pie.log(mindmap.revision)
  },

  __on_node_not_exist:function(){
    //第一步 闪烁提示
    new pie.mindmap.InfoLabel(this).error('节点不存在或已删除。').pulsate();

    //第二步 白板遮盖锁定
    this.lock_mindmap();

    var info_dialog = Builder.node('div',{},[
      Builder.node('h3',{'class':'f_box'},'错误#1 试图对一个不存在的节点进行操作'),
      Builder.node('div',{'class':'mindmap_save_error'},[
        Builder.node('div',{},'当前正在被操作的节点在服务器数据中不存在，或者已被其他协同编辑者删除。'),
        Builder.node('a',{'href':'/mindmaps/'+this.id+'/edit'},'请点击这里重新载入导图。'),
        Builder.node('div',{},'或手动刷新页面')
      ])
    ]);

    //第三步 提示刷新
    jQuery.facebox(info_dialog);
    jQuery('#facebox_overlay').unbind('click');
  },

  __on_mindmap_not_save:function(){
    new pie.mindmap.InfoLabel(this).error('导图数据保存失败').pulsate();

    //第二步 白板遮盖锁定
    this.lock_mindmap();

    var info_dialog = Builder.node('div',{},[
      Builder.node('h3',{'class':'f_box'},'错误#2 上一步操作保存失败'),
      Builder.node('div',{'class':'mindmap_save_error'},[
        Builder.node('div',{},'由于网络或服务器原因，或者由于导图已经被其他协同编辑者修改，上一步操作保存失败。'),
        Builder.node('a',{'href':'/mindmaps/'+this.id+'/edit'},'请点击这里重新载入导图。'),
        Builder.node('div',{},'或手动刷新页面')
      ])
    ]);

    //第三步 提示刷新
    jQuery.facebox(info_dialog);
    jQuery('#facebox_overlay').unbind('click');
  },

  __on_revision_not_valid:function(){
    new pie.mindmap.InfoLabel(this).error('导图数据保存失败').pulsate();

    //第二步 白板遮盖锁定
    this.lock_mindmap();

    var info_dialog = Builder.node('div',{},[
      Builder.node('h3',{'class':'f_box'},'错误#3 导图已经被其他人修改'),
      Builder.node('div',{'class':'mindmap_save_error'},[
        Builder.node('div',{},'由于导图已经被其他协同编辑者修改，操作保存失败。'),
        Builder.node('a',{'href':'/mindmaps/'+this.id+'/edit'},'请点击这里重新载入导图。'),
        Builder.node('div',{},'或手动刷新页面')
      ])
    ]);

    //第三步 提示刷新
    jQuery.facebox(info_dialog);
    jQuery('#facebox_overlay').unbind('click');
  },

  __on_access_not_valid:function(){
    new pie.mindmap.InfoLabel(this).error('导图数据保存失败').pulsate();

    //第二步 白板遮盖锁定
    this.lock_mindmap();

    var info_dialog = Builder.node('div',{},[
      Builder.node('h3',{'class':'f_box'},'错误#4 没有编辑权限'),
      Builder.node('div',{'class':'mindmap_save_error'},[
        Builder.node('div',{},'你对当前导图没有编辑权限，或者协同编辑权限已被取消。'),
        Builder.node('a',{'href':'/mindmaps/'+this.id+'/edit'},'请点击这里重新载入导图。'),
        Builder.node('div',{},'或手动刷新页面')
      ])
    ]);

    //第三步 提示刷新
    jQuery.facebox(info_dialog);
    jQuery('#facebox_overlay').unbind('click');
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
    var paper_jq = this.paper.jq;

    var jq = jQuery("<div class='lock-white-board'></div>")
      .css('opacity',0.6)
      .css('width',paper_jq.width())
      .css('height',paper_jq.height())
      .css('position','absolute');

    paper_jq.append(jq);
  }
}

//*******************************
//导图的顶部信息提示区块
pie.mindmap.InfoLabel = Class.create({
  initialize:function(mindmap){
    this.map = mindmap;
    this.el = this._build_dom();
  },
  
  _build_dom:function(){
    var el = Builder.node('div',{'class':'info-label','style':'display:none;'},'');

    var parent_jq = this.map.scroller.jq.parent()
    parent_jq.find('.info-label').remove();
    parent_jq.append(el);
    
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


