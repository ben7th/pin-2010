/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

var ToolLib = {
  // 是否是可忽略的 地址
  is_ignorable_url : function(url){
    if(/^(javascript:|#)/.test(url)){
      return true;
    }
    return false;
  },

  check_url : function(url,location){
    if(this.is_ignorable_url(url)){
      return url
    }
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

}


