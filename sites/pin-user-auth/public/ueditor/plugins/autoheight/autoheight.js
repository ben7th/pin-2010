/**
 * @description 自动伸展
 * @author zhanyi
 */
(function() {

    var browser = baidu.editor.browser;

    baidu.editor.plugins['autoheight'] = function() {
        var editor = this;
        //提供开关，就算加载也可以关闭
        editor.autoHeightEnabled = this.options.autoHeightEnabled;
        
        var timer;
        var bakScroll;
        var bakOverflow;
        editor.enableAutoHeight = function (){
            var iframe = editor.iframe,
                doc = editor.document,
                minHeight = editor.options.minFrameHeight;

            function updateHeight(){
                editor.setHeight(Math.max( browser.ie ? doc.body.scrollHeight :
                        doc.body.offsetHeight + 20, minHeight ));
            }
            this.autoHeightEnabled = true;
            bakScroll = iframe.scroll;
            bakOverflow = doc.body.style.overflowY;
            iframe.scroll = 'no';
            doc.body.style.overflowY = 'hidden';
            timer = setTimeout(function (){
                updateHeight();
                timer = setTimeout(arguments.callee);
            });
            editor.fireEvent('autoheightchanged', this.autoHeightEnabled);
        };
        editor.disableAutoHeight = function (){
            var iframe = editor.iframe,
                doc = editor.document;
            iframe.scroll = bakScroll;
            doc.body.style.overflowY = bakOverflow;
            clearTimeout(timer);
            this.autoHeightEnabled = false;
            editor.fireEvent('autoheightchanged', this.autoHeightEnabled);
        };
        editor.addListener( 'ready', function() {
            if(this.autoHeightEnabled){
                editor.enableAutoHeight();
            }

        });
    }

})();
