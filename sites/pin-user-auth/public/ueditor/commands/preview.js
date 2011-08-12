baidu.editor.commands['preview'] = {
    execCommand : function(){
        var me = this;
        var w = window.open('', '_blank', "");
        var d = w.document;
        d.open();
        d.write('<html><head><title></title></head><body>' +
            me.getContent() +
            '</body></html>');
        d.close();
    },
    notNeedUndo : 1
};
//baidu.editor.contextMenuItems.push({
//    label : '预览',
//    cmdName : 'preview'
//});
