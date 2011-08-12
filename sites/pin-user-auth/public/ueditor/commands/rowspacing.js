/**
 * @description 设置行距
 * @author zhanyi
 */
(function(){
    
    var domUtils = baidu.editor.dom.domUtils;
    baidu.editor.commands['rowspacing'] =  {
        execCommand : function( cmdName,value ) {
            this.execCommand('paragraph','p',{'padding' : value + 'px 0'});
            return true;
        },
        queryCommandValue : function() {
            var startNode = this.selection.getStart(),
                pN = domUtils.findParent(startNode,function(node){return domUtils.isBlockElm(node)},true),
                value;
            //trace:1026
            if(pN){
                value = domUtils.getComputedStyle(pN,'padding-top').replace(/[^\d]/g,'');
                return value*1 <= 10 ? 0 : value;
            }
            return 0;
             
        }
    }

})();
