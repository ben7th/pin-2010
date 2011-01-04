pie.mindmap.NodeImageEditor = Class.create({
	initialize: function(mindmap){
    this.map = mindmap;
	},
	do_edit_image:function(mindmap_node){
    this.node = mindmap_node;
		this.node.select();

    this._show_selector_box();
	},
  _show_selector_box:function(){
    new Ajax.Request('/mindmaps/'+this.map.id+'/files/i_editor',{
      method:'GET'
      //回调在controller里
    })
  },

  _rails_controller_callback:function(){
    //这样不太dry，CV层逻辑有些混，暂时先如此
    this.i_url        = $$('#facebox .mindmap-image-editor input.url')[0];
    this.i_width      = $$('#facebox .mindmap-image-editor input.width')[0];
    this.i_height     = $$('#facebox .mindmap-image-editor input.height')[0];
    this.i_preview    = $$('#facebox .mindmap-image-editor div.preview')[0];
    this.b_load       = $$('#facebox .mindmap-image-editor a.load')[0];
    this.b_accept     = $$('#facebox .mindmap-image-editor a.accept')[0];

    this.image_upload = $$('#facebox .mindmap-image-editor div.image-upload')[0];

    this.page = 1;

    //2011.01.04
    //uploadify初始化某元素时，页面上不能有相同ID的元素，否则无法上传的。
    //这里动态创建
    var uploader = Builder.node('input',{
      'id'   : 'upload_mindmap_image',
      'type' : 'file',
      'name' : 'flle'
    });
    this.image_upload.down('.uploader').insert(uploader);
    jQuery('#facebox #upload_mindmap_image').uploadify(uploadify_options);

    this.preview_image(this.node.image);
    this._bind_button_event();
  },

  preview_image:function(img){
		if(img.url){
			this.i_url.value    = img.url;
			this.i_width.value  = img.width;
			this.i_height.value = img.height;
			this.i_preview.update(this._build_image(img));
		}else{
			this.i_url.value    = '';
			this.i_width.value  = '';
			this.i_height.value = '';
			this.i_preview.update('');
		}
  },

  _build_image:function(img){
    return $(Builder.node("img",{
      'src':img.url,
      'height':img.height,
      'width':img.width
    }))
  },

  _bind_button_event:function(){
    this.b_load.observe("click",this._do_load.bind(this));
    this.b_accept.observe("click",this._do_accept.bind(this));
  },

  _do_load:function(){
    var url = this.i_url.value;
    if(url.blank()){return;}
    //载入外部图片url
    var img = Builder.node("img",{'src':url});
    Event.observe(img,'load',function(){
      this.i_width.value  = img.width;
      this.i_height.value = img.height;
    }.bind(this));
    this.i_preview.update(img);
  },

  _do_accept:function(){
    var node = this.node;

    if (node.image.el) {node.image.el.remove();}
    
    node.image = {
      "url"   : this.i_url.value,
      "width" : this.i_width.value,
      "height": this.i_height.value
    }

    node.image.el = this._build_image(node.image)
    
    node.nodeimg = {
      el: $(Builder.node("div", {"class": "nodeimg"},node.image.el))
    }

    Event.observe(node.image.el,'load',function(){
      Object.extend(node,node.el.getDimensions());
      node.do_dirty();
      this.map.reRank();
    }.bind(this));

    node.nodebody.el.insert({before: node.nodeimg.el});
    var record = this.map.opFactory.getImageInstance(node);
    this.map._save(record);

    jQuery.facebox.close();
  },

	do_remove_image:function(node){
    try{
      //这个方法其实最好应该放在node上作为对象方法
      if (node.image.el) {node.image.el.remove();}
      node.image={
        "url":null,
        "width":null,
        "height":null
      }
      Object.extend(node,node.el.getDimensions());
      var record = this.map.opFactory.getRemoveImageInstance(node);
      this.map._save(record);
      node.do_dirty();
      this.map.reRank();
    }catch(e){alert(e)}
	},

  next_page:function(){
    var _p = this.page + 1;
    new Ajax.Request('/mindmaps/'+this.map.id+'/files',{
      parameters:'page='+_p,
      method:'GET',
      onSuccess:function(trans){
        var html = trans.responseText;
        this.image_upload.down('.image-page').update(html);
        this.page = _p;
      }.bind(this)
    })
  },
  prev_page:function(){
    if(this.page == 1) return;
    var _p = this.page - 1;
    new Ajax.Request('/mindmaps/'+this.map.id+'/files',{
      parameters:'page='+_p,
      method:'GET',
      onSuccess:function(trans){
        var html = trans.responseText;
        this.image_upload.down('.image-page').update(html);
        this.page = _p;
      }.bind(this)
    })
  }

//  _get_google_search_images:function(){
//    this.image_search = new google.search.ImageSearch();
//    this.image_search.setSearchCompleteCallback(this,this._build_google_search_images_dom);
//    this.image_search.execute(this.node.title);
//  },
//  _build_google_search_images_dom:function(){
//    this.image_search.results.each(function(hash){
//      //var url = hash.tbUrl.gsub('images.google.com','images.google.com.hk');
//      var li = $(Builder.node('li',{},
//        Builder.node('img',{
//          'src':hash.url
//        })
//      ));
//      this.glist.appendChild(li);
//    }.bind(this));
//  },
//  _init_google_search:function(){
//    this.glist     = $$('#facebox #imgselector ul.google-image-list')[0];
//    this.glist.update();
//    this._get_google_search_images();
//    setTimeout(function(){
//      if(!this.resizer){
//        this.resizer = new pie.Resizable(this.i_preview, {scale:"fixed",proxy:"dashed"});
//      }
//    }.bind(this),1)
//  }
})


