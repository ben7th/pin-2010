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
    var concat_box = getSidebarWindow().document.createElement("vbox");
    concat_box.setAttribute("align","start");
    concat_box.setAttribute("class","concat_box");
    concat_box.setAttribute("id","concat_box_"+data[1].id);
    if(typeof(data[0].email)=="undefined"){
      var label = getSidebarWindow().document.createElement("label");
      label.setAttribute("value",data[1].email);
      concat_box.appendChild(label);
    }else{
      Mindpin.Concats.add_element_to_concatbox(concat_box,data);
    }
    Mindpin.Concats.add_delete_button(concat_box,data[1].id);
    Mindpin.Concats.add_right_key_menu(concat_box,data[1].id,data[0].id);
    return concat_box
  },

  // 将联系人 显示到插件上
  add_element_to_concatbox : function(concat_box,data){
    var avatar = getSidebarWindow().document.createElement("image");
    avatar.setAttribute("src",data[0].avatar);
    avatar.setAttribute("width","32px");
    avatar.setAttribute("height","32px");
    Mindpin.Concats.show_user_info(concat_box,avatar,data);
    var name_label = getSidebarWindow().document.createElement("label");
    name_label.setAttribute("value",data[0].name);
    var email_label = getSidebarWindow().document.createElement("label");
    email_label.setAttribute("value",data[0].email);
    concat_box.appendChild(avatar);
    concat_box.appendChild(name_label);
    concat_box.appendChild(email_label);
  },

  // 显示用户详细资料
  show_user_info : function(concat_box,avatar,data){
    var temp_box = $(getSidebarWindow().document.createElement("div"));
    temp_box.hide();
    concat_box.appendChild(temp_box[0])
    $(avatar).bind("mouseover",function(evt){
      setTimeout(function(){
        temp_box.attr("style","width:200px;height:200px;-moz-appearance:none;position:fixed;background-color:#FFF000;left:"+evt.clientX+"px;top:"+evt.clientY+"px");
        temp_box.show()
      },500);
    });
    $(avatar).bind("mouseout",function(){
      temp_box.hide();
    });
  },

  // 删除联系人的按钮  和 事件
  add_delete_button : function(box,concat_id){
    var delete_label = getSidebarWindow().document.createElement("label");
    delete_label.setAttribute("value","删除");
    delete_label.setAttribute("class","text-link");
    Mindpin.Concats.add_delete_envent(delete_label,concat_id);
    box.appendChild(delete_label);
  },

  // 给元素 注册删除 事件
  add_delete_envent : function(item,concat_id){
    item.addEventListener('click',function(){
      if (confirm("确认删除?")==true){
        $.ajax({
          url: Mindpin.DESTROY_CONCAT_URL+"?id="+concat_id,
          type: "delete",
          success: function(data){
            $(item).parents("vbox.concat_box").remove();
          },
          error: function(xhr,text,error){
            alert("删除失败")
          }
        });
      }
    },false);
  },

  // 添加右键菜单
  add_right_key_menu : function(box,concat_id,user_id){
    // 创建右键菜单元素（两个链接 -删除 -查看）
    var menu_box = getSidebarWindow().document.createElement("popup");
    $(menu_box).attr("id","concat_context_menu_"+concat_id)
    var delete_menuitem = getSidebarWindow().document.createElement("menuitem");
    $(delete_menuitem).attr("label","删除联系人");
    Mindpin.Concats.add_delete_envent(delete_menuitem,concat_id);
    menu_box.appendChild(delete_menuitem);
    // 如果哟过户存在添加 查看个人页 按钮
    if(typeof(user_id)!="undefined"){
      var show_concat_menuitem = getSidebarWindow().document.createElement("menuitem");
      $(show_concat_menuitem).attr("label","查看个人页");
      $(show_concat_menuitem).bind("command",function(){
        new_tab(Mindpin.SHOW_USER(user_id))
      });
      menu_box.appendChild(show_concat_menuitem);
    }

    box.appendChild(menu_box);
    $(box).attr("context","concat_context_menu_"+concat_id);
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
        error_message.setAttribute("style","display:none");
        email.value = "";
        var concats = getSidebarWindow().document.getElementById("concats");
        var concat_box = Mindpin.Concats.create_concat_vbox(data);
        concats.appendChild(concat_box);
      },
      error: function(xhr,text,error){
        error_message.setAttribute("style","");
        error_message.setAttribute("value",xhr.responseText);
      }
    });
  }

}

