pie.load(function(){
  pie.cell.init();
  pie.tab.init();
  pie.mplist.init();
//  init_mini_buttons();
});

//function init_mini_buttons(){
//  $$('a.minibutton').each(function(btn){
//    if(btn.hasClassName('inited')) return;
//    btn
//      .observe('mousedown',minibutton_toggle_mousedown)
//      .observe('mouseup',minibutton_toggle_mouseup)
//      .observe('mouseleave',minibutton_toggle_mouseup);
//    btn.addClassName('inited');
//  })
//}
//
//function minibutton_toggle_mousedown(){
//  $(this).addClassName('mousedown');
//}
//
//function minibutton_toggle_mouseup(){
//  $(this).removeClassName('mousedown');
//}

//此处放置一些全局的函数

function enable_mouse_over(el){
  $(el)
  .observe('mouseover',function(evt){
    evt.stop();
    el.addClassName('mouseover');
  }.bind(this))
  .observe('mouseout',function(evt){
    evt.stop();
    el.removeClassName('mouseover');
  }.bind(this))
  return el;
}

function show_ajax_info(options){
  options = options || {}
  var mode = options.mode;
  switch(mode){
    case 'success':{
      pie.page_cache.ajax_page_info_div.remove();
    }break;
    case 'failure':{
      pie.page_cache.ajax_page_info_div.remove();
      show_fbox('<div style="background:red;font-size:30px;color:white;font-weight:bold;">啊喔，出錯了..! &gt;_&lt;</div>')
    }
    default:{
      document.body.appendChild(pie.page_cache.ajax_page_info_div.addClassName('ajax-page-loading').update('正在讀取...'));
    }
  }
}

//切换页面皮肤样式
function toggle_theme(theme){
  var csslink = $$('link[t=theme]')[0];
  csslink.href = '/stylesheets/themes/'+theme+'.css'
  if(pie.isIE()){
    var csslink_ie = $$('link[t=themeie]')[0];
    csslink_ie.href = '/stylesheets/themes/'+theme+'.ie.css'
  }
}