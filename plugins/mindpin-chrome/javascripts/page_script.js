// 是否是可忽略的 地址
function is_ignorable_url(url){
  if(/^(javascript:|#)/.test(url)){
    return true;
  }
  return false;
}

function check_url(url){
  if(is_ignorable_url(url)){
    return url
  }
  var location = document.location;
  var host = location.host;
  var protocol = location.protocol;
  var site = protocol + "//" + host;

  if(/^http/.test(url)){
    return url;
  }else{
    if(/^\//.test(url)){
      return site + url
    }
    return site + "/" + url;
  }
}

check_url("/rss")

var links = [];
$("a").each(function(i,item){
  var item_j = $(item)
  links[i] = {
    href:check_url(item_j.attr("href")),
    text:item_j.text()
  };
});
var images = [];
$("img").each(function(i,item){
  var item_j = $(item)
  images[i] = {
    src:check_url(item_j.attr("src")),
    width:item_j.attr("width"),
    heigth:item_j.attr("height")
  };
});
var rsses = [];
$("link[type='application/rss+xml']").each(function(i,item){
  var item_j = $(item)
  rsses[i] = {
    href:check_url(item_j.attr("href")) ,
    text:item_j.attr("title")
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
