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
    if (!node.closed) {
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
    if(node.sub.put_on_right()){
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
      if(node.sub.put_on_right()){
        hoff=pct.left+node.parent.canvas.left;
        left+=hoff;
        right+=hoff;
      }else{
        hoff=pct.right+node.container.width-node.parent.canvas.left;
        left+=hoff;
        right+=hoff;
      }
    }

    if(!node.sub.put_on_right()){
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
    try{
      var pm = pie.mindmap;
      var pr = node.sub.put_on_right();
      var is_up = node.branch.type == 0;

      var rbc;

      if(pr){
        rbc = is_up ? pm.RootBranchCanvasRUP : pm.RootBranchCanvasRDOWN;
      }else{
        rbc = is_up ? pm.RootBranchCanvasLUP : pm.RootBranchCanvasLDOWN;
      }
      
      new rbc(node,ctx).draw();
      
    }catch(e){alert(e)}
  }
}

pie.mindmap.RootBranchCanvasBase = Class.create({
  initialize:function(node,ctx){
    this.map = node.map;
    this.branch = node.branch;
    this.ctx = ctx;
    this.lw = 5;  //线最粗的地方的横向宽度
    this.p2 = Math.PI*2;
    this.rr = 2;  //一级子节点的连接点半径
    this.cr = this.map.cr;
    
    if(node.sub.put_on_right()){
      this.qcoff = this.branch.width/3;
    }else{
      this.qcoff = -this.branch.width/3;
    }
  },
  draw:function(){
    this._count_point();
    
    var ctx = this.ctx;
    ctx.beginPath();
    this._draw_connect_line(ctx);
    ctx.stroke();
    ctx.fill();
    
    ctx.beginPath();
    this._draw_arc(ctx);
    ctx.fill();
  },
  _draw_connect_line:function(ctx){
    ctx.moveTo(this.x1, this.y1);
    ctx.quadraticCurveTo(this.xn - this.qcoff, this.yn, this.xn, this.yn);
    ctx.quadraticCurveTo(this.xn - this.qcoff, this.yn, this.x2, this.y1);
  },
  _draw_arc:function(ctx){
    ctx.arc(this.xn, this.yn, this.rr, 0, this.p2, true);
  }
})

/**
 *                xnyn
 *             //
 *          /  /
 *       /    /
 *    /      /
 * x1y1-lw-x2y1
 */
pie.mindmap.RootBranchCanvasRUP=Class.create(pie.mindmap.RootBranchCanvasBase,{
  _count_point:function(){
    this.x1 = 0;
    this.x2 = this.lw;

    this.y1 = this.branch.height + this.cr;

    this.xn = this.branch.width - this.rr;
    this.yn = this.cr;
  }
});

/**
 * x1y1   x2y1
 *
 *
 *
 *
 *
 *                xnyn
 */
pie.mindmap.RootBranchCanvasRDOWN=Class.create(pie.mindmap.RootBranchCanvasBase,{
  _count_point:function(){
    this.x1 = 0;
    this.x2 = this.lw;

    this.y1 = this.cr;

    this.xn = this.branch.width - this.rr;
    this.yn = this.branch.height + this.cr;
  }
});

/**
 * xnyn
 *
 *
 *
 *
 *
 *         x2y1   x1y1
 */
pie.mindmap.RootBranchCanvasLUP=Class.create(pie.mindmap.RootBranchCanvasBase,{
  _count_point:function(){
    this.x1 = this.branch.width;
    this.x2 = this.branch.width - this.lw;

    this.y1 = this.branch.height + this.cr;

    this.xn = this.rr;
    this.yn = this.cr;
  }
});

pie.mindmap.RootBranchCanvasLDOWN=Class.create(pie.mindmap.RootBranchCanvasBase,{
  _count_point:function(){
    this.x1 = this.branch.width;
    this.x2 = this.branch.width - this.lw;

    this.y1 = this.cr;

    this.xn = this.rr;
    this.yn = this.branch.height + this.cr;
  }
});


