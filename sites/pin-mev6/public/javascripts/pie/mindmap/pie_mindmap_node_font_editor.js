pie.mindmap.NodeFontEditor = Class.create({
	initialize: function(options){
    this.h = [];
    this.h[0] = "FF";
    this.h[1] = "CC";
    this.h[2] = "99";
    this.h[3] = "66";
    this.h[4] = "33";
    this.h[5] = "00";
	},
  doEditFont:function(node){

    this.get_cube();

    var fontsize = node.fontsize || 12;
    var fontcolor = node.fontcolor || '#000000';

    $('fontsize').value = fontsize;
    $('fontcolor').value = fontcolor;

    $("accept_font").observe("click",function(){
      var new_size = $('fontsize').value;
      var new_color = $('fontcolor').value;

      node.nodetitle.el.setStyle({
        'fontSize':new_size+'px',
        'color':new_color
      })
      node.fontsize = new_size;
      node.fontcolor = new_color;

      Lightview.hide();
    }.bind(this));

		Lightview.show({
		  href: '#fontselector',
		  title: '修改字体',
		  caption: '输入字体大小/颜色',
      width: '500px'
		});
  },
  get_cube: function(){// 创建颜色小方块
    if($('colorzone').innerHTML.blank()){

      for(var r=0; r<6; r++){
        var _ul = document.createElement("ul");
        for(var g=0; g<6; g++){
          for(var b=0; b<6; b++){
            var R = this.h[r];
            var G = this.h[g];
            var B = this.h[b];

            var _li = document.createElement("li");
            var _a = document.createElement("a");
            _a.style.background = "#"+ R + G + B;
            _li.title = "#"+ R + G + B;
            _li.appendChild(_a);
            _ul.appendChild(_li);
          };
        };
        $(_ul).observe("click", function(evt){
           var el = evt.element();
           var color = el.parentNode.title
           $('fontcolor').value = color;
        });
        $('colorzone').appendChild(_ul);
      };
    }
  }
});