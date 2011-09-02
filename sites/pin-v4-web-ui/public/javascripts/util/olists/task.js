pie.load(function(){
  var task_olist_elm = jQuery('.page-olist.tasks');
  if(!task_olist_elm[0]) return; //页面无对应元素则不加载事件

  var ops_delete_elm = task_olist_elm.find('.task .ops .delete')

  ops_delete_elm.live('click',function(){
    var elm = jQuery(this);
    var task_elm = elm.closest('.task');
    elm.confirm_dialog('确定删除吗',function(){
      // delete /tasks/:id
      var task_id = task_elm.domdata('id');
      jQuery.ajax({
        url : '/tasks/'+task_id,
        type : 'delete',
        success : function(){
          task_elm.css('overflow','hidden')
            .animate({
              'height':0,'opacity':0
            },200,function(){
              task_elm.remove();
            })
        }
      })
    })
  })
})