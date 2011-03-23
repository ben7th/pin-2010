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
        return "<img class='logo tiny' src='"+json.avatar+"' />"+json.name+"("+json.email+")";
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