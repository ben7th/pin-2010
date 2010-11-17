var links = [];
$("a").each(function(i,item){
  var item_j = $(item)
  links[i] = {
    href:item_j.attr("href"),
    text:item_j.text()
  };
});
var images = [];
$("img").each(function(i,item){
  var item_j = $(item)
  images[i] = {
    src:item_j.attr("src"),
    width:item_j.attr("width"),
    heigth:item_j.attr("height")
  };
});
var rsses = [];
$("link[type='application/rss+xml']").each(function(i,item){
  var item_j = $(item)
  rsses[i] = {
    href:item_j.attr("href") ,
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
      sendResponse({page_content: final_data});
    }
  }
);
