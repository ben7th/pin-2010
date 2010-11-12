TabBox = Class.create({
  initialize: function (box){
    this.box = box;
    this.btns = box.select("a.btn");
    this.items = box.select("div.item");
    this.btns.each(function(a){
      a.observe("click",function(evt){
        this.show_item(a)
      }.bind(this));
    }.bind(this));
  },
  show_item: function(a){
    this.btns.each(function(i){
      i.removeClassName("active")
    });
    this.items.each(function(i){
      i.addClassName("hide")
    });
    a.addClassName("active")
    this.items[this.btns.indexOf(a)].removeClassName("hide")
  }
});

ToggleBox = Class.create({
  initialize: function(box){
    this.toggle_box = box.down("div.toggle_box");
    this.show_btn = box.down("a.show_btn");
    this.hidden_btn = box.down("a.hidden_btn");
    if(this.show_btn && this.hidden_btn && this.toggle_box){
      this.show_btn.observe("click",function(){
        this.toggle_box.removeClassName("hide")
        this.show_btn.addClassName("hide")
      }.bind(this));
      this.hidden_btn.observe("click",function(){
        this.show_btn.removeClassName("hide")
        this.toggle_box.addClassName("hide")
      }.bind(this));
    }
  }
});
pie.load(function(){
  $$('div.toggle').each(function(div){
    new ToggleBox(div)
  })
})


VideoToggleBox = Class.create({
  initialize: function(box){
    this.toggle_box = box.down("div.toggle_box");
    this.show_btn = box.down("a.show_btn");
    this.video_img = box.down("div.video_img")
    this.hidden_btn = box.down("a.hidden_btn");
    this.video_div = box.down("div.video")

    this.show_btn.observe("click",function(){
      var url = this.video_div.readAttribute("data-url")
      this.video_div.innerHTML = this.create_video_html(url)
      this.toggle_box.removeClassName("hide")
      this.video_img.addClassName("hide")
    }.bind(this));
    this.hidden_btn.observe("click",function(){
      this.video_div.innerHTML = ""
      this.toggle_box.addClassName("hide")
      this.video_img.removeClassName("hide")
    }.bind(this))
  },
  create_video_html:function(url){
    object_html = ""
    object_html += '<object height="360" width="440" type="application/x-shockwave-flash" data="'+ url +'">'
    object_html += '  <param name="quality" value="high" />'
    object_html += '  <param name="allowScriptAccess" value="always" />'
    object_html += '  <param name="wmode" value="transparent" />'
    object_html += '  <param name="allowFullscreen" value="true" />'
    object_html += '  <param name="flashvars" value="autostart=true&isAutoPlay=true" />'
    object_html += '  <param name="movie" value="'+url+'" />'
    object_html += '</object>'
    return object_html
  }
});

pie.load(function(){
  $$('div.video_toggle').each(function(div){
    new VideoToggleBox(div)
  })
});


CheckToggleBox = Class.create({
  initialize:function(div){
    this.btn = div.down("div.check_btn").down("input[type='checkbox']")
    this.area = div.down("div.check_area")
    if(this.btn && this.area){
      this.init_btn()
    }
  },
  init_btn:function(){
    this.btn.observe("click",function(){
      var check = this.btn.checked
      if(check == true){
        this.area.removeClassName("hide")
      }else if(check == false){
        this.area.addClassName("hide")
      //        this.area.select("input").each(function(input){
      //          input.checked = false
      //        })
      }
    }.bind(this))
  }
});
pie.load(function(){
  $$('div.check_toggle').each(function(div){
    new CheckToggleBox(div)
  })
});