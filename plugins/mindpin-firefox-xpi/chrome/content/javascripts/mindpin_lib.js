if(typeof(Mindpin)=='undefined'){Mindpin = {}}
Mindpin.FireFoxWindow = Components.classes["@mozilla.org/appshell/window-mediator;1"]  
                    .getService(Components.interfaces.nsIWindowMediator)
                    .getMostRecentWindow("navigator:browser");

var keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

function getFireFoxWindow(){
  return Mindpin.FireFoxWindow
}

function getSidebarWindow(){
  return Mindpin.FireFoxWindow.document.getElementById("sidebar").contentWindow 
}

function getWebWindow(){
  return Mindpin.FireFoxWindow.gBrowser.contentWindow
}

function new_tab(url){
  var gbrowser = getFireFoxWindow().gBrowser;
  var tab = gbrowser.addTab(url);
  gbrowser.selectedTab = tab;
}

function btoa(input) {
    var output = "";
    var chr1, chr2, chr3;
    var enc1, enc2, enc3, enc4;
    var i = 0;
    do {
 
        chr1 = input.charCodeAt(i++);
        chr2 = input.charCodeAt(i++);
        chr3 = input.charCodeAt(i++);

        enc1 = chr1 >> 2;
        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
        enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
        enc4 = chr3 & 63;

        if (isNaN(chr2)) {
            enc3 = enc4 = 64;
        } else if (isNaN(chr3)) {
            enc4 = 64;
        }

        output = output + keyStr.charAt(enc1) + keyStr.charAt(enc2) +
        keyStr.charAt(enc3) + keyStr.charAt(enc4);
    } while (i < input.length);

    return output;
}

function toUTF8Octets(string) {
    return unescape(encodeURIComponent(string));
}

function getUnicodePref(prefName, prefBranch) {
    return prefBranch.getComplexValue(prefName, Components.interfaces.nsISupportsString).data;
}

function setUnicodePref (prefName, prefValue, prefBranch) {
    var sString = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);
    sString.data = prefValue;
    prefBranch.setComplexValue(prefName,  Components.interfaces.nsISupportsString, sString);
}

Mindpin.Preferences = {
  _branch: function(){
    return Components.classes["@mozilla.org/preferences-service;1"]
        .getService(Components.interfaces.nsIPrefService)
        .getBranch("mindpin")
  },

  // 设置 数字类型的偏好
  set_int: function(name,value){
    return this._branch().setIntPref(name,value)
  },

  // 获取 数字类型的偏好,如果没有,用默认的
  get_int: function(name,defalut){
    try{
      return this._branch().getIntPref(name)
    }catch(e){
      return defalut;
    }
  },

  // 设置 字符串类型的偏好（支持中文）
  set_unicode: function(name,value){
    var obj = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);
    obj.data = value;

    this._branch().setComplexValue(name,Components.interfaces.nsISupportsString, obj);
  },

  // 获取 字符串类型的偏好,如果没有,用默认的
  get_unicode: function(name,defalut){
    try{
      return this._branch().getComplexValue(name,Components.interfaces.nsISupportsString).data;
    }catch(e){
      return defalut;
    }
  },

  // 删除一个偏好
  remove: function(name){
    return this._branch().deleteBranch(name)
  }
}

Mindpin.Log = {
  _consoleService: Components.classes["@mozilla.org/consoleservice;1"]
                                  .getService(Components.interfaces.nsIConsoleService),
  m: function(msg){
    this._consoleService.logStringMessage(msg);
  }
}

jQuery.fn.extend({
  xshow: function() {
    return this.attr("hidden",false);
  },
  xhide: function() {
    return this.attr("hidden",true);
  }
});