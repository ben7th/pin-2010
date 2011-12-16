/* 
 * 当分享内容的字数超过140个字之后
 *  可以隐藏后面的内容，通过点击，来进行展开和隐藏操作
 */

ShowShareContent = {
  show : function(dom){
    //显示详细内容，隐藏缩略内容
    var span = $(dom.parentNode);
    span.addClassName('hide');
    span.next().removeClassName('hide');
  },
  hide : function(dom){
    //显示缩略内容，隐藏详细内容
    var span = $(dom.parentNode);
    span.addClassName('hide');
    span.previous().removeClassName('hide');
  }
}


