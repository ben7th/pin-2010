/*
 * 打包发送的窗体
 */
if(typeof(Mindpin)=="undefined"){
  Mindpin={}
};

Mindpin.PackageSendWindow = {
  init: function(){
    Mindpin.CollectionTextWindow.get_workspaces_to_itemlist();
    var data = window.arguments[0];
    // 链接
    var link_box = document.createElement("vbox");
    $(link_box).css("marginBottom",20);
    var link_label = document.createElement("label");
    link_label.textContent = "您选择的链接"
    link_box.appendChild(link_label)
    $(data.links).each(function(){
      var description = document.createElement("description");
      description.textContent = this.text + " -- " + this.href
      link_box.appendChild(description)
    });
    $("#package_content")[0].appendChild(link_box);
    // rss
    var rss_box = document.createElement("vbox");
    $(rss_box).css("marginBottom",20);
    var rss_label = document.createElement("label");
    rss_label.textContent = "您选择的 RSS 链接";
    rss_box.appendChild(rss_label);
    $(data.rsses).each(function(){
      var description = document.createElement("description");
      description.textContent = this.text + " -- " + this.href
      rss_box.appendChild(description)
    });
    $("#package_content")[0].appendChild(rss_box)
    // 图片
    var image_box = document.createElement("vbox");
    image_box.setAttribute("align","start")
    $(image_box).css("marginBottom",20)
    var image_label = document.createElement("label");
    image_label.textContent = "您选择的 图片";
    image_box.appendChild(image_label);
    $(data.images).each(function(){
      var image = document.createElement("image");
      image.setAttribute("src",this.src);
      image_box.appendChild(image)
    });
    $("#package_content")[0].appendChild(image_box)
  },
  send: function(){
    var bundle_xml = this.bundle_data();
    var comment = $('#send_content')[0].value;
    var content = bundle_xml + comment;
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
  },
  bundle_data: function(){
    var data = window.arguments[0];
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
};