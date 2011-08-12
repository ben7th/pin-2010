/**
 * 右键菜单
 * @function
 * @name baidu.editor.plugins.contextmenu
 * @author zhanyi
 */
(function (){
    var domUtils = baidu.editor.dom.domUtils;
         
    baidu.editor.plugins['contextmenu'] = function (){
        var me = this,
            menu,
            utils = baidu.editor.utils,
            items = baidu.editor.config.contextMenuItems;
        me.addListener('ready',function(){
            var uiUtils = baidu.editor.ui.uiUtils;
            domUtils.on(me.document, 'contextmenu', function (evt){
                var offset = uiUtils.getViewportOffsetByEvent(evt);
                if(menu)
                    menu.destroy();
                for(var i=0,ti,contextItems=[];ti=items[i];i++){

                    (function(item){
                        if(item == '-'){
                            contextItems[i] = item;
                        }else if(item.group){
                            for(var j=0,cj,subMenu = [];cj=item.subMenu[j];j++){
                                (function(subItem){
                                   subMenu[j] = subItem == '-' ? '-' :{
                                           'label':subItem.label,
                                            className: 'edui-for-'+subItem.cmdName+(subItem.value || ''),
                                            'onclick' :item.exec? function(){item.exec.call(me)} : function(){me.execCommand(subItem.cmdName,subItem.value)},
                                            'disabled' : me.queryCommandState(subItem.cmdName) == -1
                                    }
                                })(cj)

                            }
                            contextItems[i]={
                                'label' : item.group,
                                 className: 'edui-for-'+item.icon,
                                'subMenu' : {
                                    items: subMenu
                                }
                            }
                        }else{
                             contextItems[i] = {
                                'label':item.label,
                                 className: 'edui-for-'+item.cmdName + (item.value || ''),
                                onclick : item.exec? function(){item.exec.call(me)} : function(){me.execCommand(item.cmdName,item.value)},
                                disabled : me.queryCommandState(item.cmdName) == -1
                            }
                        }
                        
                    })(ti)
                }
                menu = new baidu.editor.ui.Menu({
                    items: contextItems
                });
                menu.render();
                menu.showAt(offset);
                evt.preventDefault ?  evt.preventDefault() : (evt.returnValue = false)
               
            });
        })




    };


})();
