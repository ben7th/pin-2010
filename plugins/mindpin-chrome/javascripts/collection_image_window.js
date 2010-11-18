var BG = chrome.extension.getBackgroundPage();

$(document).ready(function(){
  //data 格式 {type:"send",content:data}
  var data = BG.collection_data;
  BG.collection_data = null;
  // 切换页签
  Collection.select_tab_by_type(data.type)
  // 设置 图片
  $("#send_image").attr("src",data.image.src)
  $("#send_image").attr("width",data.image.width)
  $("#send_image").attr("height",data.content.height)

  $("#share_image").attr("src",data.image.src)
  $("#share_image").attr("width",data.image.width)
  $("#share_image").attr("height",data.content.height)

  // 给发送按钮注册事件
  $("#send_btn").click(function(){
    $("#tip").hide();
    var content = data.image.src + " -- " +$("#send_content").attr("value")
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
    var content = data.image.src + $("#share_content").attr("value");

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


