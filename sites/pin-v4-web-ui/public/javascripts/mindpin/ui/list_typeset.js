//导图排版
//feed排版算法
pie.load(function(){
  var top_l = 0;
  var top_m = 0;
  var top_r = 0;

//  jQuery('.page-user-mindmaps').append('<div class="listl"></div><div class="listm"></div><div class="listr"></div>');
//
//  jQuery('.page-user-mindmaps .mindmap-m').each(function(){
//    var mindmap_elm = jQuery(this);
//    var listl = jQuery('.page-user-mindmaps .listl');
//    var listm = jQuery('.page-user-mindmaps .listm');
//    var listr = jQuery('.page-user-mindmaps .listr');
//    pie.log(1)
//    var min = [top_l, top_m, top_r].min();
//
//    if(min == top_l){
//      //左边
//      listl.append(mindmap_elm);
//      top_l += (mindmap_elm.height());
//    }else if(min == top_m){
//      //中间
//      listm.append(mindmap_elm);
//      top_m += (mindmap_elm.height());
//    }else{
//      //右边
//      listr.append(mindmap_elm);
//      top_r += (mindmap_elm.height());
//    }
//  })

  jQuery('.page-user-mindmaps').css('position','relative');

  jQuery('.page-user-mindmaps .mindmap-m').each(function(){
    var mindmap_elm = jQuery(this);
    mindmap_elm.css('position','absolute');

    var min = [top_l, top_m, top_r].min();

    mindmap_elm.css('top',min);

    if(min == top_l){
      //左边
      mindmap_elm.css('left',0);
      top_l += (mindmap_elm.height());
    }else if(min == top_m){
      //中间
      mindmap_elm.css('left',240);
      top_m += (mindmap_elm.height());
    }else{
      //右边
      mindmap_elm.css('left',480);
      top_r += (mindmap_elm.height());
    }

    jQuery('.page-user-mindmaps').css('height',[top_l, top_m, top_r].max());
  })
})