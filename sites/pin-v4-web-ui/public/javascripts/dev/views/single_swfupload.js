SingleSwfUpload = Class.create({
  initialize:function(dom){
    this.form = dom
    // post_params
    var post_params = {}
    var session_key = dom.readAttribute("data-session_key")
    var session_value = dom.readAttribute("data-session_value")
    var authenticity_token = dom.readAttribute("data-authenticity_token")
    post_params[session_key] = session_value
    post_params["authenticity_token"] = authenticity_token
    // input_name
    var input_name = dom.readAttribute("data-input_name")
    // upload_url
    var upload_url = dom.readAttribute("data-upload_url")
    
    // file_list
    var file_list = dom.down(".file_list")
    file_list.id = randstr()
    var file_name = dom.down(".file_name")
    file_name.id = randstr()
    var add_file = dom.down(".add_file")
    add_file.id = randstr()
    var start_upload = dom.down(".start_upload")
    start_upload.id = randstr()

    new SWFUpload(
    {
      flash_url : "/javascripts/swfupload/swfupload.swf",
      upload_url: upload_url,
      file_post_name : input_name,
      file_size_limit : "20 MB",
      file_types : "*.*",
      file_types_description : "All Files",
      file_upload_limit : 100,
      file_queue_limit : 1,
      custom_settings : {
        progressTarget : file_list.id,
        inputFileName : file_name.id,
        startUploadBtn : start_upload.id
      },
      debug: false,

      // 选择文件的按钮样式
      button_image_url: "/javascripts/swfupload/XPButtonUploadText_61x22.png",
      button_width: "61",
      button_height: "22",
      button_placeholder_id: add_file.id,

      swfupload_loaded_handler : single_file_upload.swfupload_loaded_handler,
      // 显示上传进度
      upload_progress_handler : single_file_upload.upload_progress_handler,
      // 文件不合法的错误提示
      file_queue_error_handler : single_file_upload.file_queue_error_handler,
      // 文件上传成功后，运行 rjs
      upload_success_handler : single_file_upload.upload_success_handler,
      // 向上传队列增加文件时,把文件名称显示出来
      file_queued_handler : single_file_upload.file_queued_handler,
      // 点击选择文件时运行,因为只上传一个文件，每次选择文件时，清空文件上传队列
      file_dialog_start_handler: single_file_upload.file_dialog_start_handler,
      // 上传出现异常时的处理
      upload_error_handler: single_file_upload.upload_error_handler
    }
    );
  }
});

SingleSwfUploadManager = {
  load: function(){
    $$(".simple_swf_upload").each(function(dom){
      new SingleSwfUpload(dom)
    })
  }
};
pie.load(SingleSwfUploadManager.load);