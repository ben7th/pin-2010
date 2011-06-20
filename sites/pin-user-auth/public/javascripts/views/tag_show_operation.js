pie.load(function(){
  var perfix = '.tag-page-top-info .base-info .tag-main ';

  jQuery(perfix + '.edit-detail').live('click',function(){
    var form_elm = jQuery('.tag-detail-edit-form');

    var elm = jQuery(this);
    var tag_elm = elm.closest('.tag-main');
    var detail_elm = tag_elm.find('.detail-data');

    form_elm.show();
    detail_elm.hide();
  });

  //取消
  jQuery(perfix + '.tag-detail-edit-form .editable-cancel').live('click',function(){
    var form_elm = jQuery('.tag-detail-edit-form')
    var elm = jQuery(this);
    var feed_elm = elm.closest('.tag-main');
    var detail_elm = feed_elm.find('.detail-data');
    detail_elm.show();
    form_elm.hide();
  });

  //确定
  jQuery(perfix + '.tag-detail-edit-form .editable-submit').live('click',function(){
    var form_elm = jQuery('.tag-detail-edit-form')
    var elm = jQuery(this);
    var tag_elm = elm.closest('.tag-main');
    var detail_elm = tag_elm.find('.detail-data');
    var tag_name = tag_elm.attr('data-name');
    var content = form_elm.find('.detail-inputer').val();

//    pie.log(tag_name,content)

    //  put /tags/name/detail params[:detail]
    jQuery.ajax({
      url : '/tags/'+tag_name+'/update_detail',
      type : 'put',
      data : 'detail='+encodeURIComponent(content),
      success : function(res){
        var new_tag_elm = jQuery(res).find('.tag-main');
        tag_elm.after(new_tag_elm);
        tag_elm.remove();
        form_elm.hide();
      }
    })
  });
  
})