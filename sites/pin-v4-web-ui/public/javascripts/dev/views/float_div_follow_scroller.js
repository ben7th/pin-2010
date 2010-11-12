// 随窗体滚动的操作层
FloatDivFollowScroller = Class.create({
  initialize:function(el){
    this.el = el;

    new PeriodicalExecuter(function(pe) {
      this.move_div_follow_scroll();
    }.bind(this), 0.001);
  },

  // 根据滚动调整div的位置
  move_div_follow_scroll:function(){
    this.el.style.top = document.documentElement.scrollTop + "px";
  }

});


