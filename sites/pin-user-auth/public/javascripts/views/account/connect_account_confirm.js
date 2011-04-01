pie.load(function(){
  jQuery('.connect-has-reged a').live('click',function(){
    jQuery('.connect-confirm-btns').fadeOut('fast',function(){
      jQuery('.connect-link-form').fadeIn('fast');
    });
  });

  jQuery('.connect-link-form .a-suanle').live('click',function(){
    jQuery('.connect-link-form').fadeOut('fast',function(){
      jQuery('.connect-confirm-btns').fadeIn('fast');
    });
  })
})


