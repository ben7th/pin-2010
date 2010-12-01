/* 
 * 联系人的js操作
 */
if(typeof(Mindpin)=="undefined"){
  Mindpin=={}
}

Mindpin.Concats = {
  init : function(){
    this.show_concats();
  },

  // 显示联系人
  show_concats : function(){
    var concats = getSidebarWindow().document.getElementById("concats")
    while (concats.firstChild) {
      concats.removeChild(concats.firstChild);
    }
    $.ajax({
      url: Mindpin.CONCATS_URL,
      type: "get",
      success: function(data){
        for(var i=0;i<data.length;i++){
          var concat_box = Mindpin.Concats.create_concat_vbox(data[i])
          concats.appendChild(concat_box);
        }
      }
    });
  },

  // 组装用户
  create_concat_vbox : function(data){
    var concat_box = getSidebarWindow().document.createElement("vbox")
    concat_box.setAttribute("align","start")
    if(typeof(data[0].email)=="undefined"){
      var label = getSidebarWindow().document.createElement("label")
      label.setAttribute("value",data[1].email)
      concat_box.appendChild(label)
    }else{
      var avatar = getSidebarWindow().document.createElement("image")
      avatar.setAttribute("src",data[0].avatar)
      avatar.setAttribute("width","32px")
      avatar.setAttribute("height","32px")
      var name_label = getSidebarWindow().document.createElement("label")
      name_label.setAttribute("value",data[0].name)
      var email_label = getSidebarWindow().document.createElement("label")
      email_label.setAttribute("value",data[0].email)
      concat_box.appendChild(avatar)
      concat_box.appendChild(name_label)
      concat_box.appendChild(email_label)
    }
    return concat_box
  },

  // 添加联系人
  add_concat : function(){
    var email = getSidebarWindow().document.getElementById("concat_email_text")
    var error_message = getSidebarWindow().document.getElementById("email_error_message")
    $.ajax({
      url: Mindpin.ADD_CONCAT_URL,
      type: "post",
      data:{
        email:email.value
        },
      success: function(data){
        Mindpin.Log.m(data)
        error_message.setAttribute("style","display:none")
        email.value = "";
        var concats = getSidebarWindow().document.getElementById("concats")
        var concat_box = Mindpin.Concats.create_concat_vbox(data)
        concats.appendChild(concat_box);
      },
      error: function(xhr,text,error){
        error_message.setAttribute("style","")
        error_message.setAttribute("value",xhr.responseText)
      }
    });
  }

}

