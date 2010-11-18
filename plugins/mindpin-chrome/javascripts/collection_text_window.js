var BG = chrome.extension.getBackgroundPage();

$(document).ready(function(){
  //data 格式 {type:"send",data_type:"link",data:{href:"",text:""}
  var data = BG.collection_data;
  BG.collection_data = null;
  // 切换页签
  Collection.select_tab_by_type(data.type)
  // 设置 表单内容
  var content = data.data.text + " -- " + data.data.href
  $("#send_content").attr("value",content)
  $("#share_content").attr("value",content)
  // 获取工作空间
  Collection.get_workspaces_to_select();

  
  // 给发送按钮注册事件
  $("#send_btn").click(function(){
    $("#tip").hide();
    var content = $("#send_content").attr("value")
    var workspace_id = $("#workspaces").attr("value")

    if(content == ""){
      $("#tip").text("发送内容不能为空")
      $("#tip").show();
      $("#send_content")[0].focus();
      return;
    }

    $("#tip").text("正在发送数据 ...")
    $("#tip").show();

    var success = function(url){
      $(document.body).html("发送成功，<a href='"+ url +"' target='_blank'>查看详情<a>")
    }
    var auth = function(){
      $("#tip").text("未知错误");
      $("#tip").show();
    }
    
    $.ajax({
      url: BG.Mindpin.SUBMIT_DISCUSSION_URL,
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
  });


  // 给分享按钮注册事件
  $("#share_btn").click(function(){
    $("#tip").hide();
    var content = $("#share_content").attr("value");
    
    if(content == ""){
      $("#tip").text("分享内容不能为空")
      $("#tip").show();
      $("#share_content")[0].focus();
      return;
    }
    $("#tip").text("正在发送数据 ...")
    $("#tip").show();
    var success = function(url){
      $(document.body).html("发送成功，<a href='"+ BG.Mindpin.SHARE_LIST_URL +"' target='_blank'>查看详情<a>")
    }
    var auth = function(){
      $("#tip").text("未知错误");
      $("#tip").show();
    }
    $.ajax({
      url: BG.Mindpin.SUBMIT_SHARE_URL,
      type: "post",
      async: true,
      data: {
        content:content
      },
      dataType: "text",
      success: success,
      error: auth
    });
  })
  
  
});