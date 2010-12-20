(function(a){a.fn.extend({autocomplete:function(d,b){var j=typeof d=="string";b=a.extend({},a.Autocompleter.defaults,{url:j?d:null,data:j?null:d,delay:j?a.Autocompleter.defaults.delay:10,max:b&&!b.scroll?10:150},b);b.highlight=b.highlight||function(k){return k};b.formatMatch=b.formatMatch||b.formatItem;return this.each(function(){new a.Autocompleter(this,b)})},result:function(d){return this.bind("result",d)},search:function(d){return this.trigger("search",[d])},flushCache:function(){return this.trigger("flushCache")},
setOptions:function(d){return this.trigger("setOptions",[d])},unautocomplete:function(){return this.trigger("unautocomplete")}});a.Autocompleter=function(d,b){function j(){var f=r.selected();if(!f)return false;var p=f.result;o=p;if(b.multiple){var t=s(c.val());if(t.length>1){var y=b.multipleSeparator.length,A=a(d).selection().start,w,v=0;a.each(t,function(C,B){v+=B.length;if(A<=v){w=C;return false}v+=y});t[w]=p;p=t.join(b.multipleSeparator)}p+=b.multipleSeparator}c.val(p);n();c.trigger("result",[f.data,
f.value]);return true}function k(f,p){if(l==g.DEL)r.hide();else{var t=c.val();if(!(!p&&t==o)){o=t;t=m(t);if(t.length>=b.minChars){c.addClass(b.loadingClass);b.matchCase||(t=t.toLowerCase());i(t,e,n)}else{c.removeClass(b.loadingClass);r.hide()}}}}function s(f){if(!f)return[""];if(!b.multiple)return[a.trim(f)];return a.map(f.split(b.multipleSeparator),function(p){return a.trim(f).length?a.trim(p):null})}function m(f){if(!b.multiple)return f;var p=s(f);if(p.length==1)return p[0];p=a(d).selection().start;
p=p==f.length?s(f):s(f.replace(f.substring(p),""));return p[p.length-1]}function n(){r.visible();r.hide();clearTimeout(h);c.removeClass(b.loadingClass);b.mustMatch&&c.search(function(f){if(!f)if(b.multiple){f=s(c.val()).slice(0,-1);c.val(f.join(b.multipleSeparator)+(f.length?b.multipleSeparator:""))}else{c.val("");c.trigger("result",null)}})}function e(f,p){if(p&&p.length&&q){c.removeClass(b.loadingClass);r.display(p,f);var t=p[0].value;if(b.autoFill&&m(c.val()).toLowerCase()==f.toLowerCase()&&l!=
g.BACKSPACE){c.val(c.val()+t.substring(m(o).length));a(d).selection(o.length,o.length+t.length)}r.show()}else n()}function i(f,p,t){b.matchCase||(f=f.toLowerCase());var y=u.load(f);if(y&&y.length)p(f,y);else if(typeof b.url=="string"&&b.url.length>0){var A={timestamp:+new Date};a.each(b.extraParams,function(w,v){A[w]=typeof v=="function"?v():v});a.ajax({mode:"abort",port:"autocomplete"+d.name,dataType:b.dataType,url:b.url,data:a.extend({q:m(f),limit:b.max},A),success:function(w){var v;if(!(v=b.parse&&
b.parse(w))){v=[];w=w.split("\n");for(var C=0;C<w.length;C++){var B=a.trim(w[C]);if(B){B=B.split("|");v[v.length]={data:B,value:B[0],result:b.formatResult&&b.formatResult(B,B[0])||B[0]}}}v=v}v=v;u.add(f,v);p(f,v)}})}else{r.emptyList();t(f)}}var g={UP:38,DOWN:40,DEL:46,TAB:9,RETURN:13,ESC:27,COMMA:188,PAGEUP:33,PAGEDOWN:34,BACKSPACE:8},c=a(d).attr("autocomplete","off").addClass(b.inputClass),h,o="",u=a.Autocompleter.Cache(b),q=0,l,x={mouseDownOnSelect:false},r=a.Autocompleter.Select(b,d,j,x),z;a.browser.opera&&
a(d.form).bind("submit.autocomplete",function(){if(z)return z=false});c.bind((a.browser.opera?"keypress":"keydown")+".autocomplete",function(f){q=1;l=f.keyCode;switch(f.keyCode){case g.UP:f.preventDefault();r.visible()?r.prev():k(0,true);break;case g.DOWN:f.preventDefault();r.visible()?r.next():k(0,true);break;case g.PAGEUP:f.preventDefault();r.visible()?r.pageUp():k(0,true);break;case g.PAGEDOWN:f.preventDefault();r.visible()?r.pageDown():k(0,true);break;case b.multiple&&a.trim(b.multipleSeparator)==
","&&g.COMMA:case g.TAB:case g.RETURN:if(j()){f.preventDefault();z=true;return false}break;case g.ESC:r.hide();break;default:clearTimeout(h);h=setTimeout(k,b.delay);break}}).focus(function(){q++}).blur(function(){q=0;if(!x.mouseDownOnSelect){clearTimeout(h);h=setTimeout(n,200)}}).click(function(){q++>1&&!r.visible()&&k(0,true)}).bind("search",function(){function f(t,y){var A;if(y&&y.length)for(var w=0;w<y.length;w++)if(y[w].result.toLowerCase()==t.toLowerCase()){A=y[w];break}typeof p=="function"?
p(A):c.trigger("result",A&&[A.data,A.value])}var p=arguments.length>1?arguments[1]:null;a.each(s(c.val()),function(t,y){i(y,f,f)})}).bind("flushCache",function(){u.flush()}).bind("setOptions",function(f,p){a.extend(b,p);"data"in p&&u.populate()}).bind("unautocomplete",function(){r.unbind();c.unbind();a(d.form).unbind(".autocomplete")})};a.Autocompleter.defaults={inputClass:"ac_input",resultsClass:"ac_results",loadingClass:"ac_loading",minChars:1,delay:400,matchCase:false,matchSubset:true,matchContains:false,
cacheLength:10,max:100,mustMatch:false,extraParams:{},selectFirst:true,formatItem:function(d){return d[0]},formatMatch:null,autoFill:false,width:0,multiple:false,multipleSeparator:", ",highlight:function(d,b){return d.replace(RegExp("(?![^&;]+;)(?!<[^<>]*)("+b.replace(/([\^\$\(\)\[\]\{\}\*\.\+\?\|\\])/gi,"\\$1")+")(?![^<>]*>)(?![^&;]+;)","gi"),"<strong>$1</strong>")},scroll:true,scrollHeight:180};a.Autocompleter.Cache=function(d){function b(e,i){d.matchCase||(e=e.toLowerCase());var g=e.indexOf(i);
if(d.matchContains=="word")g=e.toLowerCase().search("\\b"+i.toLowerCase());if(g==-1)return false;return g==0||d.matchContains}function j(e,i){n>d.cacheLength&&s();m[e]||n++;m[e]=i}function k(){if(!d.data)return false;var e={},i=0;if(!d.url)d.cacheLength=1;e[""]=[];for(var g=0,c=d.data.length;g<c;g++){var h=d.data[g];h=typeof h=="string"?[h]:h;var o=d.formatMatch(h,g+1,d.data.length);if(o!==false){var u=o.charAt(0).toLowerCase();e[u]||(e[u]=[]);h={value:o,data:h,result:d.formatResult&&d.formatResult(h)||
o};e[u].push(h);i++<d.max&&e[""].push(h)}}a.each(e,function(q,l){d.cacheLength++;j(q,l)})}function s(){m={};n=0}var m={},n=0;setTimeout(k,25);return{flush:s,add:j,populate:k,load:function(e){if(!d.cacheLength||!n)return null;if(!d.url&&d.matchContains){var i=[];for(var g in m)if(g.length>0){var c=m[g];a.each(c,function(h,o){b(o.value,e)&&i.push(o)})}return i}else if(m[e])return m[e];else if(d.matchSubset)for(g=e.length-1;g>=d.minChars;g--)if(c=m[e.substr(0,g)]){i=[];a.each(c,function(h,o){if(b(o.value,
e))i[i.length]=o});return i}return null}}};a.Autocompleter.Select=function(d,b,j,k){function s(){if(o){u=a("<div/>").hide().addClass(d.resultsClass).css("position","absolute").appendTo(document.body);q=a("<ul/>").appendTo(u).mouseover(function(l){if(m(l).nodeName&&m(l).nodeName.toUpperCase()=="LI"){g=a("li",q).removeClass(e.ACTIVE).index(m(l));a(m(l)).addClass(e.ACTIVE)}}).click(function(l){a(m(l)).addClass(e.ACTIVE);j();b.focus();return false}).mousedown(function(){k.mouseDownOnSelect=true}).mouseup(function(){k.mouseDownOnSelect=
false});d.width>0&&u.css("width",d.width);o=false}}function m(l){for(l=l.target;l&&l.tagName!="LI";)l=l.parentNode;if(!l)return[];return l}function n(l){i.slice(g,g+1).removeClass(e.ACTIVE);g+=l;if(g<0)g=i.size()-1;else if(g>=i.size())g=0;l=i.slice(g,g+1).addClass(e.ACTIVE);if(d.scroll){var x=0;i.slice(0,g).each(function(){x+=this.offsetHeight});if(x+l[0].offsetHeight-q.scrollTop()>q[0].clientHeight)q.scrollTop(x+l[0].offsetHeight-q.innerHeight());else x<q.scrollTop()&&q.scrollTop(x)}}var e={ACTIVE:"ac_over"},
i,g=-1,c,h="",o=true,u,q;return{display:function(l,x){s();c=l;h=x;q.empty();for(var r=d.max&&d.max<c.length?d.max:c.length,z=0;z<r;z++)if(c[z]){var f=d.formatItem(c[z].data,z+1,r,c[z].value,h);if(f!==false){f=a("<li/>").html(d.highlight(f,h)).addClass(z%2==0?"ac_even":"ac_odd").appendTo(q)[0];a.data(f,"ac_data",c[z])}}i=q.find("li");if(d.selectFirst){i.slice(0,1).addClass(e.ACTIVE);g=0}a.fn.bgiframe&&q.bgiframe()},next:function(){n(1)},prev:function(){n(-1)},pageUp:function(){g!=0&&g-8<0?n(-g):n(-8)},
pageDown:function(){g!=i.size()-1&&g+8>i.size()?n(i.size()-1-g):n(8)},hide:function(){u&&u.hide();i&&i.removeClass(e.ACTIVE);g=-1},visible:function(){return u&&u.is(":visible")},current:function(){return this.visible()&&(i.filter("."+e.ACTIVE)[0]||d.selectFirst&&i[0])},show:function(){var l=a(b).offset();u.css({width:typeof d.width=="string"||d.width>0?d.width:a(b).width(),top:l.top+b.offsetHeight,left:l.left}).show();if(d.scroll){q.scrollTop(0);q.css({maxHeight:d.scrollHeight,overflow:"auto"});if(a.browser.msie&&
typeof document.body.style.maxHeight==="undefined"){var x=0;i.each(function(){x+=this.offsetHeight});l=x>d.scrollHeight;q.css("height",l?d.scrollHeight:x);l||i.width(q.width()-parseInt(i.css("padding-left"))-parseInt(i.css("padding-right")))}}},selected:function(){var l=i&&i.filter("."+e.ACTIVE).removeClass(e.ACTIVE);return l&&l.length&&a.data(l[0],"ac_data")},emptyList:function(){q&&q.empty()},unbind:function(){u&&u.remove()}}};a.fn.selection=function(d,b){if(d!==undefined)return this.each(function(){if(this.createTextRange){var n=
this.createTextRange();if(b===undefined||d==b)n.move("character",d);else{n.collapse(true);n.moveStart("character",d);n.moveEnd("character",b)}n.select()}else if(this.setSelectionRange)this.setSelectionRange(d,b);else if(this.selectionStart){this.selectionStart=d;this.selectionEnd=b}});var j=this[0];if(j.createTextRange){var k=document.selection.createRange(),s=j.value,m=k.text.length;k.text="<->";k=j.value.indexOf("<->");j.value=s;this.selection(k,k+m);return{start:k,end:k+m}}else if(j.selectionStart!==
undefined)return{start:j.selectionStart,end:j.selectionEnd}}})(jQuery);(function(a){function d(c){if(a.facebox.settings.inited)return true;else a.facebox.settings.inited=true;a(document).trigger("init.facebox");k();var h=a.facebox.settings.imageTypes.join("|");a.facebox.settings.imageTypesRegexp=RegExp("."+h+"$","i");c&&a.extend(a.facebox.settings,c);a("body").append(a.facebox.settings.faceboxHtml);var o=[new Image,new Image];a("#facebox").find(".b:first, .bl, .br, .tl, .tr").each(function(){o.push(new Image);o.slice(-1).src=a(this).css("background-image").replace(/url\((.+)\)/,
"$1")});a("#facebox .close").click(a.facebox.close)}function b(){var c,h;if(self.pageYOffset){h=self.pageYOffset;c=self.pageXOffset}else if(document.documentElement&&document.documentElement.scrollTop){h=document.documentElement.scrollTop;c=document.documentElement.scrollLeft}else if(document.body){h=document.body.scrollTop;c=document.body.scrollLeft}return Array(c,h)}function j(){var c;if(self.innerHeight)c=self.innerHeight;else if(document.documentElement&&document.documentElement.clientHeight)c=
document.documentElement.clientHeight;else if(document.body)c=document.body.clientHeight;return c}function k(){var c=a.facebox.settings;c.imageTypes=c.image_types||c.imageTypes;c.faceboxHtml=c.facebox_html||c.faceboxHtml}function s(c,h){if(c.match(/#/)){var o=window.location.href.split("#")[0];o=c.replace(o,"");a.facebox.reveal(a(o).clone().show(),h)}else c.match(a.facebox.settings.imageTypesRegexp)?m(c,h):n(c,h)}function m(c,h){var o=new Image;o.onload=function(){a.facebox.reveal('<div class="image"><img src="'+
o.src+'" /></div>',h)};o.src=c}function n(c,h){a.get(c,function(o){a.facebox.reveal(o,h)})}function e(){return a.facebox.settings.overlay==false||a.facebox.settings.opacity===null}function i(){if(!e()){a("facebox_overlay").length==0&&a("body").append('<div id="facebox_overlay" class="facebox_hide"></div>');a("#facebox_overlay").hide().addClass("facebox_overlayBG").css("opacity",a.facebox.settings.opacity).click(function(){a(document).trigger("close.facebox")}).fadeIn(200);return false}}function g(){if(!e()){a("#facebox_overlay").fadeOut(200,
function(){a("#facebox_overlay").removeClass("facebox_overlayBG");a("#facebox_overlay").addClass("facebox_hide");a("#facebox_overlay").remove()});return false}}a.facebox=function(c,h){a.facebox.loading();if(c.ajax)n(c.ajax);else if(c.image)m(c.image);else if(c.div)s(c.div);else a.isFunction(c)?c.call(a):a.facebox.reveal(c,h)};a.extend(a.facebox,{settings:{opacity:0.4,overlay:true,imageTypes:["png","jpg","jpeg","gif"],faceboxHtml:'    <div id="facebox" style="display:none;">       <div class="popup">         <div class="content">         </div>         <a href="javascript:;" class="close"></a>       </div>     </div>'},
loading:function(){d();if(a("#facebox .loading").length==1)return true;i();a("#facebox .content").empty();a("#facebox .body").children().hide().end().append('<div class="loading"></div>');a("#facebox").css({top:b()[1]+j()/10,left:385.5}).show();a(document).bind("keydown.facebox",function(c){c.keyCode==27&&a.facebox.close();return true});a(document).trigger("loading.facebox")},reveal:function(c,h){a(document).trigger("beforeReveal.facebox");h&&a("#facebox .content").addClass(h);a("#facebox .content").append(c);
a("#facebox .loading").remove();a("#facebox .body").children().fadeIn("normal");a("#facebox").css("left",a(window).width()/2-a("#facebox").width()/2);a(document).trigger("reveal.facebox").trigger("afterReveal.facebox")},close:function(){a(document).trigger("close.facebox");return false}});a.fn.facebox=function(c){d(c);return this.click(function(){a.facebox.loading(true);var h=this.rel.match(/facebox\[?\.(\w+)\]?/);if(h)h=h[1];s(this.href,h);return false})};a(document).bind("close.facebox",function(){a(document).unbind("keydown.facebox");
a("#facebox").fadeOut(function(){a("#facebox .content").removeClass().addClass("content");g();a("#facebox .loading").remove()})})})(jQuery);jQuery(document).ready(function(a){a("a[rel*=facebox]").facebox()});function show_fbox(a){if(jQuery("#facebox").length==0||jQuery("#facebox").css("display")=="none"){jQuery.facebox(a);jQuery("#facebox_overlay").unbind("click")}else{jQuery("#facebox .content").empty();jQuery.facebox.reveal(a)}}function close_fbox(){jQuery(document).trigger("close.facebox")};(function(a){function d(b,j){this.$element=a(b);this.options=j;this.enabled=true;this.fixTitle()}d.prototype={show:function(){var b=this.getTitle();if(b&&this.enabled){var j=this.tip();j.find(".tipsy-inner")[this.options.html?"html":"text"](b);j[0].className="tipsy";j.remove().css({top:0,left:0,visibility:"hidden",display:"block"}).appendTo(document.body);b=a.extend({},this.$element.offset(),{width:this.$element[0].offsetWidth,height:this.$element[0].offsetHeight});var k=j[0].offsetWidth,s=j[0].offsetHeight,
m=typeof this.options.gravity=="function"?this.options.gravity.call(this.$element[0]):this.options.gravity,n;switch(m.charAt(0)){case "n":n={top:b.top+b.height+this.options.offset,left:b.left+b.width/2-k/2};break;case "s":n={top:b.top-s-this.options.offset,left:b.left+b.width/2-k/2};break;case "e":n={top:b.top+b.height/2-s/2,left:b.left-k-this.options.offset};break;case "w":n={top:b.top+b.height/2-s/2,left:b.left+b.width+this.options.offset};break}if(m.length==2)n.left=m.charAt(1)=="w"?b.left+b.width/
2-15:b.left+b.width/2-k+15;j.css(n).addClass("tipsy-"+m);this.options.fade?j.stop().css({opacity:0,display:"block",visibility:"visible"}).animate({opacity:this.options.opacity}):j.css({visibility:"visible",opacity:this.options.opacity})}},hide:function(){this.options.fade?this.tip().stop().fadeOut(function(){a(this).remove()}):this.tip().remove()},fixTitle:function(){var b=this.$element;if(b.attr("title")||typeof b.attr("original-title")!="string")b.attr("original-title",b.attr("title")||"").removeAttr("title")},
getTitle:function(){var b,j=this.$element,k=this.options;this.fixTitle();k=this.options;if(typeof k.title=="string")b=j.attr(k.title=="title"?"original-title":k.title);else if(typeof k.title=="function")b=k.title.call(j[0]);return(b=(""+b).replace(/(^\s*|\s*$)/,""))||k.fallback},tip:function(){if(!this.$tip)this.$tip=a('<div class="tipsy"></div>').html('<div class="tipsy-arrow"></div><div class="tipsy-inner"></div>');return this.$tip},validate:function(){if(!this.$element[0].parentNode){this.hide();
this.options=this.$element=null}},enable:function(){this.enabled=true},disable:function(){this.enabled=false},toggleEnabled:function(){this.enabled=!this.enabled}};a.fn.tipsy=function(b){function j(e){var i=a.data(e,"tipsy");if(!i){i=new d(e,a.fn.tipsy.elementOptions(e,b));a.data(e,"tipsy",i)}return i}function k(){var e=j(this);e.hoverState="in";if(b.delayIn==0)e.show();else{e.fixTitle();setTimeout(function(){e.hoverState=="in"&&e.show()},b.delayIn)}}function s(){var e=j(this);e.hoverState="out";
b.delayOut==0?e.hide():setTimeout(function(){e.hoverState=="out"&&e.hide()},b.delayOut)}if(b===true)return this.data("tipsy");else if(typeof b=="string"){var m=this.data("tipsy");m&&m[b]();return this}b=a.extend({},a.fn.tipsy.defaults,b);b.live||this.each(function(){j(this)});if(b.trigger!="manual"){m=b.live?"live":"bind";var n=b.trigger=="hover"?"mouseleave":"blur";this[m](b.trigger=="hover"?"mouseenter":"focus",k)[m](n,s)}return this};a.fn.tipsy.defaults={delayIn:0,delayOut:0,fade:false,fallback:"",
gravity:"n",html:false,live:false,offset:0,opacity:0.8,title:"title",trigger:"hover"};a.fn.tipsy.elementOptions=function(b,j){return a.metadata?a.extend({},j,a(b).metadata()):j};a.fn.tipsy.autoNS=function(){return a(this).offset().top>a(document).scrollTop()+a(window).height()/2?"s":"n"};a.fn.tipsy.autoWE=function(){return a(this).offset().left>a(document).scrollLeft()+a(window).width()/2?"e":"w"}})(jQuery);
