pie.load(function(){
  var file_input_elm = jQuery('.page-file-upload input[type=file]');
  var photos_elm = jQuery('.page-photos');

/*
  .uploading-photo.aj-loading{:style=>'display:none;'}
    .meta
      .desc 正在上传文件
      .file-name.bold abc.jpg
      .file-size.bold 40KB
    .process
      .p
 */

  var uploading_photo_elm = jQuery(
    '<div class="uploading-photo aj-loading">'+
      '<div class="meta">'+
        '<div class="desc">正在上传文件</div>'+
        '<div class="file-name bold"></div>'+
        '<div class="file-size bold"></div>'+
      '</div>'+
      '<div class="process">'+
        '<div class="p"></div>'+
      '</div>'+
      '<a class="error-close" href="javascript:;">关闭</div>'+
    '</div>'
  );

  jQuery('.page-photos .uploading-photo.error .error-close').live('click',function(){
    var elm = jQuery(this);
    var photo_elm = elm.closest('.uploading-photo')
    photo_elm.fadeOut(function(){
      photo_elm.remove();
    })
  })

  var get_file_size_str = function(file){
    var file_size_str = '0KB';
    var file_size = file.size;
    if(file_size > 1024 * 1024){
      file_size_str = (Math.round(file_size * 100 / (1024 * 1024)) / 100).toString() + 'MB';
    }else{
      file_size_str = (Math.round(file.size * 100 / 1024) / 100).toString() + 'KB';
    }
    return file_size_str;
  }

  var create_file_uploading_elm = function(file){
    var uploading_elm = uploading_photo_elm.clone();
    uploading_elm.find('.file-name').html(file.name);
    uploading_elm.find('.file-size').html(get_file_size_str(file));
    uploading_elm.find('.p').css('width',0)
    uploading_elm.hide().fadeIn().prependTo(photos_elm);
    return uploading_elm;
  }

  var do_upload_file = function(file){
    var uploading_elm = create_file_uploading_elm(file);

    var form_data = new FormData();
    form_data.append('file',file);
    form_data.append('authenticity_token',decodeURIComponent(decodeURIComponent(pie.auth_token)));
    form_data.append(pie.session_key,pie.session_value);
    
    var xhr = new XMLHttpRequest();

    xhr.upload.addEventListener("progress", function(evt){
      pie.log('pregress');

      if (evt.lengthComputable) {
        var percentComplete = Math.round(evt.loaded * 100 / evt.total);
        uploading_elm.find('.p').animate({'width':percentComplete+'%'})
      }
      else {
        pie.log('unComputable')
      }
    }, false);


    xhr.onload = function(evt){
      var status = xhr.status;
      if ( status >= 200 && status < 300 || status === 304 ){
        //上传成功
        pie.log('success');
        var res = xhr.responseText;
        var new_photo_elm = jQuery(res);
        
        uploading_elm.find('.p').animate({'width':'100%'},function(){
          uploading_elm.after(new_photo_elm).remove();
          new_photo_elm.hide().fadeIn();
        })

      }else{
        //上传失败
        pie.log('error');
        uploading_elm.addClass('error').removeClass('aj-loading').find('.desc').html('上传失败');
        
      }
    };

//    xhr.onerror = function(){
//      pie.log('error');
//    }

//    xhr.addEventListener("abort", upload_canceled, false);

    xhr.open("POST", "/photos");
    xhr.send(form_data);
  };

  file_input_elm.bind('change',function(){
    var file = file_input_elm[0].files[0];
    if(file){
      do_upload_file(file);
    }
  })
})