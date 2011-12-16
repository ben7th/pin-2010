/**
 *   KK Form Input Tips ( jQuery )  v0.1b
 *
 *	 Author: Mrkelly
 *
 *	 MSN/Gtalk/Email: chepy.v@gmail.com
 *	 QQ: 23110388
 *   Twitter: @mrkelly
 *
 *	 Usage:
 		<input type="text" id="test_input" />

 		<script>
 			$(function(){
 				$('#test_input').input_tips( 'some text to display on it.' );
 			});
 		</script>
 *
 */
(function($) {
  $.fn.input_tips = function(tip_str) {
    var elm = $(this);

    //初始化
    initial_target(elm,tip_str);

    //focus和blur的事件绑定，不能以live来声明
    $(this)
      .focus(function(){
        clear_target(elm);
      })
      .blur(function(){
        show_target(elm);
      });
  };

  // 初始化
  function initial_target(input_elm,str) {
    var tip_elm = $('<div class="quiet j-input-tip">'+str+'</div>')
    tip_elm.css('position','absolute');
    tip_elm.css('font-size',input_elm.css('font-size'));

    var o = input_elm.offset();
    var left = o.left + parseInt(input_elm.css('padding-left')) + 2;
    var top = o.top + parseInt(input_elm.css('padding-top')) + 1;

    tip_elm.css('left',left).css('top',top);

    if(input_elm.val() != '') tip_elm.hide();

    tip_elm.mousedown(function(event){
      tip_elm.hide();
      setTimeout(function(){
        input_elm.focus();
      },1);
    })

    input_elm.after(tip_elm);
  }
  
  // 聚焦时，清除提示
  function clear_target(input_elm){
    var tip_elm = input_elm.next('.j-input-tip');
    tip_elm.hide();
  }

  // 失焦时，显示提示
  function show_target(input_elm){
    var tip_elm = input_elm.next('.j-input-tip');
    if(input_elm.val() == '') tip_elm.show();
  }

  //全页面的input tip初始化
  $(document).ready(function() {
    $('[data-input-tip]').each(function(){
      var d = $(this);
      d.input_tips(d.attr('data-input-tip'));
    });
  });
})(jQuery);

jQuery.fn.input = function(fn) {
	var $this = this;
	return fn
		?
			$this.bind({
				'input.input': function(event) {
					$this.unbind('keydown.input');
					fn.call(this, event);
				},
				'keydown.input': function(event) {
					fn.call(this, event);
				}
			})
		:
			$this.trigger('keydown.input');
};


pie.load(function(){
  jQuery.fn.pie_j_tips = function() {
    var elm = jQuery(this);
    var jt_label_elm = elm.closest('.field').find('label');
    jt_label_elm.mousedown(function(){
      setTimeout(function(){
        elm.focus();
      },1);
    })

    //初始化
    j_tip_active(elm);

    //focus和blur的事件绑定，不能以live来声明
    elm
    .change(function(){
      j_tip_active(elm)
    })
    .input(function(){
      j_tip_active(elm)
    })
  };

  function j_tip_active(elm){
    var jt_label_elm = elm.closest('.field').find('label');
    var value = elm.val();

    if(jQuery.string(value).blank()){
      jt_label_elm.show();
    }else{
      jt_label_elm.hide();
    }
  }

  jQuery('.j-tip').each(function(){
    jQuery(this).pie_j_tips();
  })
})