/**
 * 首行缩进
 * @function
 * @name baidu.editor.commands.indent
 * @author zhanyi
 */
(function (){
    var domUtils = baidu.editor.dom.domUtils;
    baidu.editor.commands['outdent'] = baidu.editor.commands['indent'] = {
        execCommand : function(cmd) {
             var me = this,
                 value = cmd.toLowerCase() == 'outdent' ? '0em' : (me.options.indentValue || '2em');
             me.execCommand('Paragraph','p',{'textIndent':value});
        }

    };
//    baidu.editor.contextMenuItems.push('-',{
//        label : '首行缩进',
//        cmdName : 'indent'
//    },{
//        label : '取消缩进',
//        cmdName : 'outdent'
//    },'-')
})();
