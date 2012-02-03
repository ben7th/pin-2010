// 加载导图所需的各个组件。组件互不依赖，逻辑解耦，顺序不限。

//=require jquery.hotkeys.js

//=require mindmap-hash.js
// 一个简单的Hash类实现 pie.Hash

//=require mindmap-base.js

//=require mindmap-doms.js
//=require mindmap-image-lightbox.js
//=require mindmap-classical-layout.js
//=require mindmap-classical-layout-lines.js
//=require mindmap-folding.js
//=require mindmap-focus.js

//=require mindmap.edit-event.js

jQuery.fn.pie_mindmap = function(options){
  options.NODE_Y_GAP = 12; // 节点的垂直相邻间距
  options.NODE_X_GAP = 48; // 节点的水平相邻间距
  options.FD_RADIUS  = 8;  // 折叠点半径
  options._FD_CANVAS_OFFSET = 14; // (FD_RADIUS - 1)*2
  
  options.INIT_ANIMATION_PERIOD = 800; //0.8s
  options.RELAYOUT_ANIMATION_PERIOD = 400; //0.4s

  var R = {
    options    : options,
    board_elm  : jQuery(this).empty(), // 被初始化的作为画板的dom的jQuery-object对象
    paper_elm  : jQuery('<div class="paper"></div>').appendTo(this), // 放置节点的画布对象
    data       : null, // 从/mindmaps/:id.js 载回的json-object对象
    
    // node_hash
    node_hash  : new pie.Hash(),
    n_count : function(){
      return R.node_hash.size;
    },
    enter : function(node){
      R.node_hash.set(node.id, node);
    },
    drop : function(node){
      R.node_hash.remove(node.id);
    },
    get : function(node_id){
      return R.node_hash.get(node_id);
    },
    each_do : function(func){
      R.node_hash.each(func);
    },
    
    // init_list
    init_list : [],
    init : function(){
      pie.log(R.data);
      jQuery.each(R.init_list, function(index, func){
        func(R);
      })
    }
  }
  
  var load_ext = function(ext){
    var BASE = pie.mindmap.base;
    jQuery.extend(BASE.shared_methods, ext.shared_methods||{});
    jQuery.extend(BASE.root_methods, ext.root_methods||{});
    jQuery.extend(BASE.node_methods, ext.node_methods||{});
    
    R.init_list.push(ext.init);
  }
  
  load_ext(pie.mindmap.base);
    load_ext(pie.mindmap.doms);
      load_ext(pie.mindmap.image_lightbox);
      load_ext(pie.mindmap.classical_layout);
        load_ext(pie.mindmap.classical_layout_lines);
        load_ext(pie.mindmap.folding);
      load_ext(pie.mindmap.focus);
  
  // 编辑相关事件。。
  //  load_ext(pie.mindmap.edit_events);
  
  // 基础拖拽事件
  R.paper_elm
    .drag('start', function(evt, dd){
      R.board_elm.data('drag-original-scroll-left', R.board_elm.scrollLeft());
      R.board_elm.data('drag-original-scroll-top',  R.board_elm.scrollTop());
    })
    .drag(function(evt, dd){
      R.board_elm.scrollLeft(R.board_elm.data('drag-original-scroll-left') - dd.deltaX);
      R.board_elm.scrollTop( R.board_elm.data('drag-original-scroll-top')  - dd.deltaY);
    })
  
  jQuery.ajax({
    url : options.data_url,
    type : 'GET',
    dataType : 'json',
    success : function(res){
      try{
        R.data = res;
        R.init();
      }catch(e){
        pie.log(e);
      }
    }
  });
  
  this.R = R;
  return this;
}

// page load
pie.load(function(){
  MINDMAP = jQuery('.main .board').pie_mindmap({
    data_url : '/mindmaps/'+PAGE_MINDMAP_ID+'.js'
  })
});