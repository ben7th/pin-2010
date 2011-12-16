Feeling = Class.create({
  initialize: function(dom){
    this.options = dom.select("div.option")
    this.feel = dom.readAttribute("data-feel")
    this.btns = dom.select("div.option a.btn")
    // 初始化 btns 的内容
    // btn count
    // btn title
    this.init_btns()
    // 根据 count 替换 btn 中 innerHTML
    this.set_btn_innerHTML()
    // 给btn 注册事件
    this.add_event_to_btns()
    // 设置this.feel 对应的按钮的css
    this.set_feel_btn_style()
  },
  set_feel_btn_style: function(){
    this.btns.each(function(btn){
      btn.removeClassName("select")
    })
    if(this.feel !== ""){
      var feel_btn = this.get_btn_by_feel(this.feel)
      feel_btn.addClassName("select")
    }
  },
  set_btn_innerHTML: function(){
    this.btns.each(function(btn){
      btn.innerHTML = btn.title + "("+ btn.count +")"
    }.bind(this))
  },
  set_btn_count: function(btn){
    btn.count = btn.count + 1
    if(this.feel !== ""){
      var feel_btn = this.get_btn_by_feel(this.feel)
      feel_btn.count = feel_btn.count - 1
    }
  },
  init_btns: function(){
    this.btns.each(function(btn){
      btn.title = btn.readAttribute("data-title")
      btn.count = parseInt(btn.readAttribute("data-count"))
      btn.url = btn.readAttribute("data-url")
      btn.method = btn.readAttribute("data-method")
      btn.feel = btn.readAttribute("data-feel")
    }.bind(this))
  },
  get_btn_by_feel: function(feel){
    var feel_btn = null
    this.btns.each(function(btn){
      if(btn.feel === feel){
        feel_btn = btn
      }
    })
    return feel_btn
  },
  add_event_to_btns: function(){
    this.btns.each(function(btn){
      btn.observe("click",function(){
        if(this.feel === btn.feel){
          return
        }
        new Ajax.Request(btn.url,{
          evalJS: false,
          method: btn.method,
          onSuccess: function(transport){
            var btns = this.btns.without(btn)
            // 设置按钮的 count
            this.set_btn_count(btn)
            this.set_btn_innerHTML()
            this.feel = btn.feel
            this.set_feel_btn_style()
          }.bind(this)
        })
      }.bind(this))
    }.bind(this))
  }
});
pie.load(function(){
  $$(".feeling").each(function(dom){
    new Feeling(dom)
  })
});