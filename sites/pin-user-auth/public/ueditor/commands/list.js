/**
 * @description 列表
 * @author zhanyi
 */
(function() {
    var domUtils = baidu.editor.dom.domUtils,
        browser = baidu.editor.browser,
        webkit = browser.webkit,
        gecko = browser.gecko;
    baidu.editor.commands['insertorderedlist'] = baidu.editor.commands['insertunorderedlist'] = {
        execCommand : function( command, style ) {

            var me = this,
                parent = domUtils.findParentByTagName( this.selection.getStart(), command.toLowerCase() == 'insertorderedlist' ? 'ol' : 'ul', true ),
                doc = this.document,
                range,flag=1;
            if(browser.ie){
                var start = me.selection.getStart(),
                    blockquote = domUtils.findParent(start,function(node){return node.tagName == 'BLOCKQUOTE'}),
                    hasBlockquote = 0;
                if(blockquote)
                    hasBlockquote = 1;
            }

            style = style && style.toLowerCase() || (command == 'insertorderedlist' ? 'decimal' : 'disc');

            range = me.selection.getRange();

            if(parent && !range.collapsed){
                var eParent = domUtils.findParentByTagName(range.endContainer,command.toLowerCase() == 'insertorderedlist' ? 'ol' : 'ul',true);
                if(!eParent){
                    flag = 0
                }
            }
            

            doc.execCommand( command, false, null );

            if( parent && domUtils.getStyle( parent, 'list-style-type' ) != style && flag){

                doc.execCommand( command, false, null );
            }
            parent = domUtils.findParentByTagName( this.selection.getStart(), command.toLowerCase() == 'insertorderedlist' ? 'ol' : 'ul', true );
            if ( parent ) {
                
               
                if ( webkit ) {
                    var lis = parent.getElementsByTagName( 'li' );
//                    for ( var i = 0,ci; ci = lis[i++]; ) {
//                        ci = ci.lastChild;
//                        if ( ci.nodeType == 1 && ci.tagName.toLowerCase() == 'br' )
//                            domUtils.remove( ci );
//                    }

                    if ( parent.parentNode.tagName.toLowerCase() == 'p' ) {
                        range = this.selection.getRange();
                        var bookmark = range.createBookmark();
                        domUtils.remove( parent.parentNode, true );
                        range.moveToBookmark(bookmark).select()

                    }
                }
                var pre = parent.previousSibling;

                if(pre && pre.nodeType == 1 && pre.tagName == parent.tagName &&
                    style == domUtils.getStyle( pre, 'list-style-type' )){
                    range = me.selection.getRange();
                    var bookmark = range.createBookmark();
                    while(parent.firstChild){
                        pre.appendChild(parent.firstChild)
                    }
                    domUtils.remove(parent);
                    range.moveToBookmark(bookmark).select();
                    return 1;
                }

                if ( gecko ) {
                    parent.removeAttribute( '_moz_dirty' );
                    var nodes = parent.getElementsByTagName( '*' );
                    for ( var i = 0,ci; ci = nodes[i++]; ) {
                        ci.removeAttribute( '_moz_dirty' );
                    }
                }
                parent.style.listStyleType = style;
                if(browser.ie && hasBlockquote && !domUtils.findParent(parent,function(node){return node.tagName == 'BLOCKQUOTE'})){
                    var pp = domUtils.findParent(parent,function(node){return node.tagName == command.toLowerCase() == 'insertorderedlist' ? 'OL' : 'UL'});
                    if(pp){
                        blockquote.innerHTML = '';
                        while(pp.firstChild){
                            blockquote.appendChild(pp.firstChild)
                        }
                        pp.parentNode.insertBefore(blockquote,pp);
                        domUtils.remove(pp)
                    }
                }
                //修正chrome下h1套ol/ul导致标号看不到
                if(browser.webkit){
                    var h = domUtils.findParentByTagName(parent,[ 'h1', 'h2', 'h3', 'h4', 'h5', 'h6']);
                    if(h){
                        range = me.selection.getRange();
                        var bk = range.createBookmark(),
                            lis = domUtils.getElementsByTagName(parent,'li');
                        for(var i=0,li;li=lis[i++];){
                            var tmp = h.cloneNode(false);
                            while(li.firstChild){
                                tmp.appendChild(li.firstChild);
                            }
                            li.appendChild(tmp)
                        }
                        domUtils.remove(h,true);
                        range.moveToBookmark(bk).select()
                    }
                }
            }


        },
        queryCommandState : function( command ) {

            var startNode = this.selection.getStart();
           
            return domUtils.findParentByTagName( startNode, command.toLowerCase() == 'insertorderedlist' ? 'ol' : 'ul', true ) ? 1 : 0;
        },
        queryCommandValue : function( command ) {

            var startNode = this.selection.getStart(),
                node = domUtils.findParentByTagName( startNode, command.toLowerCase() == 'insertorderedlist' ? 'ol' : 'ul', true );
          
            return node ? domUtils.getStyle( node, 'list-style-type' ) : null;
        }
    }
//    baidu.editor.contextMenuItems.push({
//        group : '列表',
//        subMenu : [
//            {
//                label: '有序列表',
//                cmdName : 'insertorderedlist',
//                value : 'decimal'
//            },
//            {
//                label: '无序列表',
//                cmdName : 'insertunorderedlist',
//                value : 'disc'
//            }
//        ]
//    });

})();
