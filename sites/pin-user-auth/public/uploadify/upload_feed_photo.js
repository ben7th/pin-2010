pie.load(function(){
  var scriptData = {
    'authenticity_token':pie.auth_token
  }
  scriptData[pie.session_key] = pie.session_value;

  var form_photos_elm = jQuery('.page-new-feed-form .field.photos');
  var form_photos_ipter_elm = jQuery('.page-new-feed-form .field.photos .photos-ipter').val('');

  jQuery('#page-upload-photo-btn').uploadify({
    'uploader'     : '/uploadify/uploadify.swf?'+pie.randstr(),
    'script'       : '/photos/feed_upload',
    'cancelImg'    : '/uploadify/cancel.png',
    'buttonImg'    : '/uploadify/upload_photo.png',
    'width'        : 93,
    'height'       : 21,
    'wmode'        : 'transparent',
    'auto'         : true,
    'multi'        : true,
    'fileDataName' : 'file',
    'fileDesc'     : '图像文件',
    'fileExt'      : '*.jpg;*.jpeg;*.gif;*.png;',
    'sizeLimit'    : 4194304,// 4.megabytes
    'scriptData'   : scriptData,
    'queueID'      : 'page-upload-queue',

    'onComplete'  : function(event, ID, fileObj, response, data) {
      var new_photos_elm = jQuery(response);

      new_photos_elm.appendTo(form_photos_elm).hide().fadeIn();

      var photo_ids = [];
      form_photos_elm.find('.photo').each(function(){
        photo_ids.push(jQuery(this).domdata('id'));
      })

      form_photos_ipter_elm.val(photo_ids);
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
        str = '图像上传出错。'
      }
      setTimeout(function(){
        jQuery('.uploadifyError .percentage').html(' - '+str);
      },1);
    }
  });
});