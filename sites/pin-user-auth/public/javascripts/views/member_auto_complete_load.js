pie.UserAutoCompleteModule = {
  initialize:function(inputer,options){
    this.options = options || {};
    this.inputer = jQuery(inputer).val('');
    this.init();
    this._enable_ac();
  },
  init:function(){},
  _enable_ac:function(){
    this.inputer.autocomplete('/users/autocomplete',{
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

pie.ConcatAutoComplete = Class.create(pie.UserAutoCompleteModule,{
  result:function(){
    this.add_member_submit();
  },
  add_member_submit:function(){
    jQuery('.add-member-info').html('正在处理...');
    var pars = this.inputer.serialize();
    new Ajax.Request('/concats', {
      parameters:pars,
      onComplete:function(){
        this.inputer.val('');
      }.bind(this)
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