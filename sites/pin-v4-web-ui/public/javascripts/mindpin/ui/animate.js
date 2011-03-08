pie.inputflash = function(input_dom){
  var elm = jQuery(input_dom)
  var current =  elm.css('background-color');
  
  elm
    .animate({'backgroundColor': '#FFB49C'}, 100)
    .animate({'backgroundColor': current}, 100)
    .animate({'backgroundColor': '#FFB49C'}, 100)
    .animate({'backgroundColor': current}, {
      duration:100,
      complete:function(){
        elm.css('backgroundColor',current);
      }
    });
}


