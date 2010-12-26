pie.drag.Cooprate = Class.create(pie.drag.Base,{
  onInit:function(){
    this.concat_li = this.el;
    this.ul = this.el.parentNode;

    this.ce_input = $('cooperate_editors');
    this.cv_input = $('cooperate_viewers');
  },
  beforeStart:function(){
    var dragproxy = this.__init_dragproxy();

    this.ul.appendChild(dragproxy);

    this.pos = {
      'ce':this._get_pos(this.ce_input),
      'cv':this._get_pos(this.cv_input)
    }

		this.ileft = parseInt(dragproxy.style.left||0);
		this.itop = parseInt(dragproxy.style.top||0);
  },
  onDragging:function(){
    var newLeft = this.ileft + this.distanceX;
    var newTop = this.itop + this.distanceY;
		this.dragproxy.setStyle({
			"top":newTop+"px",
			"left":newLeft+"px"
		});

    this._hover();

  },
  beforeFinish:function(){
    this._drop();
    
    this.dragproxy.remove();
    this.ce_input.removeClassName('hover');
    this.cv_input.removeClassName('hover');
    this.dropon = false;
  },

  __init_dragproxy:function(){
		if (!this.dragproxy) {
			this.dragproxy = $(Builder.node('li', {
				'class': 'concat',
				'style': "position:absolute;padding:4px;"
			}));
		}
    this.__set_drag_proxy_style();
    this.dragproxy.update($(this.concat_li).select('.data')[0].outerHTML);
    return this.dragproxy;
  },
  __set_drag_proxy_style:function(){
    var off1 = Element.cumulativeOffset(this.ul);
		this.dragproxy.setStyle({
      left:this.cX - off1.left - 30 +'px',
      top:this.cY - off1.top - 20 +'px',
			opacity:0.6,
			zIndex:103,
			display:''
		});
  },

  _get_pos:function(dom){
    var offset = Element.cumulativeOffset(dom);
    var dim = {
      height:Element.getHeight(dom),
      width:Element.getWidth(dom)
    }
    return {
      left:offset.left,
      top:offset.top,
      right:offset.left + dim.width,
      bottom:offset.top + dim.height
    };
  },
  _is_in:function(pos){
    var x = this.newX;
    var y = this.newY;
    return (pos.left<x) && (x<pos.right) && (pos.top<y) && (y<pos.bottom);
  },
  _hover:function(){
    this.ce_input.removeClassName('hover');
    this.cv_input.removeClassName('hover');
    this.dropon = false;
    
    if(this._is_in(this.pos.ce)){
      this.ce_input.addClassName('hover');
      this.dropon = this.ce_input;
    }
    
    if(this._is_in(this.pos.cv)){
      this.cv_input.addClassName('hover');
      this.dropon = this.cv_input;
    }
  },
  _drop:function(){
    if(this.dropon){
      var email = this.concat_li.select('.email')[0].innerHTML;
      var ces = this.ce_input.value;
      var cvs = this.cv_input.value;
      if(ces.include(email) || cvs.include(email)) return;
      var ds = this.dropon.value
      if(ds.toArray().last()!=',' && !ds.blank()){
        this.dropon.value += ','
      }
      this.dropon.value += email;
    }
  }
})


