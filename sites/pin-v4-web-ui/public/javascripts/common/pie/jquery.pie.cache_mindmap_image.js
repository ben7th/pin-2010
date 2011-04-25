pie.load(function(){
  jQuery(".cached-mindmap-image").each(function(){
    var elm = jQuery(this);
    var elm_id = elm.attr('id');
    var request_url = pie.pin_url_for("pin-mindmap-image-cache");
    new GetMindmapImage(elm_id, request_url).get_mindmap_image();
  });
});

/*
 * 个人主页导图缩略图片的读取
 * 目前使用prototype编写，将来看情况改为纯jquery实现
 */
GetMindmapImage = Class.create({
  initialize : function(dom_id,request_url){
    this.dom_id = dom_id;
    this.dom = jQuery("#"+dom_id);
    this.request_url = request_url;
    this.mindmap_id = this.dom.attr("data-map-id");
    this.data_loaded_src = this.dom.attr("data-loaded-src");

    this.size       = this.dom.attr("data-map-size");
    this.width      = this.size.split("x")[0];
    this.height     = this.size.split("x")[1];

    this.updated_at = this.dom.attr("data-updated-at");
  },

  _loaded_image_dom_str:function(image_src){
    return "<img class='loaded_image' style='display:none' src="+image_src+"/>";
  },

  _image_fadein:function(dom){
    dom.find(".loading").remove();
    dom.find(".loaded_image").fadeIn('slow');
  },

  show_image : function(jsonp_data){
    var dom_id     = jsonp_data["dom_id"];
    var image_src  = jsonp_data["image_src"];

    var target_dom = jQuery("#"+dom_id);
    target_dom.append(this._loaded_image_dom_str(image_src));
    target_dom.find(".loaded_image").bind("load",function(){
      this._image_fadein(target_dom);
    }.bind(this))
  },

  get_map_info_by_jsonp : function(){
    var url = this.request_url+this.mindmap_id+".json?size="+this.size+"&domid="+this.dom_id;
    jQuery.ajax({
      url:url,
      dataType:"jsonp",
      jsonp:"mindmap_image_cache_callback",
      success:function(data){
        var loaded = data["loaded"];
        if(loaded){
          this.show_image(data);
          return;
        }
        setTimeout(this.get_mindmap_image.bind(this),5000);
      }.bind(this),
      error:function(data){
      }
    });
  },

  //尝试获取导图图片
  get_mindmap_image : function(){
    if(this.data_loaded_src == null || this.data_loaded_src.blank()){
      this.get_map_info_by_jsonp();
    }else{
      this.show_image({"dom_id":this.dom_id,"image_src":this.data_loaded_src});
    }
  }

});