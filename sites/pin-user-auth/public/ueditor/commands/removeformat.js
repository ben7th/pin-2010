/**
 * @description 清除样式
 * @author zhanyi
 */
(function() {

    var domUtils = baidu.editor.dom.domUtils,
        dtd = baidu.editor.dom.dtd;
    baidu.editor.commands['removeformat'] = {
        execCommand : function( cmdName, tags, style, attrs,notIncludeA ) {
            var tagReg = new RegExp( '^(?:' + (tags || this.options.removeFormatTags).replace( /,/g, '|' ) + ')$', 'i' ) ,
                removeFormatAttributes = style ? [] : (attrs || this.options.removeFormatAttributes).split( ',' ),
                range = new baidu.editor.dom.Range( this.document ),
                bookmark,node,parent,
                filter = function( node ) {
                    return node.nodeType == 1;
                };

            function doRemove( range ) {
                
                var bookmark1 = range.createBookmark();
                if ( range.collapsed ) {
                    range.enlarge( true );
                }

             //不能把a标签切了
                if(!notIncludeA){
                    var aNode = domUtils.findParentByTagName(range.startContainer,'a',true);
                    if(aNode){
                        range.setStartBefore(aNode)
                    }

                    aNode = domUtils.findParentByTagName(range.endContainer,'a',true);
                    if(aNode){
                        range.setEndAfter(aNode)
                    }

                }
              
                
                bookmark = range.createBookmark();

                node = bookmark.start;
                //切开始
                while ( (parent = node.parentNode) && !domUtils.isBlockElm( parent ) ) {
                    domUtils.breakParent( node, parent );
                    domUtils.clearEmptySibling( node );
                }
                if ( bookmark.end ) {
                    //切结束
                    node = bookmark.end;
                    while ( (parent = node.parentNode) && !domUtils.isBlockElm( parent ) ) {
                        domUtils.breakParent( node, parent );
                        domUtils.clearEmptySibling( node );
                    }

                    //开始去除样式
                    var current = domUtils.getNextDomNode( bookmark.start, false, filter ),
                        next;
                    while ( current ) {
                        if ( current == bookmark.end ) {
                            break;
                        }

                        next = domUtils.getNextDomNode( current, true, filter );

                        if ( !dtd.$empty[current.tagName.toLowerCase()] && !domUtils.isBookmarkNode( current ) ) {
                            if ( tagReg.test( current.tagName ) ) {
                                if ( style ) {
                                    domUtils.removeStyle( current, style );
                                    if ( domUtils.isRedundantSpan( current ) && style != 'text-decoration')
                                        domUtils.remove( current, true );
                                } else {
                                    current.tagName != 'A' && domUtils.remove( current, true )
                                }
                            } else {

                                if(!dtd.$tableContent[current.tagName]){
                                    domUtils.removeAttributes( current, removeFormatAttributes );
                                    if ( domUtils.isRedundantSpan( current ) )
                                        domUtils.remove( current, true );
                                }else{

                                }


                            }
                        }
                        current = next;
                    }
                }
                //trace:1035
                if(domUtils.isBlockElm(bookmark.start.parentNode)){
                    domUtils.removeAttributes(  bookmark.start.parentNode,removeFormatAttributes );
                }
                if(bookmark.end && domUtils.isBlockElm(bookmark.end.parentNode)){
                    domUtils.removeAttributes(  bookmark.end.parentNode,removeFormatAttributes );
                }
                range.moveToBookmark( bookmark ).moveToBookmark(bookmark1);
                //清除冗余的代码 <b><bookmark></b>
                var node = range.startContainer,
                    tmp,
                    collapsed = range.collapsed;
                while(node.nodeType == 1 && node.childNodes.length == 0 && dtd.$removeEmpty[node.tagName]){
                    tmp = node.parentNode;
                    range.setStartBefore(node);
                    //trace:937
                    //更新结束边界
                    if(range.startContainer === range.endContainer){
                        range.endOffset--;
                    }
                    domUtils.remove(node);
                    node = tmp;
                }
             
                if(!collapsed){
                    node = range.endContainer;
                    while(node.nodeType == 1 && node.childNodes.length == 0 && dtd.$removeEmpty[node.tagName]){
                        tmp = node.parentNode;
                        range.setEndBefore(node);
                        domUtils.remove(node);

                        node = tmp;
                    }


                }
            }

            if ( this.currentSelectedArr && this.currentSelectedArr.length ) {
                for ( var i = 0,ci; ci = this.currentSelectedArr[i++]; ) {
                    range.selectNodeContents( ci );
                    doRemove( range );
                }
                range.selectNodeContents( this.currentSelectedArr[0] ).select();
            } else {
                
                range = this.selection.getRange();
                doRemove( range );
                range.select();
            }
        }

    }
//    baidu.editor.contextMenuItems.push({
//        label : '清除样式',
//        cmdName : 'removeformat'
//    })
})();