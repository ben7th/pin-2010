(function($) {
  $(document).ready(function() {
    $('[original-title]').tipsy({html:true});
    $('[tip]').tipsy({html:true,title:function(){
      var tip = this.getAttribute('tip')
      var doms = $(tip)
      if(doms.length == 0) return tip;
      return doms.html();
    }});
    $('[tipr]').tipsy({html:true,gravity:'w',title:function(){
      var tip = this.getAttribute('tipr')
      var doms = $(tip)
      if(doms.length == 0) return tip;
      return doms.html();
    }});
  });
})(jQuery);