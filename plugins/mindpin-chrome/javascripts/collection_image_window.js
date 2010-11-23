var BG = chrome.extension.getBackgroundPage();

$(document).ready(function(){
  //data 格式 {type:"send",data_type:"image",data:{src:"",width:"",height:""}}
  var data = BG.collection_data;
  BG.collection_data = null;
  // 切换页签
  Collection.select_tab_by_type(data.type)
  // 获取工作空间
  Collection.get_workspaces_to_select();
  // 设置 图片
  $("#send_image").attr("src",data.data.src)
  $("#send_image").attr("width",data.data.width)
  $("#send_image").attr("height",data.data.height)

  $("#share_image").attr("src",data.data.src)
  $("#share_image").attr("width",data.data.width)
  $("#share_image").attr("height",data.data.height)

  // 给发送按钮注册事件
  $("#send_btn").click(function(){
    $("#tip").hide();
    var content = data.data.src + " -- " +$("#send_content").attr("value")
    var workspace_id = $("#workspaces").attr("value")


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
    var content = data.data.href + $("#share_content").attr("value");

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


