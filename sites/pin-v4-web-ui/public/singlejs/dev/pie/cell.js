pie.cell={
  init:function(){
  },

  //关闭cell，但不改变历史记录
  _close_cell:function(position){
    $$('#PL-'+position+' .content-cell').each(function(cell){
      $(cell).remove();
    })
  },

  //在某个页面区块显示loading效果
  show_loading:function(position){
    var el = $('PL-'+position)
    if(el){
      el.update(this.loading_cell.cloneNode(true));
      this.hide_blank_paper_cell();
    }
  },

  update_html:function(position,html_str){
    var el = $('PL-'+position)
    if(el){
      el.update(html_str);
    }
  },

  refresh_page_selectors:function(){
    //根据历史记录进行页面一些链接的高亮
    $$('.page-selector').each(function(ps){
      $(ps).removeClassName('url-active')
    });
    pie.history.hash.each(function(h){
      var url = h.value;
      var str = ':"'+url+'"'; //TODO 此处hack了，为了便于维护，以后要改掉
      $$('.page-selector').each(function(ps){
        if(ps.innerHTML.include(str)){
          $(ps).addClassName('url-active')
        }
      });
    })
  }
}