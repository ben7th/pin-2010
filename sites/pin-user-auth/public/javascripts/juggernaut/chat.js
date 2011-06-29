jQuery(function(){


  jQuery("#chat_say").click(function(){
    var message_input = jQuery("input[id=message]");
    var message = message_input.attr("value");
    if(!message){return}

    jQuery.ajax({
      type    : "POST",
      url     : '/v2/chat_say',
      data    : {"message":message},
      method    : "post",
      complete : function(res){
        message_input.attr("value","");
      }
    });
  });


  var jug = new Juggernaut;
  jug.subscribe("chat", function(data){
    //  data.user.name
    //  data.user.homepage
    //  data.user.avatar
    //  data.message
    console.log(data)
    var message = data.user.name + " : " + data.message

    var chat = jQuery("#chat")
    var str = chat.attr("value")
    chat.attr("value",str+"\r\n"+message)
  });
  
});