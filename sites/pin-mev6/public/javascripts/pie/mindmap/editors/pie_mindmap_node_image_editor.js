pie.mindmap.NodeImageEditor = Class.create({
	initialize: function(mindmap){
    this.map = mindmap;

    this.upload_enlabed = false;

    //先解除此前可能已经过期的绑定 2011-7-21
    //导图某些情况下 如操作前进后退时 可能重新加载，必须如此处理
    jQuery(document).undelegate('.mindmap_node_image_editor');

    //选择图片
    jQuery(document).delegate('.page-mindmap-image-editor .image-list li .ic','click.mindmap_node_image_editor',function(){
      jQuery('.page-mindmap-image-editor .image-upload .image-list li').removeClass('selected');
      jQuery(this).closest('li').addClass('selected');
    });

    //删除图片
    jQuery(document).delegate('.page-mindmap-image-editor a.delete','click.mindmap_node_image_editor',function(){
      var elm = jQuery(this);
      var li_elm = elm.closest('li');
      var id = li_elm.attr('data-id');
      elm.confirm_dialog('确定要删除吗？',function(){
        // delete /image_attachments/:id
        jQuery.ajax({
          url : '/image_attachments/'+id,
          type : 'delete',
          success : function(){
            li_elm.fadeOut(200,function(){
              li_elm.remove();
            });
          }
        })
      });
    });

    var func = this;

    //取消
    jQuery(document).delegate('.page-mindmap-image-editor .cancel','click.mindmap_node_image_editor',function(){
      func.close();
    });

    //确定
    jQuery(document).delegate('.page-mindmap-image-editor .accept','click.mindmap_node_image_editor',function(){
      var node = func.node;

      var selected_li = jQuery('.page-mindmap-image-editor .image-list li.selected');
      
      if(selected_li.length == 0){
        var info_elm = jQuery('.page-mindmap-image-editor span.info');
        info_elm.html('请先选择图片').css('padding-left',20).fadeOut(2000,function(){
          info_elm.html('').fadeIn(1);
        });
      }else{
        var size = jQuery('.page-mindmap-image-editor .image-size :checked').val();

        var img_attach_id = selected_li.attr('data-id');;
        var img_attach_url;
        var img_attach_width;
        var img_attach_height;

        if(size == 'full'){
          img_attach_url = selected_li.attr('data-url-full');
          img_attach_width = selected_li.attr('data-width-full');
          img_attach_height = selected_li.attr('data-height-full');
        }else{
          img_attach_url = selected_li.attr('data-url-thumb');
          img_attach_width = selected_li.attr('data-width-thumb');
          img_attach_height = selected_li.attr('data-height-thumb');
        }

        var image = {
          "attach_id" : img_attach_id,
          "url"       : img_attach_url,
          "width"     : img_attach_width,
          "height"    : img_attach_height,
          "size"      : size
        };

        node.set_image_and_save(image,size);
        func.close();
      }
    });
	},

  // 被菜单调用的方法
	do_edit_image:function(mindmap_node){
    this.node = mindmap_node;
		this.node.select();

    //显示图片上传对话框
    this._show_selector_box();
    if(!this.upload_enabled){
      this._enable_upload_btn();
    }
	},

  // 被菜单调用的方法
	do_remove_image:function(mindmap_node){
    mindmap_node.remove_image_and_save();
	},

  close:function(){
    jQuery('.page-mindmap-image-editor').hide();
    jQuery('.page-overlay').remove();
  },

  _show_selector_box:function(){
    var height = jQuery(window).height();
    var width = jQuery(window).width();
    var e_elm = jQuery('.page-mindmap-image-editor');

    e_elm.show()
      .css('left', (width - e_elm.outerWidth())/2 )
      .css('top', (height - e_elm.outerHeight())/2 )

    var overlay_elm = jQuery('<div class="page-overlay"></div>')
      .css('opacity',0.4)
      .css('height',height).css('width',width);
    jQuery('body').append(overlay_elm);
  },

  _enable_upload_btn:function(){
    this.upload_enabled = true;

    var scriptData = {
      'authenticity_token':pie.auth_token
    }
    scriptData[pie.session_key] = pie.session_value;

    jQuery('.page-mindmap-image-editor #page-upload-mindmap-img').uploadify({
        'uploader'     : '/uploadify/uploadify.swf',
        'script'       : '/image_attachments',
        'cancelImg'    : '/uploadify/cancel.png',
        'buttonImg'    : '/uploadify/upload_mindmap_image.png',
        'width'        : 66,
        'height'       : 21,
        'wmode'        : 'transparent',
        'auto'         : true,
        'multi'        : false,
        'fileDataName' : 'file',
        'fileDesc'     : '图片文件 png,gif,jpg',
        'fileExt'      : '*.png;*.gif;*.jpg;*.jpeg;',
        'sizeLimit'    : 4194304,// 4.megabytes
        'scriptData'   : scriptData,
        'queueID'      : 'page-mindmap-upload-queue',

        'onComplete'   : function(event, ID, fileObj, response, data){
          var li_elm = jQuery(response).find('.image-list li');
          jQuery('.page-mindmap-image-editor .image-list').prepend(li_elm).scrollTop(0);
          li_elm.hide().fadeIn();
        },
        'onError'     : function (event, ID, fileObj, errorObj) {
          setTimeout(function(){
            jQuery('.uploadifyError .percentage').html(' - 上传出错');
          },1);
        }
      }
    );
  }
})


