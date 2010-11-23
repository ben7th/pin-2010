if(typeof(Mindpin)=='undefined'){
  Mindpin = {}
}
Mindpin.CollectionTextWindow = {
  init: function(){
    var data = window.arguments[0];
//    $("#tabbox")[0].selectedIndex = window.arguments[1];
//    $("#share_content").attr("value",data);
    $("#send_content").attr("value",data);
    Mindpin.CollectionTextWindow.get_workspaces_to_itemlist();
  },
  share_ui: function(data){
    window.openDialog("chrome://mindpin/content/collection_text_window.xul", "collection_text_window", "chrome,dialog,centerscreen,modal,resizable=no",data,0);
  },
  send_ui: function(data){
    window.openDialog("chrome://mindpin/content/collection_text_window.xul", "collection_text_window", "chrome,dialog,centerscreen,modal,resizable=no",data,1);
  },
  share: function(){
    var content =$("#share_content")[0].value;
    Mindpin.CollectionTextWindow.send_share_content(content);
  },
  send: function(){
    var content = $("#send_content")[0].value;
    if(content == ""){
      alert("内容不能为空")
      $("#send_content")[0].focus();
    }
    var selectedItem = $("#send_workspace")[0].selectedItem
    if(!selectedItem){
      alert("请选择一个工作空间")
    }
    var workspace_id = selectedItem.value

    var success = function(discussion_url){
      $("#send_loading").attr("hidden",true);
      $("#send_tip").attr("发送成功")
      var opener = window.opener;
      var link = discussion_url;
      window.close();
      opener.setTimeout(function(){
        opener.openDialog("chrome://mindpin/content/message.xul", "message_window", "chrome,dialog,centerscreen,modal,resizable=no",link);
      },0)
    }
    var auth = function(){
      $("#send_loading").attr("hidden",true);
      $("#send_tip").attr("value","发送失败，未知错误")
    }
    $("#send_loading").attr("hidden",false);
    $("#send_tip").attr("value","正在提交..")

    $.ajax({
      url: Mindpin.SUBMIT_DISCUSSION_URL, 
      type: "post",
      async: true,
      data: {
        workspace_id:workspace_id,
        "text_pin[html]":content
      },
      dataType: "text", 
      success: success,
      error: auth
    });
  },
  send_share_content : function(content){
    if(content == ""){
      alert("内容不能为空")
      $("#share_content")[0].focus();
    }
    var success = function(){
      $("#share_loading").attr("hidden",true);
      $("#share_tip").attr("发送成功")
      var opener = window.opener;
      var link = Mindpin.SHARE_LIST_URL;
      window.close();
      opener.setTimeout(function(){
        opener.openDialog("chrome://mindpin/content/message.xul", "message_window", "chrome,dialog,centerscreen,modal,resizable=no",link);
      },0)
    }
    var auth = function(){
      $("#share_loading").attr("hidden",true);
      $("#share_tip").attr("value","发送失败，未知错误")
    }
    $("#share_loading").attr("hidden",false);
    $("#share_tip").attr("value","正在提交..")

    $.ajax({
      url: Mindpin.SUBMIT_SHARE_URL, 
      type: "post",
      async: true,
      data: {
        content:content
      },
      dataType: "text", 
      success: success,
      error: auth
    }); 
  },
  comments_data: function(share_button){
    var content = $(share_button).closest(".actions").prev("p").html();
    var title = getWebWindow().document.title;
    var url = getWebWindow().document.location;
    return title + " -- " + url + "    " + content;
  },
  share_comments_ui: function(share_button){
    var data = Mindpin.CollectionTextWindow.comments_data(share_button);
    Mindpin.CollectionTextWindow.share_ui(data);
  },
  send_comments_ui: function(send_button){
    var data = Mindpin.CollectionTextWindow.comments_data(send_button);
    Mindpin.CollectionTextWindow.send_ui(data);
  },
  url_data: function(share_button){
    var a = $(share_button).prev("a");
    var title = a.text();
    var url = a.attr("href");
    return title + " -- " + url;
  },
  share_url_ui: function(share_button){
    var data = Mindpin.CollectionTextWindow.url_data(share_button);
    Mindpin.CollectionTextWindow.share_ui(data);
  },
  send_url_ui: function(send_button){
    var data = Mindpin.CollectionTextWindow.url_data(send_button);
    Mindpin.CollectionTextWindow.send_ui(data);
  },
  open_new_workspace_page: function(){
    window.close();
    var gbrowser = getFireFoxWindow().gBrowser;
    var tab = gbrowser.addTab(Mindpin.NEW_WORKSPACE_URL);
    gbrowser.selectedTab = tab;
  },
  select_workspace: function(){
    var selectedItem = $("#send_workspace")[0].selectedItem;
    this.set_select_workspace_id(selectedItem.value);
    $("#send_button")[0].disabled = (!selectedItem);
  },

  // 给空间列表选择框填充值
  get_workspaces_to_itemlist: function(){
    $.ajax({
      url: Mindpin.WORKSPACE_LIST_URL,
      type: "get",
      dataType: "json",
      success: function(arr){
        var send_workspace_list = $("#send_workspace")[0];
        $(arr).each(function(){
          var workspace = this.workspace
          var id = workspace.id
          var name = workspace.name
          send_workspace_list.appendItem(name,id)
        });
        // 获取本地保存的 用户 选择过的 空间 id
        var saved_id = Mindpin.CollectionTextWindow.get_select_workspace_id();
        if (saved_id==null){
          // 默认设为选择列表的第一个
          send_workspace_list.selectedIndex = 0;
        }else{
          send_workspace_list.selectedItem = $(send_workspace_list).find("menuitem[value='"+saved_id+"']")[0]
        }
        // 检测第一个元素是否有东西，有的话，后面的按钮显示为可用
        if(send_workspace_list.selectedItem!=null){
          $("#send_button")[0].disabled = false;
        }
        if(send_workspace_list.itemCount == 0){
          $("#create_workspace_tip").css("visibility","visible")
        }
      }
    })
  },
  
  // 保存用户选择空间 的 id
  set_select_workspace_id : function(workspace_id){
    Mindpin.Preferences.set_unicode("selected_workspace_id",workspace_id);
  },

  // 获取保存在本地的 用户选择空间 的 id
  get_select_workspace_id : function(){
    return Mindpin.Preferences.get_unicode("selected_workspace_id",null);
  }

};