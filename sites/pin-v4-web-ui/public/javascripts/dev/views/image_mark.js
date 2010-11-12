Element.addMethods({
  observe_once: function(element,type,fun){
    var once_fun = function(){
      fun()
      element.stopObserving(type,once_fun)
    }
    element.observe(type,once_fun)
  }
});
/*
 * 编辑模式
 * 给画板 注册创建评注事件
 * self_mark 全部显示
 * ohther_mark 全部隐藏
 * all_mark 全部清除查看事件
 * self_mark 注册可编辑事件
 *
 * 阅读模式
 * 给画板 取消注册评注事件
 * all_mark 全部隐藏
 * all_mark 全部注册查看事件
 * self_mark 全部取消可编辑事件
 *
 */
ImageMarkBox = Class.create({
  initialize: function(image_mark){
    this.box = image_mark
    this.image_panel = image_mark.down("div.image_panel");
    this.image = image_mark.down("img.image");
    this.image.id = randstr()
    this.add_remark_btn = image_mark.down("a.add_remark_btn");
    this.self_mark_div = this.image_panel.down("div.self_mark")
    this.form_panel = image_mark.down("div.form")
    this.mark_tag_list = image_mark.down("div.mark_tag_list")
    this.create_mark_url = this.form_panel.down('form').action
    this.create_mark_method = this.form_panel.down('form').method
    this.init_add_remark_btn();
    this.init_read_mode();
    this.init_form();
    // 给标注列表初始化 鼠标经过显示标语事件
    this.init_read_image_mark_event_for_mark_tag_list();
    // 给所有标记块初始化 鼠标经过显示标语事件
    this.init_read_image_mark_event_for_all_mark()
  },
  add_image_cropper_ui: function(){
    this.image_cropper_ui = new Cropper.Img(this.image.id,{
      minWidth:30,
      minHeight:30,
      onEndCrop:function(evt,areaCoords,wh){
        var element = evt.element()
        if(!element.up("div.form")){
          var left = areaCoords["x1"]
          var top = areaCoords["y1"]
          var width = wh["width"]
          var height = wh["height"]
          this.event_create_image_mark(left,top,width,height)
        }
      }.bind(this),
      changeArea:function(areaCoords,wh){
        this.form_panel.addClassName("hide")
      }.bind(this)
    })
  },
  remove_image_cropper_ui:function(){
    if(this.image_cropper_ui){
      this.image_cropper_ui.remove()
    }
  },
  // ---------------------初始化方法开始---------------------------------
  init_add_remark_btn: function(){
    this.add_remark_btn.observe('click',function(){
      this.init_edit_mode();
    }.bind(this))
  },
  // 开启阅读模式
  init_read_mode: function(){
    if(this.mode !== ImageMarkBox.MODE.READ){
      this.image_panel.removeClassName("edit")
      this.image_panel.addClassName("read")
      this.mark_tag_list.removeClassName("hide")
      // 让全部评注块透明
      this.hyaline_all_marks();
      // 取消掉 未提交的编辑或创建 （如果有）
      this.cancel_create_image_mark()
      this.box.down(".edit_mode_tips").addClassName('hide')
      this.remove_image_cropper_ui()
    }
    this.mode = ImageMarkBox.MODE.READ
  },
  // 开启编辑模式
  init_edit_mode: function(){
    if(this.mode !== ImageMarkBox.MODE.EDIT){
      this.image_panel.removeClassName("read")
      this.image_panel.addClassName("edit")
      this.mark_tag_list.addClassName("hide")
      // 隐藏所有评注
      this.hidden_all_marks();
      this.box.down(".edit_mode_tips").removeClassName('hide')
      this.add_image_cropper_ui()
    }
    this.mode = ImageMarkBox.MODE.EDIT
  },
  // 给所有标记注册 显示标语事件
  init_read_image_mark_event_for_all_mark: function(){
    this.all_marks().each(function(mark){
      this.init_read_image_mark_event_for_mark(mark)
    }.bind(this))
  },
  // 给 mark 注册查看标语事件
  init_read_image_mark_event_for_mark: function(mark){
    mark.observe("mouseout",function(evt){
      // 编辑模式下没有响应
      if(this.mode === ImageMarkBox.MODE.EDIT){
        return
      }
      this.event_hyaline_mark(evt)
    }.bind(this))
    mark.observe("mouseover",function(evt){
      // 编辑模式下没有响应
      if(this.mode === ImageMarkBox.MODE.EDIT){
        return
      }
      this.event_show_mark(evt)
    }.bind(this))
  },
  // 给图片旁边的标注导航注册查看事件
  init_read_image_mark_event_for_mark_tag_list: function(){
    this.mark_tag_list.select("li").each(function(li){
      this.init_read_image_mark_event_for_mark_tag_li(li)
    }.bind(this))
  },
  // 给 tag li 注册事件
  init_read_image_mark_event_for_mark_tag_li: function(li){
    var id = li.id.match(/remark_image_mark_([0-9]*)/)[1]
    var mark = this.image_panel.down("#mark_" + id)
    li.observe('mouseover',function(){
      this.show_mark_div_and_mark_content_div(mark)
    }.bind(this));
    li.observe('mouseout',function(){
      this.hyaline_mark_div_and_mark_content_div(mark)
    }.bind(this))
  },
  // 给 评注表单的按钮增加事件
  init_form: function(){
    $('submit_mark').observe('click',function(){
      var form = $('submit_mark').form
      if(form.down("textarea[name='image_mark[content]']").value === ""){
        alert("请输入评注")
        return
      }
      new Ajax.Request(this.submit_url,{
        evalJS: false,
        method: this.submit_method,
        parameters: Form.serialize(form),
        onSuccess: function(transport){
          this.create_mark_success(transport)
          this.form_status = ImageMarkBox.FORM_STATUS.NONE
          this.init_read_mode()
        }.bind(this)
      });
    }.bind(this));
    $('cancel_mark').observe('click',function(){
      this.cancel_create_image_mark()
      this.init_read_mode()
    }.bind(this));
  },
  // 取消编辑或创建
  cancel_create_image_mark: function(){
    if(this.form_status === ImageMarkBox.FORM_STATUS.CREATE){
      this.mark_panel.remove();
      this.mark_content_panel.remove();
    }
    delete this.mark_panel
    delete this.mark_content_panel
    this.hidden_form_panel()
    this.form_status = ImageMarkBox.FORM_STATUS.NONE
  },
  // 评注创建成功时运行
  create_mark_success:function(transport){
    eval(transport.responseText)
    // 隐藏表单
    this.hidden_form_panel();
    // 给 评注块 注册查看事件
    this.init_read_image_mark_event_for_mark(this.mark_panel)
    // 给 tag 注册事件
    var li = this.mark_tag_list.select("li").last()
    this.init_read_image_mark_event_for_mark_tag_li(li)
    // 删除 this.mark_panel 的引用
    delete this.mark_panel
    // 删除 this.mark_content_panel 的引用
    delete this.mark_content_panel
    alert("增加评注成功，请继续评注")
  },
  // ---------------------初始化方法结束---------------------------------
  // --------------------显示或隐藏标注块相关方法开始------------------------
  // 自己的评注块
  self_marks:function(){
    return this.image_panel.select("div.self_mark div.mark")
  },
  // 别人的评注块
  ohters_marks:function(){
    return this.image_panel.select("div.others_mark div.mark")
  },
  // 所有人的评注块
  all_marks:function(){
    return this.image_panel.select("div.mark")
  },
  // 获得 mark 的 内容 dom
  get_mark_content:function(mark){
    return $(mark.id + "_content")
  },
  // 根据 mark 获得 mark 的 模型 id
  get_mark_id:function(mark){
    return mark.id.match(/mark_([0-9]*)/)[1]
  },
  // 让所有评注透明
  hyaline_all_marks:function(){
    this.all_marks().each(function(mark){
      this.hyaline_mark_div(mark)
    }.bind(this))
  },
  // 显示自己的评注
  show_self_mark:function(){
    this.self_marks().each(function(mark){
      this.show_mark_div(mark)
    }.bind(this))
  },
  // 隐藏全部评注块
  hidden_all_marks: function(){
    this.all_marks().each(function(mark){
      this.hidden_mark_div(mark)
    }.bind(this))
  },
  // 隐藏别人的评注
  hidden_others_mark: function(){
    this.ohters_marks().each(function(mark){
      this.hidden_mark_div(mark)
    }.bind(this))
  },
  // --------------------显示或隐藏标注块相关方法结束------------------------
  
  // -------------------阅读标注事件相关开始------------------------
  event_show_mark:function(evt){
    var mark = evt.element()
    var div = mark.up("div.mark")
    if(div){
      mark = div
      }
    this.show_mark_div_and_mark_content_div(mark)
    evt.stop()
  },
  show_mark_div_and_mark_content_div: function(mark){
    this.show_mark_div(mark)
    this.show_mark_content_by_mark(mark)
  },
  show_mark_content_by_mark:function(mark){
    var left = parseFloat(mark.getStyle('left'))
    var top = parseFloat(mark.getStyle('top'))
    var width = parseFloat(mark.getStyle('width'))
    var height = parseFloat(mark.getStyle('height'))
    var mark_content = this.get_mark_content(mark)
    mark_content.removeClassName("hide")
    mark_content.setStyle({
      "left":left + "px",
      "top":top + height + 5 + "px"
    })
  },
  event_hyaline_mark:function(evt){
    var mark = evt.element()
    var div = mark.up("div.mark")
    if(div){
      mark = div
      }
    this.hyaline_mark_div_and_mark_content_div(mark)
    evt.stop()
  },
  hyaline_mark_div_and_mark_content_div: function(mark){
    this.hyaline_mark_div(mark)
    this.hidden_mark_content_by_mark(mark)
  },
  hidden_mark_content_by_mark: function(mark){
    var mark_content = this.get_mark_content(mark)
    mark_content.addClassName("hide")
  },
  // 显示 mark
  show_mark_div:function(mark){
    mark.addClassName("s")
    mark.removeClassName("hide")
    mark.removeClassName("hl")
  },
  // 隐藏 mark
  hidden_mark_div:function(mark){
    mark.addClassName("hide")
    mark.removeClassName("s")
    mark.removeClassName("hl")
  },
  // 让 mark 透明
  hyaline_mark_div:function(mark){
    mark.addClassName("hl")
    mark.removeClassName("s")
    mark.removeClassName("hide")
  },
  // -------------------阅读标注事件相关结束------------------------
  // -------------------创建或编辑标注事件相关开始------------------------
  // ele left =>  ele.viewportOffset()[0]
  // ele top => ele.viewportOffset()[1]
  // 画板评注事件
  event_create_image_mark:function(left,top,width,height){
    // 取消掉 未提交的编辑或创建 （如果有）
    this.cancel_create_image_mark()
    // 创建 一个新的 mark
    if(!this.mark_panel){
      this.create_mark_panel_and_coment(left,top,width,height)
    }
    this.change_mark_panel_position(left,top,width,height)
    // 根据 mark 的位置 显示 from 表单
    this.show_form_panel_by_mark_panel()
    // 更新表单的值
    this.syn_form_panel_input_value_by_mark_panel()
    // 更新表单提交的 url 和 method
    this.submit_url = this.create_mark_url
    this.submit_method = this.create_mark_method
    // 更新 form 状态
    this.form_status = ImageMarkBox.FORM_STATUS.CREATE
  },
  change_mark_panel_position: function(left,top,width,height){
    this.mark_panel.setStyle({
      "left":left + "px",
      "top":top + "px",
      "width":width + "px",
      "height":height + "px"
    })
  },
  //
  create_mark_panel_and_coment:function(left,top,width,height){
    var mark_panel_id = "mark_" + randstr()
    var mark_content_panel_id = mark_panel_id + "_content"
    this.mark_panel = Builder.node("div",{
      "id":mark_panel_id,
      "class":"mark hide",
      "style":"left:"+ left +"px;top:"+ top +"px;width:" + width + "px;height:" + height + "px;"
    },Builder.node("div"))
    //    this.show_mark_div(this.mark_panel)
    this.mark_content_panel = Builder.node("div",{
      "id": mark_content_panel_id,
      "class":"mark_content hide"
    })
    new Insertion.Bottom(this.self_mark_div,this.mark_panel)
    new Insertion.Bottom(this.self_mark_div,this.mark_content_panel)
  },
  // 隐藏表单
  hidden_form_panel: function(){
    this.form_panel.addClassName("hide")
    this.form_panel.down("input[name='image_mark[left]']").value = null
    this.form_panel.down("input[name='image_mark[top]']").value = null
    this.form_panel.down("input[name='image_mark[width]']").value = null
    this.form_panel.down("input[name='image_mark[height]']").value = null
    this.form_panel.down("textarea[name='image_mark[content]']").value = null
  },
  // 根据 编辑块 的位置显示 表单
  show_form_panel_by_mark_panel: function(){
    var left = parseFloat(this.mark_panel.getStyle("left"))
    var top = parseFloat(this.mark_panel.getStyle("top"))
    var width = parseFloat(this.mark_panel.getStyle("width"))
    var height = parseFloat(this.mark_panel.getStyle("height"))
    this.form_panel.removeClassName("hide")
    this.form_panel.setStyle({
      left:left + width + 10 +"px",
      top:top + "px",
      "zIndex":201
    })
  },
  // 根据 编辑快的位置和 编辑块的内容 更新表单的字段
  syn_form_panel_input_value_by_mark_panel:function(){
    var left = parseFloat(this.mark_panel.getStyle("left"))
    var top = parseFloat(this.mark_panel.getStyle("top"))
    var width = parseFloat(this.mark_panel.getStyle("width"))
    var height = parseFloat(this.mark_panel.getStyle("height"))
    this.form_panel.down("input[name='image_mark[left]']").value = left
    this.form_panel.down("input[name='image_mark[top]']").value = top
    this.form_panel.down("input[name='image_mark[width]']").value = width
    this.form_panel.down("input[name='image_mark[height]']").value = height
  }
// -------------------创建或编辑标注事件相关结束------------------------
});

ImageMarkBox.MODE = {
  READ: "read",
  EDIT: "edit"
};
ImageMarkBox.FORM_STATUS = {
  CREATE: "create",
  NONE: "none"
}

function randstr(){
  var length = 8;
  var base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  var size = base.length
  var re = '' + base[rand_int(size-10)]
  for(var i=0; i<length-1; i++){
    re = re + base[rand_int(size)]
  }
  return re
};

// 0 --- (i-1)
function rand_int(i){
  return Math.floor(Math.random()*i)
};
