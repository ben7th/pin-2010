//=require jquery.hash.js
// 使用一个简单的 jQuery hash 来进行一些基本的页面缓存

//=require mindmap-node-compute.js
// 用来计算节点宽高的函数库

//=require mindmap-classical-layout.js
// 经典导图布局

jQuery.fn.pie_mindmap = function(options){
  options.node_vertical_gap = 6; // 节点的垂直相邻间距
  options.node_horizontal_gap = 20; // 节点的水平相邻间距

  var R = {
    options    : options,
	  canvas_elm : jQuery(this), // 被初始化的作为画布的dom的jQuery-object对象
		paper_elm  : jQuery('<div></div>').addClass('paper').appendTo(this), // 放置节点的画布对象
		data       : null, // 从/mindmaps/:id.js 载回的json-object对象
	}

  jQuery.ajax({
    url : options.data_url,
		type : 'GET',
		dataType : 'json',
		success : function(res){
		  R.data = res;
			draw_map();
		  
		}
	});
	
	// 遍历计算所有节点的文字（如果有图片则包括图片）宽高
	var draw_map = function(){
    pie.log(R.data);
		// 第一步，遍历全部节点，在节点对象上设置好 parent 等属性，并生成dom
    pie.mindmap.init_data(R);
		// 第二步
		pie.mindmap.do_layout_classical(R);
	}
}

jQuery('.main .canvas').pie_mindmap({
  data_url : '/mindmaps/'+PAGE_MINDMAP_ID+'.js'
});