pie.MindmapPageLoader = {
  _init:function(){
    $("mindmap-canvas").update('');
    this.sidebar = $('mindmap-sidebar');
    this.toggle_sidebar_button = $$('a.toggle-sidebar')[0];

    jQuery('a.mindmap-recenter')
      .live("mousedown",function(){jQuery(this).addClass("mousedown")})
      .live("mouseup mouseleave",function(){jQuery(this).removeClass("mousedown")});
  },

  //重新载入当前导图，先这么写，观察一下看看会不会有其他问题
  //可能还要考虑内存问题
  reload_map:function(){
    var old_map = window.mindmap;
    var mindmap_id = old_map.id;
    var editmode = old_map.editmode;
    $('mindmap-canvas').update('');

    window.mindmap = new pie.mindmap.BasicMapPaper("mindmap-canvas",{
      id:mindmap_id,
      loader: new pie.mindmap.JSONLoader({url:'/mindmaps/' + mindmap_id}),
      editmode: editmode,
      after_load:function(){
        mindmap.root.select();
      }.bind(this)
    }).load();

    delete old_map;

    return window.mindmap;
  },

  _load_map:function(mindmap_id,editmode){
    window.mindmap = new pie.mindmap.BasicMapPaper("mindmap-canvas",{
      id:mindmap_id,
      loader: new pie.mindmap.JSONLoader({url:'/mindmaps/' + mindmap_id}),
      editmode: editmode,
      after_load:function(){
        mindmap.root.select();
        if(editmode){
          this.pull(mindmap_id);
        }
      }.bind(this)
    }).load();
  },

  _after_init:function(){
    this.mindmap_resize();
    Event.observe(window,"resize",this.mindmap_resize.bind(this));
    return this;
  },

  load_editor_page:function(mindmap_id){
    this._init();
    this._load_map(mindmap_id,true);
    this._after_init();

    return this;
  },

  load_viewer_page:function(mindmap_id){
    this._init();
    this._load_map(mindmap_id,false);
    return this._after_init();
  },

  mindmap_resize:function(){
    var height = document.viewport.getHeight() - 40 - 38;
    var sidebar_width = this.sidebar.visible() ? this.sidebar.getWidth():0;
    var width = $('mindmap-status-bar').getWidth() - sidebar_width;
    $('mindmap-main').setStyle({
      'height':height + 'px'
    });
    $('mindmap-resizer').setStyle({
      'height':height + 'px',
      'width':width + 'px'
    });
  },
  show_comments:function(mindmap_id){
    new Ajax.Updater("comments-list","/mindmaps/"+mindmap_id+"/comments",{
      method:'GET',
      onCreate:function(){
        $("comments-list").update('<div class="loading"></div>');
      }
    });
  },
  
  pull:function(mindmap_id){
    var pars =
      'map=' + mindmap_id + '&' +
      'revision=' + Object.toJSON(mindmap.revision);

    new Ajax.Request("/mindmaps/pull",{
      parameters:pars,
      method:'GET',
      onFailure:function(trans){
        pie.log('获取失败');
        setTimeout(function(){
          this.pull(mindmap_id);
        }.bind(this),6000);
      }.bind(this),
      onSuccess:function(trans){
        try{
          var array = trans.responseText.evalJSON();
          array.each(function(json){
            pie.log('同步协同暂未实现，不对其他编辑请求作处理')
            mindmap.coop_break();
//            mindmap.show_op_instance(json);
          }.bind(this))

          setTimeout(function(){
            this.pull(mindmap_id);
          }.bind(this),6000);
        }catch(e){}
      }.bind(this)
    });
  },

//  add_chat:function(chat_json){
//    var username = chat_json.username;
//    var text = chat_json.text;
//    var cl = $$('.chat-list')[0];
//    var node = Builder.node('div',{'class':'chat-line'},[
//      Builder.node('span',{'class':'username'},username+': '),
//      Builder.node('span',{},text)
//    ]);
//    cl.appendChild(node);
//  },

  toggle_sidebar:function(){
    Element.toggle(this.sidebar);
    Element.toggleClassName(this.toggle_sidebar_button,'open')
    this.mindmap_resize();
    return this;
  }
}

TimeKeeper = Class.create({
  initialize : function(url){
    this.url = url;
    this.frequence = 0;
    this.ave_time = 0;
    this.total_time = 0;
    this.request_per_half_minute();
  },
  request_per_half_minute : function(){
    new PeriodicalExecuter(function() {
      var begin_time = new Date();
      new Ajax.Request(this.url,{
        method: 'get',
        onSuccess:function(response){
          var respond_time = (new Date()-begin_time);
          this.total_time = this.total_time + respond_time;
          this.frequence = this.frequence + 1;
          this.ave_time = this.total_time/this.frequence;
          $$("#net_condition .last_respond span.time")[0].update(respond_time)
          $$("#net_condition .average_respond span.time")[0].update(Math.round(this.ave_time))
        }.bind(this)
      })
    }.bind(this), 30);
  }
});

pie.MindmapUser = Class.create({
  initialize:function(user_name,mindmap_id){
    this.user_name = user_name;
    this.mindmap_id = mindmap_id;
  },
  say:function(text){
    try{
      var json = Object.toJSON({
        'username':this.user_name,
        'text':text
      });
      var pars = 'channel='+'mindmap_'+this.mindmap_id;
      new Ajax.Request("/mindmaps/push?"+pars,{
        method:'POST',
        postBody:json,
        onSuccess:function(trans){
          //
        }
      });
    }catch(ex){
      alert(ex)
    }
  }
});
