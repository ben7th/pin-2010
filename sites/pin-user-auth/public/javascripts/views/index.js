(function(){

  pie.load(function(){
    //导图切换公开私有
    jQuery('.mplist .mpli .pt .toggle').live('click',function(evt){
      var dom = jQuery(evt.target);
      var map_id = dom.attr('data-map-id');
      jQuery.ajax({
        url     : '/mindmaps/'+map_id+'/do_private',
        type    : 'PUT',
        beforeSend : function(){
          dom.addClass('loading');
        },
        success : function(){
          dom.removeClass('loading').toggleClass('private').toggleClass('public');
        }
      })
    });

    //导入导图的表单
    jQuery('.import-mindmap .icon').live('click',function(){
      jQuery(".import-mindmap-form").toggle();
    });

    // 加载页面后，清空导图创建表单中的内容
    jQuery("form.feed-form-mev6 input.feed-content").attr("value","");
    // 给 创建导图按钮 注册 点击事件
    jQuery("form.feed-form-mev6 .create-mindmap").bind("click",function(evt){
      evt.preventDefault();
      evt.stopPropagation();

      var btn = jQuery("form.feed-form-mev6 .create-mindmap");
      var form = jQuery("form.feed-form-mev6");
      var mode = form.attr("data-mode");
      if(mode == "create_mindmap"){
        var title = jQuery("form.feed-form-mev6 input.feed-content")
        var title_str = title.attr("value");
        if(jQuery.string(title_str).blank() || title.hasClass('input-field-tip')){
          var current=title.css('background-color');
          title
            .animate({'backgroundColor': '#FFB49C'}, 100)
            .animate({'backgroundColor': current}, 100)
            .animate({'backgroundColor': '#FFB49C'}, 100)
            .animate({'backgroundColor': current}, 100);
          return;
        }
        jQuery("form.feed-form-mev6").submit();
        form.attr("data-mode","create_mindmap_executing");
        setTimeout(function(){
          jQuery("form.feed-form-mev6 #content").val('');
        },1);
      }else if(mode == "import_mindmap"){
        var href = btn.attr("data-href");
        window.location = href;
      }
    });
    // 给 导入导图的流程中 最后显示的缩略图 的关闭按钮 增加事件
    jQuery("form.feed-form-mev6 .close-import-mindmap-image").bind("click",function(evt){
      evt.preventDefault();
      evt.stopPropagation();
      var import_image_div = jQuery("form.feed-form-mev6 .import-mindmap-image");
      import_image_div.hide();
      jQuery("form.feed-form-mev6 input.feed-content").attr("value","");
      jQuery("form.feed-form-mev6").attr("data-mode","create_mindmap")
    });

    var scriptData = {
      'authenticity_token':pie.auth_token
    }
    scriptData[pie.session_key] = pie.session_value;

    jQuery('#file-upload-btn').uploadify({
      'uploader'  : '/javascripts/uploadify/uploadify.swf',
      'script'    : '/mindmaps/import_file',
      'cancelImg' : '/images/actions/cancel.png',
      'buttonImg' : '/images/actions/upload-mindmap-button.png',
      'width'     : 105,
      'height'    : 27,
      'wmode'     : 'transparent',
      'auto'      : true,
      'multi'     : false,
      'fileDataName' : 'file',
      'fileDesc'     : '导图文件 mm, mmap, xmind',
      'fileExt'      : '*.mm;*.mmap;*.xmind;',
      'sizeLimit'    : 4194304,// 4.megabytes
      'scriptData'   : scriptData,
      'onComplete'  : function(event, ID, fileObj, response, data) {
        var data_json = jQuery.parseJSON(response)
        //关闭 导入表单
        jQuery(".import-mindmap-form").hide();
        // 隐藏 解析错误的提示信息
        jQuery(".import-error").hide();
        // 添加正在读取的图标
        jQuery(".feed-form-mev6 .btns").addClass('loading')
        get_import_mindmap_image(data_json.qid)
      }
    });

    jQuery(".import-mindmap-form .close").live("click",function(){
      jQuery(".import-mindmap-form").hide();
    });

    jQuery(".import-error .close").live("click",function(){
      jQuery(".import-error").hide();
    });
    
    function get_import_mindmap_image(qid){
      jQuery.ajax({
        url:pie.pin_url_for('pin-user-auth')+"import_mindmap_queue?qid="+qid,
        dataType:"jsonp",
        jsonp:"import_mindmap_callback",
        success:function(data){
          var loaded = data["loaded"];
          var success = data["success"];

          if(!loaded){
            setTimeout(function(){
              get_import_mindmap_image(qid);
            },5000);
          }else if(success){
            import_success(data);
          }else{
            jQuery(".feed-form-mev6 .btns").removeClass('loading');
            jQuery(".import-error").show();
          }
        },
        error:function(data){
        }
      });
    }
    function create_loading_image_div(map_id,dom_id,size_param,updated_at,loading_src){
      pie.log(loading_src)
      return jQuery('<div id="'+dom_id+'" class="cache_mindmap_image" data-map-id="'+map_id+'" data-map-size="'+size_param+'" data-updated-at="'+updated_at+'" ><img class="loading" src="'+loading_src +'" /></div>')
    }

    function import_success(data){
      var mindmap_title = data["map_title"];
      var mindmap_id = data["map_id"];
      var loading_image_div_id = pie.randstr();
      var size = data["size"];
      var updated_at = data["updated_at"];
      var loading_src = data["loading_src"];
      var image_cache_url = data["image_cache_url"];

      // 读取图标 的时候 弹出显示导图缩略图，添加标题，后面按钮链接改成，进入并编辑
      jQuery(".feed-form-mev6 .feed-content").attr("value",mindmap_title);
      jQuery(".feed-form-mev6 .btns").removeClass('loading');

      var import_image_div = jQuery(".feed-form-mev6 .import-mindmap-image");

      var image_content = jQuery(".feed-form-mev6 .import-mindmap-image .image");
      var loading_image = create_loading_image_div(mindmap_id,loading_image_div_id ,size ,updated_at,loading_src)
      image_content.html(loading_image)
      var gmt = new GetMindmapImage(loading_image_div_id,image_cache_url);
      gmt.get_mindmap_image();
      import_image_div.show();

      jQuery(".feed-form-mev6").attr("data-mode","import_mindmap")
      jQuery(".feed-form-mev6 .create-mindmap").attr("data-href",pie.pin_url_for('pin-mev6')+"mindmaps/"+ mindmap_id+"/edit")
    }

  });

})();