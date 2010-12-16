pie.mindmap_canvas_draw_module = {
  connect:{},
  _connectWithDiv: function(){
  },

  _drawOnCanvas:function(sub){
    sub.canvas.el = $(sub.canvas.id);
    var ctx = sub.canvas.el.getContext('2d');
    ctx.strokeStyle = this.lineColor;
    //ctx.clearRect(0, 0, sub.canvas.width, sub.canvas.height);
    this._connectWithCanvas_recursion(sub,ctx);
  },
  _connectWithCanvas_recursion: function(node,ctx){
    var pos = this.__getNodePosition(node);
    ctx.beginPath();
    ctx.moveTo(pos.left, pos.bottom);
    ctx.lineTo(pos.right, pos.bottom);
    ctx.stroke();
    if (node.fold != 1) {
      node.children.each(function(child){
        this._connectWithCanvas_recursion(child, ctx);
        ctx.beginPath();
        ctx.moveTo(pos.right, pos.bottom);
        ctx.bezierCurveTo(pos.right, pos.bottom, pos.right, child.canvas.bottom, child.canvas.left, child.canvas.bottom);
        ctx.stroke();
      }.bind(this));
    }
  },
  __getNodePosition: function(node){
    var top = node.top.round();
    var bottom = top + node.height;
    var left,right;
    if(node.sub.putright){
      left = node.left;
      right = left + node.width + this.fw/2;
    }else{
      left = node.right;
      right = left + node.width + this.fw/2;
    }
    if(node.sub!=node){
      var pct=node.parent.content;
      var voff=node.container.top+node.parent.canvas.top-(node.parent.top-pct.top).round();
      top+=voff;
      bottom+=voff;
      var hoff;
      if(node.sub.putright){
        hoff=pct.left+node.parent.canvas.left;
        left+=hoff;
        right+=hoff;
      }else{
        hoff=pct.right+node.container.width-node.parent.canvas.left;
        left+=hoff;
        right+=hoff;
      }
    }

    if(!node.sub.putright){
      left=node.container.width-left;
      right=node.container.width-right;
    }

    node.canvas.top = top;
    node.canvas.bottom = bottom;
    node.canvas.left = left;
    node.canvas.right = right;

    return {
      "top": top,
      "right": right,
      "bottom": bottom,
      "left": left
    };
  },

  _drawOnBranch:function(sub){
    if(sub.free) return;
    sub.branch.el=$(sub.branch.id);
    var ctx = sub.branch.el.getContext('2d');
    ctx.fillStyle=this.lineColor;
    ctx.strokeStyle=this.lineColor;
    //ctx.clearRect(0, 0, sub.branch.width, sub.branch.height);
    this._connect_root_with_canvas(sub,ctx);
  },
  _connect_root_with_canvas:function(node,ctx){
    if(node.sub.putright){
      if (node.branch.type == 0) {
        new pie.mindmap.RootBranchCanvasR0(node,ctx).draw();
      }else{
        new pie.mindmap.RootBranchCanvasR1(node,ctx).draw();
      }
    }else{
      if (node.branch.type == 0) {
        new pie.mindmap.RootBranchCanvasL0(node,ctx).draw();
      }else{
        new pie.mindmap.RootBranchCanvasL1(node,ctx).draw();
      }
    }
  }
}

pie.mindmap.RootBranchCanvasBase = Class.create({
  initialize:function(node,ctx){
    this.node = node;
    this.map = node.root.map;
    this.branch = node.branch;
    this.ctx = ctx;
    this.line_weight = 2;
  },
  draw:function(){
    var ctx = this.ctx;
    ctx.beginPath();
    this._draw_connect_line();
    ctx.stroke();
    ctx.fill();
    ctx.beginPath();
    this._draw_arc();

    ctx.fill();
  }
  //_draw_connect_line:function(){},
  //_draw_arc:function(){}
})

pie.mindmap.RootBranchCanvasR0=Class.create(pie.mindmap.RootBranchCanvasBase,{
  _draw_connect_line:function(){
    var ctx = this.ctx;
    var branch = this.branch;
    var map = this.map;
    var lw = this.line_weight;

    ctx.moveTo(0, branch.height + map.cr - lw);
    ctx.lineTo(branch.width - map.rr, map.cr);
    ctx.lineTo(lw, branch.height + map.cr);
  },
  _draw_arc:function(){
    var ctx = this.ctx;
    var branch = this.branch;
    var map = this.map;
    
    ctx.arc(branch.width - map.rr, 0 + map.cr, map.rr, 0, Math.PI * 2, true);
  }
});

pie.mindmap.RootBranchCanvasR1=Class.create(pie.mindmap.RootBranchCanvasBase,{
  _draw_connect_line:function(){
    var ctx = this.ctx;
    var branch = this.branch;
    var map = this.map;
    var lw = this.line_weight;

    ctx.moveTo(0, map.cr + lw);
    ctx.lineTo(branch.width - map.rr, branch.height + map.cr);
    ctx.lineTo(lw, map.cr);
  },
  _draw_arc:function(){
    var ctx = this.ctx;
    var branch = this.branch;
    var map = this.map;
    
    ctx.arc(branch.width - map.rr, branch.height + map.cr, map.rr, 0, Math.PI * 2, true);
  }
});

pie.mindmap.RootBranchCanvasL0=Class.create(pie.mindmap.RootBranchCanvasBase,{
  _draw_connect_line:function(){
    var ctx = this.ctx;
    var branch = this.branch;
    var map = this.map;
    var lw = this.line_weight;

    ctx.moveTo(branch.width, branch.height + map.cr - lw);
    ctx.lineTo(0 + map.rr, map.cr);
    ctx.lineTo(branch.width - lw, branch.height + map.cr);
  },
  _draw_arc:function(){
    var ctx = this.ctx;
    var branch = this.branch;
    var map = this.map;

    ctx.arc(0 + map.rr, 0 + map.cr, map.rr, 0, Math.PI * 2, true);
  }
});

pie.mindmap.RootBranchCanvasL1=Class.create(pie.mindmap.RootBranchCanvasBase,{
  _draw_connect_line:function(){
    var ctx = this.ctx;
    var branch = this.branch;
    var map = this.map;
    var lw = this.line_weight;

    ctx.moveTo(branch.width, map.cr + lw);
    ctx.lineTo(0 + map.rr, branch.height + map.cr);
    ctx.lineTo(branch.width - lw, map.cr);
  },
  _draw_arc:function(){
    var ctx = this.ctx;
    var branch = this.branch;
    var map = this.map;

    ctx.arc(0 + map.rr, branch.height + map.cr, map.rr, 0, Math.PI * 2, true);
  }
});


