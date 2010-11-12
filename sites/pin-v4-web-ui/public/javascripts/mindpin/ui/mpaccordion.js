var MpAccordion = Class.create({
  initialize: function(togglers, elements, options){
    this.elements = $A(elements);
    this.togglers = $A(togglers);
    this.setOptions(options);
    
    this.togglers.each(function(toggler, i){
      if (toggler.onclick){
        toggler.prevClick = toggler.onclick;
      }else{
        toggler.prevClick = function(){};
      }
      $(toggler).onclick = function(){
        toggler.prevClick();
        this.show_or_hide(i);
      }.bind(this);
    }.bind(this));
    
  },
  setOptions:function(options){
    this.options = options || {}
    this.options = Object.extend({
      unfold_bgc:"#ff0000"
    },this.options)
  },
  show_or_hide:function(i){
    var el = this.elements[i]
    if (el.offsetHeight == el.scrollHeight){
      this.hide_el(i)
    }else if(el.offsetHeight == 0){
      this.show_el(i)
    }
  },
  show_el:function(i){
    var el = this.elements[i];
    var title = this.togglers[i];
    var height = el.scrollHeight;
    this.change_el_height(el, height);
    var unfold_bgc = title.getAttribute("data-active-bgc");
    this.change_title_color(title,unfold_bgc);
    title.addClassName("open").removeClassName("close");
  },
  hide_el:function(i){
    var el = this.elements[i];
    var title = this.togglers[i];
    this.change_el_height(el,0);
    this.change_title_color(title,title.getAttribute("data-bgc"));
    title.removeClassName("open").addClassName("close");
  },
  change_title_color:function(title,color){
    new Effect.Morph(title,{
      style: {backgroundColor:color},
      duration: 0.1
    });
  },
  change_el_height:function(el,height){
    new Effect.Morph(el, {
      style: {
        height:height + "px"
        },
      duration: 0.3
    });
  }
});
pie.load(function(){
  $$('.mpaccordion-bar').each(function(bar){
    var options = {}
    var toggles = bar.select(".mpaccordion-toggler")
    var contents = bar.select(".mpaccordion-content")
    new MpAccordion(toggles,contents,options)
  }.bind(this));
})
