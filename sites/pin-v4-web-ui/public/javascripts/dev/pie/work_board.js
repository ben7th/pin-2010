/* 
 * pie.WorkBoard.show({
 *   width:300,
 *   height:300
 * })
 */

pie.WorkBoard = {
  template: '<div id="work_board" style="display:none;">\
               <div class="wb_wrap">\
                 <div class="wb_title">\
                   <a class="close">关闭</a>\
                 </div>\
                 <div class="wb_body">\
                    <a class="refurbish">刷新</a>\
                    <div class="wb_content"></div>\
                 </div>\
               </div>\
             </div>\
             ',
  settings: {
    width:300,
    height:300
  },
  show: function(settings){
    Object.extend(this.settings,settings)
    this._init()
    this._loading()

    this.work_board.setStyle({
      width: this.settings.width + "px",
      height: this.settings.height + "px"
    })

    var work_board = this.work_board
    var pageScroll = document.viewport.getScrollOffsets();
    work_board.setStyle({
      'top': pageScroll.top + (document.viewport.getHeight() / 10) + 'px',
      'left': document.viewport.getWidth() / 2 - (work_board.getWidth() / 2) + 'px'
    });
    this.work_board.appear({ 
      duration:0.5
    });
  },
  close:function(){
    this.work_board.fade({ 
      duration:0.5
    });
  },
  // 清除 work_board 中 除模板以外的内容
  _loading: function(){
    this.work_board.fire("dom:refurbish")
  },
  // 获得 work_board 元素
  _init: function(){
    if(this.work_board){
      return
    }
    new Insertion.Bottom($(document.body),this.template)
    this.work_board = $("work_board")
    // 使 标题可拖动
    new pie.WorkBoard.drag(this.work_board.down(".wb_title"))
    // 注册关闭事件
    this.work_board.down(".wb_title a.close").observe("click",function(){
      this.close()
    }.bind(this))
    // 刷新事件
    this.work_board.observe("dom:refurbish",function(){
      this.work_board.down(".wb_content").update("正在载入")
      new Ajax.Request("/users/" + this.settings.user_id +"/work_board", {
        method: 'get',
        onSuccess: function(transport) {
          this.work_board.down(".wb_content").update(transport.responseText)
        }.bind(this)
      });
    }.bind(this))
    this.work_board.down(".wb_body a.refurbish").observe("click",function(){
      this.work_board.fire("dom:refurbish")
    }.bind(this))
  }
}

pie.WorkBoard.drag = Class.create(pie.drag.Base,{
  onInit:function(){},
  beforeStart:function(){
    var work_board = this.el.up("#work_board")

    this.ileft = parseInt(work_board.getStyle("left")||0);
    this.itop = parseInt(work_board.getStyle("top")||0);
  },
  onDragging:function($super){
    var work_board = this.el.up("#work_board")
    var width = parseInt(work_board.getStyle("width"));
    var height = parseInt(work_board.getStyle("height"));

    var newLeft = this.ileft + this.distanceX;
    var newTop = this.itop + this.distanceY;

    var pageScroll = document.viewport.getScrollOffsets();

    var mintop = pageScroll.top
    var maxtop = pageScroll.top + document.viewport.getHeight() - height
    var minleft = pageScroll.left
    var maxleft = pageScroll.left + document.viewport.getWidth() - width

    if(newLeft < minleft){
      newLeft = minleft
    }
    if(newLeft > maxleft){
      newLeft = maxleft
    }

    if(newTop < mintop){
      newTop = mintop
    }
    if(newTop > maxtop){
      newTop = maxtop
    }

    work_board.setStyle({
      "top":newTop+"px",
      "left":newLeft+"px"
    })
  },
  beforeFinish:function(){}
});