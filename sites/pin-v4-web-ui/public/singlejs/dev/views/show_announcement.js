// 显示最新公告

ShowAnnouncement = Class.create({
  initialize : function(){
    var is_show = this.read_cookie("show_announcement");
    if(is_show == 'true'){
      this.show_announcement_box()
    }
  },

  show_announcement_box : function(){
    new pie.NoticeTip({
      width:'auto',
      height:'auto',
      position:'rightBottom',
      ajax:'/announcements/last',
      animate:{
        effect:'appear',
        params:{
          duration: 2.0
        }
      }
    });
  },

  read_cookie : function(name){
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
      var c = ca[i];
      while (c.charAt(0)==' ') c = c.substring(1,c.length);
      if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
  }
});

pie.load(function(){
  if(window.location.pathname != "/"){
    new ShowAnnouncement()
  }
});




