ImageBox = Class.create({
  initialize: function (box){
    this.box = box;
    this.btns = box.select("a.btn");
    this.items = box.select("div.item");
    this.btns.each(function(a){
      a.observe("click",function(evt){
        this.show_image(a)
      }.bind(this));
    }.bind(this));
  },
  show_image: function(a){
    this.items.each(function(i){
      i.addClassName("hide")
    });
    this.items[this.btns.indexOf(a)].removeClassName("hide")
  }
});