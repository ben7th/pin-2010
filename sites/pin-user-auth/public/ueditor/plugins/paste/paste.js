/*
 ** @description 粘贴
 * @author zhanyi
 */
(function() {

	var domUtils = baidu.editor.dom.domUtils,
        browser = baidu.editor.browser;

    function getClipboardData( callback ) {

        var doc = this.document;

        if ( doc.getElementById( 'baidu_pastebin' ) ) {
            return;
        }

        var range = this.selection.getRange(),
            bk = range.createBookmark(),
            //创建剪贴的容器div
            pastebin = doc.createElement( 'div' );

        pastebin.id = 'baidu_pastebin';

        // Safari 要求div必须有内容，才能粘贴内容进来
        browser.webkit && pastebin.appendChild( doc.createTextNode( domUtils.fillChar + domUtils.fillChar ) );
        doc.body.appendChild( pastebin );
        pastebin.style.cssText = "position:absolute;width:1px;height:1px;overflow:hidden;left:-1000px;white-space:nowrap;top:" +
            //要在现在光标平行的位置加入，否则会出现跳动的问题
            domUtils.getXY( bk.start ).y + 'px';

        range.selectNodeContents( pastebin ).select( true );

        setTimeout( function() {
           
			pastebin.parentNode.removeChild(pastebin);
            range.moveToBookmark( bk ).select(true);
            callback( pastebin );
        }, 0 );


    }

    baidu.editor.plugins['paste'] = function() {
        var me = this;

        var pasteplain = me.options.pasteplain;

        me.commands['pasteplain'] = {
            queryCommandState: function (){
                return pasteplain;
            },
            execCommand: function (){
                pasteplain = !pasteplain|0;
            },
            notNeedUndo : 1
        };
        
        function filter(div){
            var html;
            if ( div.firstChild ) {
                    //去掉cut中添加的边界值
                    var nodes = domUtils.getElementsByTagName(div,'span');
                    for(var i=0,ni;ni=nodes[i++];){
                        if(ni.id == '_baidu_cut_start' || ni.id == '_baidu_cut_end'){
                            domUtils.remove(ni)
                        }
                    }


                    if(browser.webkit){
                        var divs = div.querySelectorAll('div #baidu_pastebin'),p;
                        for(var i=0,di;di=divs[i++];){
                            p = me.document.createElement('p');
                            while(di.firstChild){
                                p.appendChild(di.firstChild)
                            }
                            di.parentNode.insertBefore(p,di);
                            domUtils.remove(di,true)
                        }
                        var spans = div.querySelectorAll('span.Apple-style-span');
                        for(var i=0,ci;ci=spans[i++];){
                            domUtils.remove(ci,true);
                        };
                        var metas = div.querySelectorAll('meta');
                        for(var i=0,ci;ci=metas[i++];){
                            domUtils.remove(ci);
                        };
                        //<div><br></div>会造成多余的空行
                        var brs = div.querySelectorAll('div br');
                        for(var i=0,bi;bi=brs[i++];){
                            var pN = bi.parentNode;
                            if(pN.tagName == 'DIV' && pN.childNodes.length ==1){
                                domUtils.remove(pN)
                            }
                        }

                    }
                    if(browser.gecko){
                        var dirtyNodes = div.querySelectorAll('[_moz_dirty]')
                        for(i=0;ci=dirtyNodes[i++];){
                            ci.removeAttribute( '_moz_dirty' )
                        }
                    }

                    //if(!pasteplain){
                        html = div.innerHTML;

                        var f = me.serialize;
                        if(f){
                            var node =  f.transformInput(
                                        f.parseHTML(
                                            f.word(html), true
                                        )
                                    );
                            //trace:924
                            //纯文本模式也要保留段落
                            node = f.filter(node,pasteplain ? {
                                whiteList: {
                                    'p': {$:{}}
                                },
                                blackList: {
                                    'style':1,
                                    'script':1,
                                    'object':1
                                }
                            } :  null);

                            if(browser.webkit){
                                var length = node.children.length,
                                    child;
                                while((child = node.children[length-1]) && child.tag == 'br'){
                                    node.children.splice(length-1,1);
                                    length = node.children.length;
                                }
                            }
                            html = f.toHTML(node)

                        }
//                        }else{
//                            html = div[browser.ie ? 'innerText':'textContent'];
//                        }
                    //自定义的处理
                    me.fireEvent('beforepaste',html);
                    me.execCommand( 'insertHtml',html);

                }
        }
        
        me.addListener('ready',function(){
            domUtils.on(me.body,'cut',function(){

                var range = me.selection.getRange();
                if(!range.collapsed && me.undoManger){
                    me.undoManger.save()
                }
                //修正剪切不能把整个元素剪切出来
                range = me.selection.getRange();
                if( !range.collapsed){
                    var mStart = 0,
                        mEnd = 0;
                    while(!range.startOffset && !domUtils.isBody(range.startContainer)){
                        mStart = 1;
                        range.setStartBefore(range.startContainer);
                    }
                    while(!domUtils.isBody(range.endContainer) && range.endOffset == (range.endContainer.nodeType == 1 ? range.endContainer.childNodes.length : range.endContainer.nodeValue.length)){
                        mEnd = 1;
                        range.setEndAfter(range.endContainer);
                        if(browser.webkit){
                            var child = range.endContainer.childNodes[range.endOffset];
                            if(child && child.nodeType == 1 && child.tagName == 'BR' && range.endContainer.lastChild === child){
                                range.setEndAfter(child);
                            }
                        }
                        
                    }
                    if(mStart){
                        var start = me.document.createElement('span');
                        start.innerHTML = 'start';
                        start.id = '_baidu_cut_start';
                        range.insertNode(start).setStartBefore(start)
                    }
                    if(mEnd){
                        var end = me.document.createElement('span');
                        end.innerHTML = 'end';
                        end.id = '_baidu_cut_end';
                        range.cloneRange().collapse(false).insertNode(end);
                        range.setEndAfter(end)

                    }
                    range.select();
                    if(browser.ie){
                        setTimeout(function(){
                            var node = me.document.getElementById('_baidu_cut_end');
                            node && domUtils.remove(node)
                        },50)
                    }

                }
            });
            domUtils.on(me.body, browser.ie ? 'beforepaste' : 'paste',function(e){
                 getClipboardData.call( me, function( div ) {
                        filter(div);

                    } );
               

            })
        });

    }

})();

