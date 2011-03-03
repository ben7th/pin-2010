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
  $.fn.input_tips = function(str) {
    initial_target($(this),str);

    $(this)
      .blur(function(){
        if($(this).val()==''){
          initial_target($(this),str);
        }
      })
      .focus(function(){
        if($(this).hasClass('input-field-tip')){
          clear_target($(this));
        }
      });
  };

  function refresh_target(target,str){
    if(target.val() != str && target.hasClass('input-field-tip')){
      var color = target.attr('data-current-color');
      target.css('color',color);
      target.removeClass('input-field-tip');
    }
  }

  // 用于失焦时 use for focus
  function initial_target(target,str) {
    target.attr('data-current-color',target.css('color'));
    target.css('color','#999999');
    target.addClass('input-field-tip');
    target.val(str);
  }
  // 用于聚焦时 use for blur
  function clear_target( target ) {
    var color = target.attr('data-current-color');
    target.css('color',color);
    target.removeClass('input-field-tip');
    target.val('');
  }

  $(document).ready(function() {
    $('[data-input-tip]').each(function(){
      var d = $(this);
      d.input_tips(d.attr('data-input-tip'));
    });

    setInterval(function(){
      $('[data-input-tip]').each(function(){
        var d = $(this);
        refresh_target(d,d.attr('data-input-tip'));
      });
    },10);
  });
})(jQuery);