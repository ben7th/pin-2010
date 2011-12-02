pie.inputflash = function(input_elm){
  input_elm
    .stop()
    .animate({'background-color': '#ffeeee'},100)
    .animate({'background-color': '#ffffff'},100)
    .animate({'background-color': '#ffeeee'},100)
    .animate({'background-color': '#ffffff'},100,function(){
      input_elm.css('background-color','');
    });
}

pie.inputflashdark = function(input_elm){
  input_elm
    .stop()
    .animate({'background-color': '#16181A'},200)
    .animate({'background-color': '#25282B'},200)
    .animate({'background-color': '#16181A'},200)
    .animate({'background-color': '#25282B'},200,function(){
      input_elm.css('background-color','');
    });
}


pie.load(function(){
  var ani = function(elm){
    elm.css('backgroundColor','#292929')
      .animate({'backgroundColor': '#E9B51C'}, 1000)
      .animate({'backgroundColor': '#292929'}, {
        duration:1000,
        complete:function(){
          ani(elm);
        }
      });
  }

  var ani1 = function(elm){
    elm
      .animate({'opacity': 0.6}, 500)
      .animate({'opacity': 1}, {
        duration:500,
        complete:function(){
          ani1(elm);
        }
      });
  }

  if(pie.env == 'development'){
    jQuery('.devdraft').each(function(){
      var elm = jQuery(this);
      ani(elm);
    })
    
    jQuery('[dev-note]').each(function(){
      var elm = jQuery(this);
      var felm = jQuery('<div class="dev-note-float"></div>');
      var o = elm.offset();
      felm.css('left',o.left).css('top',o.top);
      jQuery('body').append(felm);

      felm.tipsy({html:true,title:function(){
        var tip = elm.attr('dev-note')
        var doms = jQuery(tip)
        if(doms.length == 0) return tip;
        return doms.html();
      }});

      felm.bind('dblclick',function(){
        jQuery(this).remove();
        jQuery('.tipsy').remove();
      })

      ani1(felm);
    });
  }
});