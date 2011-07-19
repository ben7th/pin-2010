pie.load(function(){
//  var scriptData = {
//    'authenticity_token':pie.auth_token
//  }
//  scriptData[pie.session_key] = pie.session_value;

  jQuery('#page-mindmap-import-btn').uploadify({
    'uploader'     : '/uploadify/uploadify.swf?'+pie.randstr(),
    'script'       : '/mindmaps/upload_import_file',
    'cancelImg'    : '/uploadify/cancel.png',
    'buttonImg'    : '/uploadify/upload_mindmap_1.png',
    'width'        : 93,
    'height'       : 21,
    'wmode'        : 'transparent',
    'auto'         : true,
    'multi'        : false,
    'fileDataName' : 'file',
    'fileDesc'     : '导图文件 mm, mmap, xmind',
    'fileExt'      : '*.mm;*.mmap;*.xmind;',
    'sizeLimit'    : 4194304,// 4.megabytes
    //'scriptData'   : scriptData,
    'queueID'      : 'page-mindmap-upload-queue',

    'onComplete'  : function(event, ID, fileObj, response, data) {
      var data_json = jQuery.parseJSON(response)
      pie.log(data_json);
      var result_elm = jQuery('.page-upload-mindmap-result');
      result_elm.find('.type .t').html(data_json['type']);
      result_elm.find('.filename .t').html(data_json['filename']);
      result_elm.find('.nodes-count .t').html(data_json['nodes_count']);
      result_elm.find('.thumb').html('<img src="'+ data_json['thumb_src'] +'"/>');

      result_elm.show();

      jQuery('.page-upload-mindmap .upload').hide();
      jQuery('#page-mindmap-upload-queue').hide();

      jQuery('form #upload_temp_id').val(data_json['upload_temp_id']);
      jQuery('form input.text').attr("disabled",false).removeClass('disabled');
      jQuery('form #mindmap_title').val(data_json['filename']);
      jQuery('form textarea').attr("disabled",false).removeClass('disabled');
      jQuery('form input.checkbox').attr("disabled",false).removeClass('disabled');
      jQuery('form span').removeClass('disabled');
      jQuery('form input.submit').attr("disabled",false).removeClass('disabled');
    },
    'onError'     : function (event, ID, fileObj, errorObj) {
      pie.log(errorObj)
      var str = ''
      if(errorObj.info == 422){
        str = '用户身份验证错误，如果该错误反复出现，请尝试退出并重新登录。'
      }else if(errorObj.info == 510){
        str = '不支持导入此文件格式。';
      }else if(errorObj.info == 511){
        str = '导图文件解析出错，可能文件已损坏，或不支持导入此版本软件保存的文件。';
      }else if(errorObj.info == 512){
        str = '导图文件解析过程中，缩略图生成失败。'
      }else if(errorObj.info == 413){
        str = '文件体积过大。'
      }else{
        str = '导图文件上传导入出错。'
      }
      setTimeout(function(){
        jQuery('.uploadifyError .percentage').html(' - '+str);
      },1);
    }
  });
});

pie.load(function(){
  jQuery(document).delegate('.page-upload-mindmap-result .close','click',function(){
    jQuery('.page-upload-mindmap-result').hide();

    jQuery('.page-upload-mindmap .upload').show();
    jQuery('#page-mindmap-upload-queue').show();

    jQuery('form #upload_temp_id').val('');
    jQuery('form input.text').attr("disabled",true).addClass('disabled');
    jQuery('form textarea').attr("disabled",true).addClass('disabled');
    jQuery('form input.checkbox').attr("disabled",true).addClass('disabled');
    jQuery('form span').addClass('disabled');
    jQuery('form input.submit').attr("disabled",true).addClass('disabled');
  })
})