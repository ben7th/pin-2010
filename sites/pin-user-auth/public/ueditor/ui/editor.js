(function (){
    var utils = baidu.editor.utils,
        uiUtils = baidu.editor.ui.uiUtils,
        UIBase = baidu.editor.ui.UIBase;

    var defaultToolbars = baidu.editor.config.defaultToolbars;

    function EditorUI(options){
        this.initOptions(options);
        this.initEditorUI();
    }
    EditorUI.prototype = {
        uiName: 'editor',
        elementPathEnabled: true,
        initEditorUI: function (){
            this.initUIBase();
            this._initToolbars();
            var editor = this.editor;
            editor.addListener('ready', function (){
                editor.fireEvent('beforeselectionchange');
                editor.fireEvent('selectionchange');
            });
            editor.addListener('mousedown', function (t, evt){
                var el = evt.target || evt.srcElement;
                baidu.editor.ui.Popup.postHide(el);
            });
            var me = this;
            editor.addListener('selectionchange', function (){
                me._updateElementPath();
            });
            editor.addListener('sourcemodechanged', function (t, mode){
                if (mode) {
                    me.disableElementPath();
                } else {
                    me.enableElementPath();
                }
            });
            // 超链接的编辑器浮层
            var linkDialog = new baidu.editor.ui.Dialog({
                iframeUrl: uiUtils.mapUrl(baidu.editor.config.defaultIframeUrlMap.link),
                autoReset: true,
                draggable: true,
                editor: editor,
                className: 'edui-for-link',
                title: '超链接',
                buttons: [{
                    className: 'edui-okbutton',
                    label: '确认',
                    onclick: function (){
                        linkDialog.close(true);
                    }
                }, {
                    className: 'edui-cancelbutton',
                    label: '取消',
                    onclick: function (){
                        linkDialog.close(false);
                    }
                }],
                onok: function (){},
                oncancel: function (){},
                onclose: function (t,ok){
                    if (ok) {
                        return this.onok();
                    } else {
                        return this.oncancel();
                    }
                }

            });
            linkDialog.render();
            // 图片的编辑器浮层
            var imgDialog = new baidu.editor.ui.Dialog({
                iframeUrl: uiUtils.mapUrl(baidu.editor.config.defaultIframeUrlMap.image),
                autoReset: true,
                draggable: true,
                editor: editor,
                className: 'edui-for-image',
                title: '图片',
                buttons: [{
                    className: 'edui-okbutton',
                    label: '确认',
                    onclick: function (){
                        imgDialog.close(true);
                    }
                }, {
                    className: 'edui-cancelbutton',
                    label: '取消',
                    onclick: function (){
                        imgDialog.close(false);
                    }
                }],
                onok: function (){},
                oncancel: function (){},
                onclose: function (t,ok){
                    if (ok) {
                        return this.onok();
                    } else {
                        return this.oncancel();
                    }
                }

            });
            imgDialog.render();
            //锚点
            var anchorDialog = new baidu.editor.ui.Dialog({
                iframeUrl: uiUtils.mapUrl(baidu.editor.config.defaultIframeUrlMap.anchor),
                autoReset: true,
                draggable: true,
                editor: editor,
                className: 'edui-for-anchor',
                title: '锚点',
                buttons: [{
                    className: 'edui-okbutton',
                    label: '确认',
                    onclick: function (){
                        anchorDialog.close(true);
                    }
                }, {
                    className: 'edui-cancelbutton',
                    label: '取消',
                    onclick: function (){
                        anchorDialog.close(false);
                    }
                }],
                onok: function (){},
                oncancel: function (){},
                onclose: function (t,ok){
                    if (ok) {
                        return this.onok();
                    } else {
                        return this.oncancel();
                    }
                }

            });
            anchorDialog.render();
            // video
            var videoDialog = new baidu.editor.ui.Dialog({
                iframeUrl: uiUtils.mapUrl(baidu.editor.config.defaultIframeUrlMap.video),
                autoReset: true,
                draggable: true,
                editor: editor,
                className: 'edui-for-video',
                title: '视频',
                buttons: [{
                    className: 'edui-okbutton',
                    label: '确认',
                    onclick: function (){
                        videoDialog.close(true);
                    }
                }, {
                    className: 'edui-cancelbutton',
                    label: '取消',
                    onclick: function (){
                        videoDialog.close(false);
                    }
                }],
                onok: function (){},
                oncancel: function (){},
                onclose: function (t,ok){
                    if (ok) {
                        return this.onok();
                    } else {
                        return this.oncancel();
                    }
                }

            });
            videoDialog.render();
            // map
            var mapDialog = new baidu.editor.ui.Dialog({
                iframeUrl: uiUtils.mapUrl(baidu.editor.config.defaultIframeUrlMap.map),
                autoReset: true,
                draggable: true,
                editor: editor,
                className: 'edui-for-map',
                title: '地图',
                buttons: [{
                    className: 'edui-okbutton',
                    label: '确认',
                    onclick: function (){
                        mapDialog.close(true);
                    }
                }, {
                    className: 'edui-cancelbutton',
                    label: '取消',
                    onclick: function (){
                        mapDialog.close(false);
                    }
                }],
                onok: function (){},
                oncancel: function (){},
                onclose: function (t,ok){
                    if (ok) {
                        return this.onok();
                    } else {
                        return this.oncancel();
                    }
                }

            });
            mapDialog.render();
            // map
            var gmapDialog = new baidu.editor.ui.Dialog({
                iframeUrl: uiUtils.mapUrl(baidu.editor.config.defaultIframeUrlMap.gmap),
                autoReset: true,
                draggable: true,
                editor: editor,
                className: 'edui-for-gmap',
                title: 'Google地图',
                buttons: [{
                    className: 'edui-okbutton',
                    label: '确认',
                    onclick: function (){
                        gmapDialog.close(true);
                    }
                }, {
                    className: 'edui-cancelbutton',
                    label: '取消',
                    onclick: function (){
                        gmapDialog.close(false);
                    }
                }],
                onok: function (){},
                oncancel: function (){},
                onclose: function (t,ok){
                    if (ok) {
                        return this.onok();
                    } else {
                        return this.oncancel();
                    }
                }

            });
            gmapDialog.render();
            var popup = new baidu.editor.ui.Popup({
                content: '',
                className: 'edui-bubble',
                _onEditButtonClick: function (){
                    this.hide();
                    linkDialog.open();
                },
                _onImgEditButtonClick: function (){
                    this.hide();
                    var nodeStart = editor.selection.getRange().getClosedNode();
                    var img = baidu.editor.dom.domUtils.findParentByTagName(nodeStart,"img",true);
                    if(img && img.className.indexOf("edui-faked-video") != -1){
                        videoDialog.open();
                    }else if(img && img.src.indexOf("http://api.map.baidu.com")!=-1){
                        mapDialog.open();
                    }else if(img && img.src.indexOf("http://maps.google.com/maps/api/staticmap")!=-1){
                        gmapDialog.open();
                    }else if(img && img.getAttribute("anchorname")){
                        anchorDialog.open();
                    }else{
                        imgDialog.open();
                    }

                },
                _onImgSetFloat: function(event,value){
                    var nodeStart = editor.selection.getRange().getClosedNode();
                    var img = baidu.editor.dom.domUtils.findParentByTagName(nodeStart,"img",true);
                    if(img){
                        switch(value){
                            case -2:
                                if(!!window.ActiveXObject){
                                    img.style.removeAttribute("display");
                                    img.style.styleFloat = "";
                                }else{
                                    img.style.removeProperty("display");
                                    img.style.cssFloat = "";
                                }
                                break;
                            case -1:
                                if(!!window.ActiveXObject){
                                    img.style.removeAttribute("display");
                                    img.style.styleFloat = "left";
                                }else{
                                    img.style.removeProperty("display");
                                    img.style.cssFloat = "left";
                                }
                                break;
                            case 1:
                                if(!!window.ActiveXObject){
                                    img.style.removeAttribute("display");
                                    img.style.styleFloat = "right";
                                }else{
                                    img.style.removeProperty("display");
                                    img.style.cssFloat = "right";
                                }
                                break;
                            case 2:
                                if(!!window.ActiveXObject){
                                    img.style.styleFloat = "";
                                    img.style.display = "block";
                                }else{
                                    img.style.cssFloat = "";
                                    img.style.display = "block";
                                }

                        }
                        this.showAnchor(img);
                    }
                },
                _onRemoveButtonClick: function (){
                    var nodeStart = editor.selection.getRange().getClosedNode();
                    var img = baidu.editor.dom.domUtils.findParentByTagName(nodeStart,"img",true);
                    if(img && img.getAttribute("anchorname")){
                        editor.execCommand("anchor");
                    }else{
                        editor.execCommand('unlink');
                    }
                    this.hide();
                },
                queryAutoHide: function (el){
                    if (el && el.ownerDocument == editor.document) {
                        if (el.tagName.toLowerCase() == 'img' || baidu.editor.dom.domUtils.findParentByTagName(el, 'a', true)) {
                            return el !== popup.anchorEl;
                        }
                    }
                    return baidu.editor.ui.Popup.prototype.queryAutoHide.call(this, el);
                }
            });
            popup.render();
            editor.addListener('selectionchange', function (t, evt){
                var html = '';
                var img = editor.selection.getRange().getClosedNode();
                var imglink = baidu.editor.dom.domUtils.findParentByTagName(img,"a",true);
                if(imglink != null){
                    html += popup.formatHtml(
                        '<nobr>属性: <span class="edui-unclickable">默认</span>&nbsp;&nbsp;<span class="edui-unclickable">左浮动</span>&nbsp;&nbsp;<span class="edui-unclickable">右浮动</span>&nbsp;&nbsp;'+
                        '<span class="edui-unclickable">独占一行</span>' +
                        ' <span onclick="$$._onImgEditButtonClick(event, this);" class="edui-clickable">修改</span></nobr>');
                }else if(img != null && img.tagName.toLowerCase() == 'img'){
                    if(img.getAttribute('anchorname')){
                        //锚点处理
                        html += popup.formatHtml(
                        '<nobr>属性: <span onclick=$$._onImgEditButtonClick(event) class="edui-clickable">修改</span>&nbsp;&nbsp;<span onclick=$$._onRemoveButtonClick(event) class="edui-clickable">删除</span></nobr>');
                    }else{
                        html += popup.formatHtml(
                            '<nobr>属性: <span onclick=$$._onImgSetFloat(event,-2) class="edui-clickable">默认</span>&nbsp;&nbsp;<span onclick=$$._onImgSetFloat(event,-1) class="edui-clickable">左浮动</span>&nbsp;&nbsp;<span onclick=$$._onImgSetFloat(event,1) class="edui-clickable">右浮动</span>&nbsp;&nbsp;'+
                            '<span onclick=$$._onImgSetFloat(event,2) class="edui-clickable">独占一行</span>' +
                            ' <span onclick="$$._onImgEditButtonClick(event, this);" class="edui-clickable">修改</span></nobr>');
                    }
                }
                var link;
                if(editor.selection.getRange().collapsed){
                    link = editor.queryCommandValue("link");
                }else{
                    link = editor.selection.getStart();
                }
                link = baidu.editor.dom.domUtils.findParentByTagName(link,"a",true);
                var url;
                if (link != null && (url = link.getAttribute('href', 2)) != null) {
                    var txt = url;
                    if(url.length>30){
                        txt = url.substring(0,20)+"...";
                    }
                    if (html) {
                        html += '<div style="height:5px;"></div>'
                    }
                    html += popup.formatHtml(
                        '<nobr>链接: <a target="_blank" href="'+ url +'" title="'+url+'" >' + txt + '</a>' +
                        ' <span class="edui-clickable" onclick="$$._onEditButtonClick(event, this);">修改</span>' +
                        ' <span class="edui-clickable" onclick="$$._onRemoveButtonClick(event, this);"> 清除</span></nobr>');
                    popup.showAnchor(link);
                }
                if (html) {
                    popup.getDom('content').innerHTML = html;
                    popup.anchorEl = img || link;
                    popup.showAnchor(popup.anchorEl);
                } else {
                    popup.hide();
                }
            });
        },
        _initToolbars: function (){
            var editor = this.editor;
            var toolbars = this.toolbars || defaultToolbars;
            var toolbarUis = [];
            for (var i=0; i<toolbars.length; i++) {
                var toolbar = toolbars[i];
                var toolbarUi = new baidu.editor.ui.Toolbar();
                for (var j=0; j<toolbar.length; j++) {
                    var toolbarItem = toolbar[j];
                    var toolbarItemUi = null;
                    if (typeof toolbarItem == 'string') {
                        if (toolbarItem == '|') {
                            toolbarItem = 'Separator';
                        }
                        if (baidu.editor.ui[toolbarItem]) {
                            toolbarItemUi = new baidu.editor.ui[toolbarItem](editor);
                        }
                    } else {
                        toolbarItemUi = toolbarItem;
                    }
                    if (toolbarItemUi) {
                        toolbarUi.add(toolbarItemUi);
                    }
                }
                toolbarUis[i] = toolbarUi;
            }
            this.toolbars = toolbarUis;
        },
        getHtmlTpl: function (){
            return '<div id="##" class="%%">' +
                '<div id="##_toolbarbox" class="%%-toolbarbox">' +
                 '<div id="##_toolbarboxouter" class="%%-toolbarboxouter"><div class="%%-toolbarboxinner">' +
                  this.renderToolbarBoxHtml() +
                 '</div></div>' +
                 '<div id="##_toolbarmsg" class="%%-toolbarmsg" style="display:none;">' +
                  '<div class="%%-toolbarmsg-close" onclick="$$.hideToolbarMsg();">x</div>' +
                  '<div id="##_toolbarmsg_label" class="%%-toolbarmsg-label"></div>' +
                  '<div style="height:0;overflow:hidden;clear:both;"></div>' +
                 '</div>' +
                '</div>' +
                '<div id="##_iframeholder" class="%%-iframeholder"></div>' +
                '<div id="##_bottombar" class="%%-bottombar"></div>' +
                '</div>';
        },
        renderToolbarBoxHtml: function (){
            var buff = [];
            for (var i=0; i<this.toolbars.length; i++) {
                buff.push(this.toolbars[i].renderHtml());
            }
            return buff.join('');
        },
        setFullScreen: function (fullscreen){
            if (this._fullscreen != fullscreen) {
                this._fullscreen = fullscreen;
                this.editor.fireEvent('beforefullscreenchange', fullscreen);
                if (fullscreen) {
                    this._bakHtmlOverflow = document.documentElement.style.overflow;
                    this._bakBodyOverflow = document.body.style.overflow;
                    this._bakAutoHeight = this.editor.autoHeightEnabled;
                    this._bakScrollTop = Math.max(document.documentElement.scrollTop, document.body.scrollTop);
                    if (this._bakAutoHeight) {
                        this.editor.disableAutoHeight();
                    }
                    document.documentElement.style.overflow = 'hidden';
                    document.body.style.overflow = 'hidden';
                    this._bakCssText = this.getDom().style.cssText;
                    this._bakCssText1 = this.getDom('iframeholder').style.cssText;
                    this._updateFullScreen();
                } else {
                    document.documentElement.style.overflow = this._bakHtmlOverflow;
                    document.body.style.overflow = this._bakBodyOverflow;
                    this.getDom().style.cssText = this._bakCssText;
                    this.getDom('iframeholder').style.cssText = this._bakCssText1;
                    if (this._bakAutoHeight) {
                        this.editor.enableAutoHeight();
                    }
                    window.scrollTo(0, this._bakScrollTop);
                }
                this.editor.fireEvent('fullscreenchanged', fullscreen);
            }
        },
        _updateFullScreen: function (){
            if (this._fullscreen) {
                var vpRect = baidu.editor.ui.uiUtils.getViewportRect();
                this.getDom().style.cssText = 'border:0;position:absolute;left:0;top:0;width:'+vpRect.width+'px;height:'+vpRect.height+'px;';
                baidu.editor.ui.uiUtils.setViewportOffset(this.getDom(), { left: 0, top: 0 });
                this.editor.setHeight(vpRect.height - this.getDom('toolbarbox').offsetHeight - this.getDom('bottombar').offsetHeight);
            }
        },
        _updateElementPath: function (){
            if (this.elementPathEnabled) {
                var list = this.editor.queryCommandValue('elementpath');
                var buff = [];
                for(var i=0,ci;ci=list[i];i++){
                    buff[i] = this.formatHtml('<span unselectable="on" onclick="$$.editor.execCommand(&quot;elementpath&quot;, &quot;'+ i +'&quot;);">' + ci + '</span>');
                }
                this.getDom('bottombar').innerHTML = '<div class="edui-editor-breadcrumb" onmousedown="return false;">path: ' + buff.join(' &gt; ') + '</div>';
            }
        },
        disableElementPath: function (){
            this.getDom('bottombar').innerHTML = '';
            this.elementPathEnabled = false;
        },
        enableElementPath: function (){
            this.elementPathEnabled = true;
            this._updateElementPath();
        },
        isFullScreen: function (){
            return this._fullscreen;
        },
        postRender: function (){
            UIBase.prototype.postRender.call(this);
            for (var i=0; i<this.toolbars.length; i++) {
                this.toolbars[i].postRender();
            }
            var me = this;
            baidu.editor.dom.domUtils.on(window, 'resize', function (){
                setTimeout(function (){
                    me._updateFullScreen();
                });
            });
        },
        showToolbarMsg: function (msg){
            this.getDom('toolbarmsg_label').innerHTML = msg;
            this.getDom('toolbarmsg').style.display = '';
        },
        hideToolbarMsg: function (){
            this.getDom('toolbarmsg').style.display = 'none';
        }
    };
    utils.inherits(EditorUI, baidu.editor.ui.UIBase);

    baidu.editor.ui.Editor = function (options){
        options = options || {};
        var editor = new baidu.editor.Editor(options);
        var uiOptions = options.ui || {};
        if (options.id) {
            uiOptions.id = options.id;
        }
        uiOptions.editor = editor;
        editor.ui = new EditorUI(uiOptions);
        var oldRender = editor.render;
        editor.render = function (holder){
            editor.ui.render(holder);
            var iframeholder = editor.ui.getDom('iframeholder');
            return oldRender.call(this, iframeholder);
        };
        return editor;
    };
})();