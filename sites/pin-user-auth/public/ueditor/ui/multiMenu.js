(function(){
    var utils = baidu.editor.utils,
        Mask = baidu.editor.ui.Mask,
        Popup = baidu.editor.ui.Popup,
        SplitButton = baidu.editor.ui.SplitButton,
        MultiMenuPop = baidu.editor.ui.MultiMenuPop = function(options){
            this.initOptions(options);
            this.initMultiMenu();
        };

    MultiMenuPop.prototype = {
        initMultiMenu: function (){
            this.initSplitButton();
            var me = this;
            this.popup = new Popup({
                content: '<iframe id="'+me.id+'_iframe" src="'+ this.iframeUrl +'" frameborder="0"></iframe>'
            });
            this.onbuttonclick = function(){
                this.showPopup();
            }

        }

    };

    utils.inherits(MultiMenuPop, SplitButton);
})();
