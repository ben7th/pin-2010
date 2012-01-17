//=require jquery.hash.js
// 使用一个简单的 jQuery hash 来进行一些基本的页面缓存

//=require mindmap-data.js
// 用来计算节点宽高的函数库

//=require mindmap-classical-layout.js
// 经典导图布局

jQuery.fn.pie_mindmap = function(options){
  options.NODE_Y_GAP = 12; // 节点的垂直相邻间距
  options.NODE_X_GAP = 48; // 节点的水平相邻间距
  options.FD_RADIUS  = 8;  // 折叠点半径
  options._FD_CANVAS_OFFSET = 14; // (FD_RADIUS - 1)*2
  
  options.INIT_ANIMATION_PERIOD = 800;
  options.RELAYOUT_ANIMATION_PERIOD = 400;

  var R = {
    options    : options,
	  board_elm  : jQuery(this), // 被初始化的作为画板的dom的jQuery-object对象
		paper_elm  : jQuery('<div class="paper"></div>').appendTo(this), // 放置节点的画布对象
		canvas_elm : jQuery('<canvas></canvas>').prependTo(this).hide(),
		data       : null, // 从/mindmaps/:id.js 载回的json-object对象
		data_kv    : {}
	}

  jQuery.ajax({
    url : options.data_url,
		type : 'GET',
		dataType : 'json',
		success : function(res){
		  try{
		    R.data = res;
			  draw_map();
		    bind_events();
	    }catch(e){
	      pie.log(e);
	    }
		}
	});
	
	// 遍历计算所有节点的文字（如果有图片则包括图片）宽高
	var draw_map = function(){
    pie.log(R.data);
		// 第一步，遍历全部节点，在节点对象上设置好 parent 等属性，并生成dom
    pie.mindmap.init_data(R);
		// 第二步，按经典布局排布
		pie.mindmap.do_layout_classical(R);
	}
	
	// 绑定各种事件
	var bind_events = function(){
	  R.paper_elm
  	  .drag('start', function(evt, dd){
  	    R.board_elm.data('drag-original-scroll-left', R.board_elm.scrollLeft());
  	    R.board_elm.data('drag-original-scroll-top',  R.board_elm.scrollTop());
  	  })
  	  .drag(function(evt, dd){
  	    R.board_elm.scrollLeft(R.board_elm.data('drag-original-scroll-left') - dd.deltaX);
  	    R.board_elm.scrollTop( R.board_elm.data('drag-original-scroll-top')  - dd.deltaY);
  	  })
	}
	
	return R;
}

pie.load(function(){
  MINDMAP = jQuery('.main .board').pie_mindmap({
    data_url : '/mindmaps/'+PAGE_MINDMAP_ID+'.js'
  })
});