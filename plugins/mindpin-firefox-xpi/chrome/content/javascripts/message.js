/* 
 * 消息框
 */
if(typeof(Mindpin)=="undefined"){
  Mindpin={}
}

Mindpin.Message = {
  init : function(){
    var link = window.arguments[0];
    $("#link")[0].addEventListener("click",function(){
      new_tab(link);
      window.close();
    },false)
  }

}

