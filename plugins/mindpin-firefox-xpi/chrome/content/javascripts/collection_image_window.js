/* 
 * 显示图片的窗体
 */
if(typeof(Mindpin)=="undefined"){
  Mindpin={}
}

Mindpin.CollectionImageWindow = {
  // 打开collection_image_window页面后，运行此函数，处理这个窗口中的元素内容
  init : function(){
    var data = window.arguments[0];
    this.image_data = data;
    $('#share_image_src_label').attr('value',data['image_src']);
    $('#share_picture_show').attr("src",data['image_src']);
    $('#share_picture_show').attr("width",data['width']);
    $('#share_picture_show').attr("height",data['height']);
    
    $('#send_image_src_label').attr('value',data['image_src']);
    $('#send_picture_show').attr("src",data['image_src']);
    $('#send_picture_show').attr("width",data['width']);
    $('#send_picture_show').attr("height",data['height']);
    Mindpin.CollectionTextWindow.get_workspaces_to_itemlist();
  },

  // 显示这个窗口
  show : function(options){
    window.openDialog("chrome://mindpin/content/collection_image_window.xul", "collection_image_window", "chrome,dialog,centerscreen,modal,resizable=no",options);
  },

  // 分享这个图片到服务器
  share : function(){
    var comment = $('#share_comment')[0].value;
    // 评语暂时先添加到字符串的后面 
    Mindpin.CollectionTextWindow.send_share_content(this.image_data["image_src"]+" 评语:"+comment);
  },

  // 发送这个图片到 工作空间
  send : function(){
    var comment = $('#send_comment')[0].value;
    var content = this.image_data["image_src"] + " -- " + comment;
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
      url: Mindpin.SUBMIT_DISCUSSION_URL, type: "post", async: true,
      data: {workspace_id:workspace_id,"text_pin[html]":content},
      dataType: "text", success: success,error: auth
    });
   }

}

