pie.mindmap.NodeImageEditor = Class.create({
	initialize: function(){
    this.image_event_loaded = false;
	},
	doEditImage:function(mindmap_node){
    var node = mindmap_node;
    this.editing_image_node = node;
		node.select();

    this._show_selector_box();
    this._init_form(node);
    this._bind_button_event();
	},
  _show_selector_box:function(){
    jQuery.facebox({div:'#imgselector'});
    this.i_url     = $$('#facebox #imgselector input.url')[0];
    this.i_width   = $$('#facebox #imgselector input.width')[0];
    this.i_height  = $$('#facebox #imgselector input.height')[0];
    this.i_preview = $$('#facebox #imgselector div.preview')[0];
    this.b_load    = $$('#facebox #imgselector a.load')[0];
    this.b_accept  = $$('#facebox #imgselector a.accept')[0];
//    setTimeout(function(){
//      if(!this.resizer){
//        this.resizer = new pie.Resizable(this.i_preview, {scale:"fixed",proxy:"dashed"});
//      }
//    }.bind(this),1)
  },

  _init_form:function(node){
		if(node.image.url){
      var nimg = node.image;

			this.i_url.value    = nimg.url;
			this.i_width.value  = nimg.width;
			this.i_height.value = nimg.height;
			this.i_preview.update(this._build_image(nimg));
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
    if(url.blank()){
      return;
    }
    //载入外部图片url
    var img = Builder.node("img",{
      'src':url
    });
    Event.observe(img,'load',function(){
      this.i_width.value  = img.width;
      this.i_height.value = img.height;
    }.bind(this));
    this.i_preview.update(img);
  },

  _do_accept:function(){
    var node = this.editing_image_node;

    if (node.image.el) {
      node.image.el.remove();
    }
    
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
      node.root.map.reRank();
    }.bind(this));

    node.nodebody.el.insert({before: node.nodeimg.el});
    var record = node.root.map.opFactory.getImageInstance(node);
    node.root.map._save(record);

    jQuery.facebox.close();
  },

	do_remove_image:function(node){
		if (node.image.el) {
			node.image.el.remove();
		}
		node.image={
			"url":null,
			"width":null,
			"height":null
		}
		Object.extend(node,node.el.getDimensions());
		var record = node.root.map.opFactory.getRemoveImageInstance(node);
		node.root.map._save(record);
		node.do_dirty();
		node.root.map.reRank();
	}
})


