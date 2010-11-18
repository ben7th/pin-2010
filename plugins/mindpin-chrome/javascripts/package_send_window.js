var BG = chrome.extension.getBackgroundPage();

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
  
  $("#package_content").html(data.rsses.length + data.links.length + data.images.length)
});

