var BG = chrome.extension.getBackgroundPage();
BG.MindpinWin.window = window;
MindpinWindow = {
  init: function(){
    // 注册一些事件
    this.add_events();
    this.loading_ui();
    this.show();
    $('#package_send').attr("disabled","disabled");
  },

  add_events: function(){
    // 退出登录按钮
    $("#logout").click(function(evt){
      BG.Mindpin.UserManager.logout();
      evt.preventDefault();
    });

    // 登录按钮
    $("#login").click(function(evt){
      BG.Mindpin.UserManager.prompt_user_login();
      evt.preventDefault();
    });
    // 注册按钮
    $("#register").click(function(evt){
      window.open(BG.Mindpin.REGISTER_URL)
      evt.preventDefault();
    });
    // 打包发送按钮
    $("#package_send").click(function(evt){
      evt.preventDefault();
      MindpinWindow.pack_send_elements()
    });
  },
  
  loading_ui: function(){
    
  },
  show: function(){
    var user = BG.Mindpin.UserManager.get_user();
    if(user){
      this.logined_ui(user);
    }else{
      this.unlogin_ui();
    }
  },
  logined_ui: function(user){
    $("#user_name").text(user.name);
    $("#user_avatar_img").attr("src",user.avatar);
    $("#unlogin_action").hide();
    $("#logined_action").show();
    this.show_window_content();
  },
  unlogin_ui: function(){
    $("#logined_action").hide();
    $("#unlogin_action").show();
    this.hide_window_content();
  },
  
  check_open_and_show: function(){
    this.loading_ui();
    this.show();
  },
  
  // 隐藏窗体内容
  hide_window_content : function(){
    $("#mindpin_window_content").hide();
  },
  
  // 显示窗体内容
  show_window_content : function(){
    $("#mindpin_window_content").show();
    this.show_page_info_comments();
    this.show_browse_history();
    this.show_page_content();
  },
  
  // 显示网页信息 以及网页评注
  show_page_info_comments : function(){
    if(BG.CurrentCorrectTab.url!=""){
      this.show_url_content(BG.CurrentCorrectTab.url);
    }
  },
  
  show_url_content : function(url){
    $.ajax({
      url:BG.Mindpin.WEB_SITE_INFOS_URL,
      data:{
        url:url
      },
      success:function(data){
        $("#web_site_info").html($("#web_site_info_template").tmpl(data))
        // 创建评注增加事件
        $("#create_comment_btn").click(function(evt){

          var content = $("#create_comment .comment_content").attr("value");
          if(content == ""){
            return
          }
          
          $.ajax({
            url:BG.Mindpin.CREATE_SITE_COMMENT_URL,
            type:"POST",
            data:{
              url:url,
              content:content
            },
            success:function(json){
              $("#web_site_comment_template").tmpl(json).prependTo($("#comments"))
              $("#create_comment .comment_content").attr("value","")
            }
          }
          )
        });

        // 编辑评注按钮的事件
        $("#comments .edit_btn").live("click",function(evt){
          var comment = $(this).closest("li").tmplItem().data;
          $("#create_comment").hide();
          var edit_comment_html = $("#edit_comment_template").tmpl();
          var edit_comment_div = $("#edit_comment");
          if(edit_comment_div.length == 0){
            edit_comment_html.appendTo("#web_site_info");
          }else{
            edit_comment_div.replaceWith(edit_comment_html);
          }
          $("#edit_comment .comment_content").attr("value",comment.content);
          // 给保存修改注册事件
          $("#edit_comment .save_btn").click(function(evt){
            var edit_url = BG.Mindpin.EDIT_SITE_COMMENT_PREFIX_URL + comment.id + ".json"
            var content = $("#edit_comment .comment_content").attr("value");
            if(content == ""){
              return
            }
            $.ajax({
              url:edit_url,
              type:"PUT",
              data:{
                content:content
              },
              success:function(json){
                $("#comment_" + comment.id).replaceWith($("#web_site_comment_template").tmpl(json))
                $("#edit_comment").remove();
                $("#create_comment").show();
              }
            });
          });
          // 给取消按钮注册事件
          $("#edit_comment .cancel_btn").click(function(evt){
            $("#edit_comment").remove();
            $("#create_comment").show();
          });
        });

        // 删除评注按钮的事件
        $("#comments .destroy_btn").live("click",function(evt){
          var li = $(this).closest("li")
          var comment = li.tmplItem().data;
          var destroy_url = BG.Mindpin.DESTROY_SITE_COMMENT_PREFIX_URL + comment.id + ".json"
          if(confirm("确认删除么？")){
            $.ajax({
              url:destroy_url,
              type:"delete",
              success:function(){
                li.remove();
              }
            });
          }
        });

        // 分享事件
        $("#comments .share_btn").click(function(evt){
          var li = $(this).closest("li")
          var comment = li.tmplItem().data;
          var link_data = {
            type:"share",
            data_type:"link",
            data:{
              href:url,
              text:comment.content
            }
          }
          MindpinWindow.open_collection_window(link_data)
        });
        // 发送事件
        $("#comments .send_btn").click(function(evt){
          var li = $(this).closest("li")
          var comment = li.tmplItem().data;
          var link_data = {
            type:"send",
            data_type:"link",
            data:{
              href:url,
              text:comment.content
            }
          }
          MindpinWindow.open_collection_window(link_data)
        });

      }
    });
  },
  
// 显示历史记录
show_browse_history : function(){
  $.ajax({url:BG.Mindpin.BROWSE_HISTORIES_URL,success:function(data){
    data = {browse_histories:data}
    $("#browse_history").html($("#browse_history_template").tmpl(data))
    // 渲染 chart 图标
    var swf_url = chrome.extension.getURL("fusion_charts/swf/Bar2D.swf");
    $.ajax({url:BG.Mindpin.BROWSE_HISTORIES_CHART_URL,dataType:"text",success:function(xml){
      var chart = new FusionCharts( swf_url,"chart", "300", "300", "0", "1" );
      chart.setDataXML(xml);
      chart.render("chartContainer");
    }})
    // 给获取更多历史按钮注册事件
    $("#more_histories").click(function(evt){
      evt.preventDefault();
      $("#loading_more_histories").show();
      var from = $("#browse_histories li").length;
      $.ajax({url:BG.Mindpin.BROWSE_HISTORIES_URL,data:{from:from},success:function(data){
        $("#loading_more_histories").hide();
        data = {browse_histories:data}

        $("#browse_history_li_template").tmpl(data).appendTo("#browse_histories");
      }})
    });

  }});
},

  // 处理图片大小
  // 设置图片高度100 宽度最大130
  new_image_size : function(width,height){
    var new_height = height;
    var new_width = width;
    var skeil = width/height ;
    if(new_height > 100){
      new_height = 100;
      new_width = skeil*100;
    }
    if(new_width > 130){
      new_width = 130;
      new_height = (1/skeil)*130;
    }
    return {height:new_height,width:new_width};
  },

  // 显示解析到的页面元素
  show_page_content : function(){
    chrome.tabs.sendRequest(BG.CurrentCorrectTab.tab_id, {
      give_content: "ok"
    }, function(response) {
      // 在第三个页签中插入元素
      $("#rsses_content").attr("innerHTML","");
      $("#links_content").attr("innerHTML","");
      $("#images_content").attr("innerHTML","");
      
      $(response.page_content.rsses).each(function(i,link){
        $("#rsses_content").append("<div class='rss_item'><input class='package_checkbox' type='checkbox'><a class='data' href="+link.href+">"+link.text+"</a> <a class='share' href='#'>分享</a> <a class='send' href='#'>发送</a><div>")
      });
      $(response.page_content.links).each(function(i,link){
        $("#links_content").append("<div class='link_item'><input class='package_checkbox' type='checkbox'><a class='data' href="+link.href+">"+link.text+"</a> <a class='share' href='#'>分享</a> <a class='send' href='#'>发送</a><div>")
      });
      $(response.page_content.images).each(function(i,image){
        var size = MindpinWindow.new_image_size(image.width,image.height)
        $("#images_content").append("<div class='image_item'><input class='package_checkbox' type='checkbox'><img class='data' src='"+image.src+"' width="+size.width+"px height="+size.height+"px real_width="+image.width+" real_height="+image.height+" /> <a class='share' href='#'>分享</a> <a class='send' href='#'>发送</a><div>")
      });

      // 注册 发送 分享 事件
      $("a.share").each(function(i,item){
        $(item).bind("click",function(){
          MindpinWindow.send_item("share",item)
        })
      });

      $("a.send").each(function(i,item){
        $(item).bind("click",function(){
          MindpinWindow.send_item("send",item)
        })
      });

      // 根据复选框的选择情况决定“打包发送”按钮的可用性
      $("input.package_checkbox").each(function(i,item){
        $(item).bind("click",function(){
          var checked_size = $("input.package_checkbox:checked").length
          if(checked_size==0){
            $('#package_send').attr("disabled","disabled")
          }else{
            $('#package_send').attr("disabled","")
          }
        })
      });

    });
  },


  send_item : function(operate_type,item){
    var link = $(item).siblings('a.data')[0];
    var image = $(item).siblings('img.data')[0];
    if(image!=null){
      var image_data = {
        type:operate_type,
        data_type:"image",
        data:{
          src:image.src,
          width:$(image).attr("real_width"),
          height:$(image).attr("real_height")
        }
      }
      MindpinWindow.open_collection_window(image_data)
    }else{
      var link_data = {
        type:operate_type,
        data_type:"link",
        data:{
          href:link.href,
          text:$(link).text()
        }
      }
      MindpinWindow.open_collection_window(link_data)
    }
  },

  
  // 发送历史记录
  send_browse_history : function(url,title){
    $.ajax({
      url: BG.Mindpin.SUBMIT_BROWSE_HISTORIES_URL,
      type: "post",
      async: true,
      data: {
        'url':url,
        'title':title
      },
      dataType: "text",
      success: function(){
        MindpinWindow.show_browse_history();
      }
    });
  },

  open_collection_window : function(data){
    // 新打开的 发送文本页面 会取 collection_data 这个数据
    BG.collection_data = data
    if(data.data_type == "link"){
      window.open("collection_text_window.html", "CollectionTextWindow", "height=400,width=500,scrollbars=no,menubar=no,location=no");
    }else if(data.data_type == "image"){
      window.open("collection_image_window.html", "CollectionImageWindow", "height=400,width=500,scrollbars=no,menubar=no,location=no");
    }
  },
  
  // 选中元素的处理
  pack_send_elements : function(){
    var rsses = []
    $(".rss_item input.package_checkbox:checked").each(function(i,item){
      var link = $(item).siblings('a.data')[0];
      rsses[i] = {
        href:link.href,
        text:link.text
      }
    });
    var links = []
    $(".link_item input.package_checkbox:checked").each(function(i,item){
      var link = $(item).siblings('a.data')[0];
      links[i] = {
        href:link.href,
        text:link.text
      }
    });
    var images = []
    $(".image_item input.package_checkbox:checked").each(function(i,item){
      var image = $(item).siblings('img.data')[0];
      images[i] = {
        src:image.src,
        width:$(image).attr('real_width'),
        height:$(image).attr('real_height')
      }
    });
    var final_data = {
      rsses:rsses,
      links:links,
      images:images
    }
    // 新打开 的 打包发送页面会用到这个数据
    BG.package_send_data = final_data;
    window.open("package_send_window.html", "PackageSendWindow", "height=400,width=500,scrollbars=no,menubar=no,location=no");
  },

  begin_clip : function(){
    $("#begin_clip").hide();
    $("#cancel_clip").show();
    $("#package_send_clip").attr("disabled","disabled")
    $("#package_send_clip").attr("innerHTML","发送捕捉到的元素")
    $("#package_send_clip").show();
    chrome.tabs.sendRequest(BG.CurrentCorrectTab.tab_id, {
      operate_clip: "begin"
    }, function(response) {
        
      });
  },

  cancel_clip : function(){
    $("#begin_clip").show();
    $("#cancel_clip").hide();
    $("#package_send_clip").hide();
    chrome.tabs.sendRequest(BG.CurrentCorrectTab.tab_id, {
      operate_clip: "cancel"
    }, function(response) {

      });
  },

  package_send_clip : function(){
    chrome.tabs.sendRequest(BG.CurrentCorrectTab.tab_id, {
      operate_clip: "send_elements"
    }, function(response) {
      // 新打开 的 打包发送页面会用到这个数据
      BG.package_send_data = response.final_data;
      window.open("package_send_window.html", "PackageSendWindow", "height=400,width=500,scrollbars=no,menubar=no,location=no");
    });
  }

}

// 页面选择 通知插件 发送捕捉元素 按钮 是否可用
chrome.extension.onRequest.addListener(
  function(request, sender, sendResponse) {
    // 按钮 上的 字符数 显示
    if(request.div_number != 0){
      $("#package_send_clip").attr("disabled","")
      $("#package_send_clip").attr("innerHTML","发送捕捉到的元素 "+ request.div_number +"块元素 " +request.char_number+"个字符 ")
    }else if(request.div_number == 0){
      $("#package_send_clip").attr("innerHTML","发送捕捉到的元素")
      $("#package_send_clip").attr("disabled","disabled")
    }
  });

$(document).ready(function(){
  MindpinWindow.init();
});
