var BG = chrome.extension.getBackgroundPage();

// 把 data 转换成 xml 数据
function bundle_data(data){
  // 链接
  var bundle_str = ""
  $(data.links).each(function(){
    bundle_str += '<link href="'+ this.href +'" text="' + this.text + '" />';
  })
  // rss
  $(data.rsses).each(function(){
    bundle_str += '<link href="'+ this.href +'" text="' + this.text + '" />';
  })
  // 图片
  $(data.images).each(function(){
    bundle_str += '<image src="' + this.src + '"/>';
  })
  return '<bundle>'+ bundle_str +'</bundle>'
}

// 把 data 显示出来
function show_data(data){
  var rsses_dom_str = ""
  var links_dom_str = ""
  var image_dom_str = ""
  $(data.rsses).each(function(){
    rsses_dom_str += "<div><a href='"+ this.href +"'>"+ this.text +"<a></div>"
  });
  $(data.links).each(function(){
    links_dom_str += "<div><a href='"+ this.href +"'>"+ this.text +"<a></div>"
  });
  $(data.images).each(function(){
    image_dom_str += "<div><img src='"+this.src+"' width='"+ this.width +"' height='"+this.height+"' /></div>"
  });
  
  $("#package_content").append(rsses_dom_str)
  $("#package_content").append(links_dom_str)
  $("#package_content").append(image_dom_str)
}

$(document).ready(function(){
//   {
//      rsses:[{href:"",text:""}],
//      links:[{href:"",text:""}],
//      images:[{src:"",width:"",height:""}]
//    }
  var data = BG.package_send_data;
  BG.package_send_data = null;
  // 获取工作空间
  Collection.get_workspaces_to_select();
  // 显示 data
  show_data(data);

  // 发送按钮事件
  $("#send_btn").click(function(){
    $("#tip").hide();
    var comment = $("#send_content").attr("value") || "无标题"
    var bundle_xml = bundle_data(data);
    var content = bundle_xml + comment
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
});

