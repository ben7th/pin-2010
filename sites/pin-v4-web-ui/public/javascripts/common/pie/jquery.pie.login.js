pie.load(function(){
  //登录表单按钮提交
  jQuery(document).delegate('.login-wrapper .login-form a.login-submit','click',function(){
    var elm = jQuery(this);
    elm.closest('form').submit();
  });

  //登录表单回车提交
  jQuery(document).delegate('.login-wrapper .login-form input.text','keydown',function(event){
    if(event.keyCode == 13){
      jQuery(this).closest('form').submit();
    }
  })
})

pie.load(function(){
  //注册表单按钮提交
  jQuery(document).delegate('.signup-wrapper .signup-form a.signup-submit','click',function(){
    var elm = jQuery(this);
    elm.closest('form').submit();
  });

  //登录表单回车提交
  jQuery(document).delegate('.signup-wrapper .signup-form input.text','keydown',function(event){
    if(event.keyCode == 13){
      jQuery(this).closest('form').submit();
    }
  })
})

pie.load(function(){
  //注册表单按钮提交
  jQuery(document).delegate('.reset-password-wrapper form a.reset-password-submit','click',function(){
    var elm = jQuery(this);
    elm.closest('form').submit();
  });

  //登录表单回车提交
  jQuery(document).delegate('.reset-password-wrapper form input.text','keydown',function(event){
    if(event.keyCode == 13){
      jQuery(this).closest('form').submit();
    }
  })
})

pie.load(function(){
  //各种表单按钮提交
  jQuery(document).delegate('.aj-submit-form a.a-link-submit','click',function(){
    var elm = jQuery(this);
    elm.closest('form').submit();
  });

  //各种表单回车提交
  jQuery(document).delegate('.aj-submit-form input.text','keydown',function(event){
    if(event.keyCode == 13){
      jQuery(this).closest('form').submit();
    }
  })
})

