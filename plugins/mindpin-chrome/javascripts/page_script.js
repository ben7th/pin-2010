var location_obj = document.location;

function is_blank(str){
  var str_tmp = $.trim(str)
  if(str_tmp.length==0){
    return true;
  }
  return false;
}

var links = [];
$("a").each(function(i,item){
  var item_j = $(item)
  var url = ToolLib.check_url(item_j.attr("href"),location_obj)
  var text = is_blank(item_j.text()) ?  url : item_j.text()
  links[i] = {
    href: url,
    text: text
  };
});
var images = [];
$("img").each(function(i,item){
  var item_j = $(item)
  images[i] = {
    src:ToolLib.check_url(item_j.attr("src"),location_obj),
    width:item_j.attr("width"),
    height:item_j.attr("height")
  };
});
var rsses = [];
$("link[type='application/rss+xml']").each(function(i,item){
  var item_j = $(item)
  var url = ToolLib.check_url(item_j.attr("href"),location_obj)
  var text = is_blank(item_j.attr("title")) ?  url : item_j.attr("title")
  rsses[i] = {
    href: url,
    text: text
  };
});
var final_data = {
  links:links,
  images:images,
  rsses:rsses
};
chrome.extension.onRequest.addListener(
  function(request, sender, sendResponse) {
    if (request.give_content == "ok"){
      sendResponse({
        page_content: final_data
      });
    }
  }
  );
