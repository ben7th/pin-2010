pie.mindmap.doms = {
  
  shared_methods : {
    // 文字标题
    _build_title_elm : function(){      
      this.title_elm = jQuery('<div class="title"></div>')
        .css('color', this.textcolor)
        .html(this.title_html())
        
      if(null != this.image){
        this.title_elm.css('margin-left', this.image.width);
      }
      
      if(!this.is_note_blank()){
        this.title_elm.css('margin-right', 18);
      }
      
      return this.title_elm;
    },
    
    // 图片
    _build_image_elm : function(){
      if(null == this.image){
        this.image_elm = null;
        return null;
      }
      
      this.image_elm = jQuery('<a class="image" href="javascript:;" title="点击查看大图"><div class="box"></div></a>')
        .domdata('src', this.image.url)
        .domdata('attach-id', this.image.attach_id)
        .css({'width':this.image.width, 'height':this.image.height})

      pie.load_cut_img(this.image.url, this.image_elm, this.image_elm.find('.box'));
        
      return this.image_elm;
    },
    
    // 备注
    _build_note_elm : function(){
      if(this.is_note_blank()){
        this.note_elm = null;
        return null;
      }
      
      this.note_elm = jQuery('<a class="note" href="javascript:;" title="点击查看备注"></a>');
      
      return this.note_elm;
    },
    
    // canvas
    _build_canvas_elm : function(){
      this.canvas_elm = jQuery('<canvas style="display:none;"></canvas>');
      
      return this.canvas_elm;
    },
    
    recompute_box_size : function(){
      this.width  = this.elm.outerWidth();
      this.height = this.elm.outerHeight();
      
      if(null != this.image){
        var title_height = this.title_elm.height();
        if(title_height < this.image.height){
          this.title_elm.css('margin-top', (this.image.height - title_height)/2);
        }
      }
    }
  },
  
  root_methods : {
    _build_elm : function(){
      this._build_canvas_elm().prependTo(this.R.paper_elm);
      
      this.elm = jQuery('<div class="node root"></div>')
        .css('background-color', this.bgcolor)
        .domdata('id', this.id)
        .append(this._build_image_elm())
        .append(this._build_title_elm())
        .append(this._build_note_elm())
        .appendTo(this.R.paper_elm);
    }
  },
  
  node_methods : {
    _build_fd_elm : function(){
      this.fd_elm = jQuery('<div class="fd"></div>')
        .addClass(this.closed ? 'close':'open')
  
      if(0 == this.children.length){this.fd_elm.hide()}
      
      return this.fd_elm;
    },
    
    _build_elm : function(){
      this._build_canvas_elm().prependTo(this.R.paper_elm);
      
      this.elm = jQuery('<div class="node"></div>')
        .css('background-color', this.bgcolor)
        .domdata('id', this.id)
        .append(this._build_image_elm())
        .append(this._build_title_elm())
        .append(this._build_note_elm())
        .append(this._build_fd_elm())
        .appendTo(this.R.paper_elm);
    }
  },
  
  // 梳理json-object，给每个节点声明以下keys:
  // parent, root, prev_node, next_node
  init : function(R){
    var root = R.data;
    
    R.each_do(function(node){
      node._build_elm();
      node.recompute_box_size();
    });
  }
}