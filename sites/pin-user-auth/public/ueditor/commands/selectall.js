/**
 * 选中所有
 * @function
 * @name execCommand
 * @author zhanyi
*/
(function() {
    var browser = baidu.editor.browser;
    baidu.editor.commands['selectall'] = {
        execCommand : function(){
            this.document.execCommand('selectAll',false,null);
            //trace 1081
            !browser.ie && this.focus();
        },
        notNeedUndo : 1
    }
//    baidu.editor.contextMenuItems.push({
//        label : '全选',
//        cmdName : 'selectall'
//    })
})();

