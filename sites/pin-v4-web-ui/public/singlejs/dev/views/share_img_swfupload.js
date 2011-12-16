ShareImgSwfUpload = Class.create({
  initialize:function(dom){
    this.attachment_list_dom = dom
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
    var share_btn = dom.down(".share_img")
    share_btn.id = randstr()
    // img
    var img_list = dom.down(".img_list")
    img_list.id = randstr()
    new SWFUpload(
    {
      flash_url : "/javascripts/swfupload/swfupload.swf",
      upload_url: upload_url,
      post_params: post_params,
      file_post_name : input_name,
      file_size_limit : "20 MB",
      file_types : "*.*",
      file_types_description : "All Files",
      file_upload_limit : 100,
      file_queue_limit : 0,
      custom_settings : {
        progressTarget : img_list.id
      },
      debug: false,

      // 增加文件按钮
      button_image_url: "/javascripts/swfupload/XPButtonUploadText_61x22.png",
      button_width: "61",
      button_height: "22",
      button_placeholder_id: share_btn.id,

      // 显示上传进度
      upload_progress_handler : share_img_upload.upload_progress_handler,
      // 运行服务器传回的 rjs
      upload_success_handler : share_img_upload.upload_success_handler,
      // 开始上传,提供取消按钮
      upload_start_handler : share_img_upload.upload_start_handler,
      // 上传失败的错误提示
      upload_error_handler : share_img_upload.upload_error_handler,
      // 文件不合法的错误提示
      file_queue_error_handler : share_img_upload.file_queue_error_handler,
      // 增加文件立即上传
      file_queued_handler : share_img_upload.file_queued_handler,
      // 每个文件上传完成后运行
      upload_complete_handler : share_img_upload.upload_complete_handler
    });
  }
});

pie.load(function(){
  $$(".share_img_swf_upload").each(function(dom){
    new ShareImgSwfUpload(dom)
  })
});