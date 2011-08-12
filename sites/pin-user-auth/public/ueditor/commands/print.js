/**
 * @description 打印
 * @author zhanyi
 */
(function() {
    baidu.editor.commands['print'] = {
        execCommand : function(){
            this.window.print();
        },
        notNeedUndo : 1
    }
//    baidu.editor.contextMenuItems.push({
//        label : '打印',
//        cmdName : 'print'
//    })
})();

