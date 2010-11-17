chrome.extension.onRequest.addListener(
  function(request, sender, sendResponse) {
//    if(request.name == "request_web_content"){
//      // 这里 只能 传递 非DOM 数据
//      // 可以把内容解析完了再传给 工具栏显示
//      sendResponse({image:[],rss:[],link:[]})
//    }
  });