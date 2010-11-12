(function(){
  pie.TextareaAdaptHeight = function(a){
    var line_height = 18
    // 获得行数
    var lines_count = 1

    var match = a.readAttribute("rel").match(/adapt\[(.*)\]/)
    if(match){
      lines_count = match[1]
    }

    // 根据行数获得高度
    var height = lines_count * line_height
    a.defaultHeight = height

    // 初始化 textarea 样式
    a.setStyle({
      lineHeight: line_height + "px",
      height: height + "px"
    })

    // 增加一个 value_change 事件
    a.observe("dom:value_change",function(){
      var virtual_textarea = get_virtual_textarea();
      virtual_textarea.value = a.value;
      var snapHeight = Math.max(virtual_textarea.scrollHeight, a.defaultHeight);
      a.setStyle({height: snapHeight + "px"});
    })

    // 获取焦点 注册 时间监听器
    $(a).observe("focus",function(){
      destroy_timer();
      new_timer(a);
    });

    // 失去焦点，销毁监听器
    $(a).observe("blur",function(){
      destroy_timer();
    });
    // 清除 firefox 的 历史记录
    a.value = ""
  }
  
  function new_timer(textarea){
    pie.TextareaAdaptHeight.Executer = new PeriodicalExecuter(function(){
      textarea.fire("dom:value_change")
    },0.01);
  }
  
  function destroy_timer(){
    if(pie.TextareaAdaptHeight.Executer){
      pie.TextareaAdaptHeight.Executer.stop();
    }
  }

  function get_virtual_textarea(){
    var textarea = $("virtual_textarea")
    if(!textarea){
      textarea = Builder.node("textarea",{id:"virtual_textarea"})
      $(document.body).insert(textarea);
    }
    return textarea;
  }
})();

pie.TextareaAdaptHeight.init = function(){
  $$('textarea[rel*=adapt]').each(function(a){
    if(a.hasClassName("adapt-packed")) return
    a.addClassName("adapt-packed")
    pie.TextareaAdaptHeight(a)
  })
};

pie.load(function() {
  pie.TextareaAdaptHeight.init()
});