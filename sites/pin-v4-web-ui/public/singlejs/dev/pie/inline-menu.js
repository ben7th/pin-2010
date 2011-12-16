pie.inline_menu = {
  init:function(){
    //生成页面上的所有菜单，同时避免重复生成
    $$('.inline-menu').each(function(menu_dom){
      this._init_menu(menu_dom);
    }.bind(this));
  },

  _init_menu:function(menu_dom){
    //如果已经生成过了，排除
    if($(menu_dom).hasClassName('menu-packed')) return;
    //生成
    menu_dom.addClassName('menu-packed');
    
    var menu = new pie.html.Menu({on:'mousedown',width:80});
    var menu_icon = menu_dom.down('.menu-icon');
    menu_dom.down('.menu-body').select('a').each(function(a){
      menu.add_dom(a);
    })
    menu.append(menu_icon,"bottom_right");
  }

}


