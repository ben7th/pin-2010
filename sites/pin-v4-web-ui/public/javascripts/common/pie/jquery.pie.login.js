pie.load(function(){
  var login_prefix = '.page-anonymous-wrapper .login-box .login-form ';

  //登录表单按钮提交
  jQuery(document).delegate(login_prefix + 'a.login-submit','click',function(){
    form_submit(jQuery(this).closest('form'));
  });

  //登录表单回车提交
  jQuery(document).delegate(login_prefix + 'input.text','keydown',function(event){
    if(event.keyCode == 13){
      form_submit(jQuery(this).closest('form'));
    }
  })

  // -----------------------

  var signup_prefix = '.page-anonymous-wrapper .signup-box .signup-form '

  //注册表单按钮提交
  jQuery(document).delegate(signup_prefix + 'a.signup-submit','click',function(){
    form_submit(jQuery(this).closest('form'));
  });

  //登录表单回车提交
  jQuery(document).delegate(signup_prefix + 'input.text','keydown',function(event){
    if(event.keyCode == 13){
      form_submit(jQuery(this).closest('form'));
    }
  })

  // --------------

  var password_prefix = '.page-anonymous-wrapper .reset-password-box form '

  //重置密码表单提交
  jQuery(document).delegate(password_prefix + 'a.reset-password-submit','click',function(){
    form_submit(jQuery(this).closest('form'));
  });

  //重置密码表单回车提交
  jQuery(document).delegate(password_prefix + 'input.text','keydown',function(event){
    if(event.keyCode == 13){
      form_submit(jQuery(this).closest('form'));
    }
  })

  var form_submit = function(form_elm){
    var can_submit = true;

    //必填字段 凡是有classname包含need的都是必填
    form_elm.find('.field .need').each(function(){
      var elm = jQuery(this);
      if(jQuery.string(elm.val()).blank()){
        can_submit = false;
        pie.inputflashdark(elm);
      }
    });

    form_elm.find('.field .need-light').each(function(){
      var elm = jQuery(this);
      if(jQuery.string(elm.val()).blank()){
        can_submit = false;
        pie.inputflash(elm);
      }
    });

    if(can_submit){
      form_elm.submit();
    }
  }
  
  //各种表单按钮提交
  jQuery(document).delegate('.aj-submit-form a.a-link-submit','click',function(){
    var elm = jQuery(this);
    if(elm.hasClass('disabled')){
      return;
    }else{
      form_submit(jQuery(this).closest('form'));
    }
  });

  //各种表单回车提交
  jQuery(document).delegate('.aj-submit-form input.text','keydown',function(event){
    if(event.keyCode == 13){
      form_submit(jQuery(this).closest('form'));
    }
  })
})

