pie.UserAutoCompleteModule = {
  initialize:function(inputer,options){
    this.options = options || {};
    if(this.options.keep_value){
      this.inputer = jQuery(inputer);
    }else{
      this.inputer = jQuery(inputer).val('');
    }
    this.url = '/users/autocomplete'
    this.init();

    this._enable_ac();
  },
  init:function(){},
  _enable_ac:function(){
    this.inputer.autocomplete(this.url,{
      formatItem: function(data, index, total) {
        var json = jQuery.parseJSON(data[0]);
        var str =
          '<div class="avatar">'+
            '<img class="logo tiny" src="'+json.avatar+'" />'+
          '</div>'+
          '<div class="data">'+
            '<div >'+json.name+'</div>'+
            '<div class="quiet">'+json.email+'</div>'+
          '</div>'

        return str;
      },
      formatMatch: function(data, i, total) {
        var json = jQuery.parseJSON(data[0]);
        return json.name + "," + json.email;
      },
      formatResult: function(data) {
        var json = jQuery.parseJSON(data[0]);
        return json.email;
      }
    }).result(function(event, data) {
      this.result(event,data);
    }.bind(this));
  }
}

pie.ContactAutoComplete = Class.create(pie.UserAutoCompleteModule,{
  result:function(){
    this.add_member_submit();
  },
  add_member_submit:function(){
    jQuery('.add-member-info').html('正在处理...');
    var pars = this.inputer.serialize();
    jQuery.ajax({
      url  : '/contacts',
      type : 'POST',
      data : pars,
      dataType : 'text',
      success : function(res){
        jQuery(".add-member-info").html("");
        jQuery("#contact_email").val("");
        jQuery('.no-member').hide();

        var li_elm = jQuery(res).find('li').hide();
        jQuery('#mplist_users').prepend(li_elm);
        li_elm.slideDown(400);
      },
      error : function(jqxhr){
        pie.log(jqxhr.responseText);
        jQuery(".add-member-info").html(jqxhr.responseText);
      }
    });
  }
})

pie.MemberAutoComplete = Class.create(pie.UserAutoCompleteModule,{
  init:function(){
    this.org_id = this.options.org_id;
  },
  result:function(){
    this.add_member_submit();
  },
  add_member_submit:function(){
    jQuery('.add-member-info').html('正在处理...');
    var pars = this.inputer.serialize();
    new Ajax.Request("/organizations/"+this.org_id+"/members", {
      parameters:pars,
      onComplete:function(){
        this.inputer.val('');
      }.bind(this)
    });
  }
})

pie.ReceiverAutoComplete = Class.create(pie.UserAutoCompleteModule,{
  init:function(){
    this.url = '/users/receiver_autocomplete'
  },
  result:function(){
    pie.log(1);
  }
})


pie.FeedInviteComplete = Class.create(pie.UserAutoCompleteModule,{
  init:function(){
    this.feed_id = this.options.feed_id;
  },
  result:function(event,data){
    var json = data[0].evalJSON();
    var user_id = json.id;
    var feed_id = this.feed_id;
    var inputer = this.inputer;
    //post /feeds/:id/invite params[:user_ids] 1,2,3

    jQuery.ajax({
      url  : '/feeds/'+feed_id+'/invite',
      type : 'post',
      data : 'user_ids='+user_id,
      success : function(res){
        inputer.val('');
        var elm = jQuery('<div>'+res+'</div>');
        var new_biu_elm = elm.find('.show-page-be-invited-users');
        var old_biu_elm = jQuery('.show-page-be-invited-users');
        old_biu_elm.after(new_biu_elm);
        old_biu_elm.remove();
      }
    });
  }
})

//邀请推荐的参与者
pie.load(function(){
  jQuery('.page-show-who-recommend .user .invite a').live('click',function(){
    var elm = jQuery(this);
    var user_elm = elm.closest('.user');
    var user_id = user_elm.attr('data-id');
    var feed_id = jQuery('.page-feed-show').attr('data-id');

    jQuery.ajax({
      url  : '/feeds/'+feed_id+'/invite',
      type : 'post',
      data : 'user_ids='+user_id,
      success : function(res){
        var elm = jQuery('<div>'+res+'</div>');
        var new_biu_elm = elm.find('.show-page-be-invited-users');
        var old_biu_elm = jQuery('.show-page-be-invited-users');
        old_biu_elm.after(new_biu_elm);
        old_biu_elm.remove();
        user_elm.fadeOut(200);
      }
    });

  });
})