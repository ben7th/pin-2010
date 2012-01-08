pie.load(function(){
	var grids_elm = jQuery('.page-mindmaps-grids')
		.fadeIn(1000)
	  .isotope({
	    itemSelector : '.gi',
	    masonry : { columnWidth : 186 },
			transformsEnabled : false
	  });
		
	// 创建思维导图
	// POST /create
	grids_elm.find('.create-mindmap input').val('');
	grids_elm.find('.create-mindmap a.submit').live('click', function(){
    var elm = jQuery(this);
		var form_elm = elm.closest('form');
		var params = form_elm.serialize();
		
		jQuery.ajax({
		  url : '/create',
			type : 'POST',
			data : params,
			success : function(res){
			  add_new_mindmap(res);
        grids_elm.find('.create-mindmap input').val('');
			}
		})
	})
	
	
	// 导入思维导图
	// POST /import
	grids_elm.find('.import-mindmap input.file').val('').html5Uploader({
    name : 'file',
    postUrl : '/import',
		onSuccess : function(evt, file, res){
		  add_new_mindmap(res);
			grids_elm.find('.import-mindmap input.file').val('');
		}
  });
	
	var add_new_mindmap = function(res){
    var new_mindmap_elm = jQuery(res);
    grids_elm.find('.mindmaps').prepend(new_mindmap_elm);
    grids_elm
      .isotope('reloadItems')
      .isotope({ sortBy: 'original-order' })
	}
	
	// 删除
	// DELETE /mindmaps/:id
	grids_elm.find('.mindmap .ops a.delete').live('click',function(){
	  var elm = jQuery(this);
		var mindmap_elm = elm.closest('.mindmap');
		var mindmap_id = mindmap_elm.data('id');
		
		elm.confirm_dialog('删除了就没有了，确定吗',function(){
			jQuery.ajax({
			  url : '/mindmaps/' + mindmap_id,
				type : 'delete',
				success : function(){
				  grids_elm.isotope( 'remove', mindmap_elm );
				}
			})
		})
	})
	
});