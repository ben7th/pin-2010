jQuery(document).ready(function($) {
  $('a[rel*=facebox]').facebox();
})

function show_fbox(string){
  if(jQuery('#facebox').length == 0 || jQuery('#facebox').css('display')=='none'){
    jQuery.facebox(string);
    jQuery('#facebox_overlay').unbind('click');
  }else{
    jQuery('#facebox .content').empty();
    jQuery.facebox.reveal(string);
  }
}

function close_fbox(){
  jQuery(document).trigger('close.facebox');
}