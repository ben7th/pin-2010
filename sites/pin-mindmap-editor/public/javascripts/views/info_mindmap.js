
function change_lock(map_id){
  var link_dom = $('link_lock_'+map_id);
  link_dom
    .toggleClassName("private-mark-link")
    .toggleClassName("not-private-mark-link")
    
    .up("li").down('.private-mark')
    .toggleClassName('p')
}

function setting_private(pri){
  if(pri.checked){
    $$('input[name=share]').each(function(share){
      share.disabled = true
    })
    if($('input_share')){
      $("input_share").addClassName("hide")
    }
  }else{
    $$('input[name=share]').each(function(share){
      share.disabled = false
    })
    if($('input_share')){
      $("input_share").removeClassName("hide")
    }
  }
}

