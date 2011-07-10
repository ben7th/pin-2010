pie.mindmap_menu_module = {
  _createMenu:function(){
    try{
      this.nodeMenu=new pie.mindmap.Menu({
        observer : $(this.paper.jq[0]),
        afterload:function(){
          this.__scrollto(this.nodeMenu);
        }.bind(this)
      });

      this.nodeMenu.addItem("新增　　 [Ins]",{
        handler:function(){
          this.focus.createNewChild();
        }.bind(this)
      });

      this.nodeMenu.addItem("删除　　 [Del]",{
        handler:function(){
          this.focus.remove();
        }.bind(this),
        flag:function(){
          return this.focus!=this.root;
        }.bind(this)
      });

      this.nodeMenu.addItem("编辑标题 [空格]",{
        handler:function(){
          this.edit_focus_title();
        }.bind(this)
      })

      this.nodeMenu.addItem("节点图片 [I]",{handler:this.edit_focus_image.bind(this)});

      this.nodeMenu.addItem("移除图片",{
        handler:function(){
          this._node_image_editor.do_remove_image(this.focus);
        }.bind(this),
        flag:function(){
          return this.focus.image;
        }.bind(this)
      });

      this.nodeMenu.addItem("节点颜色",{handler:this.edit_focus_font.bind(this)});

      this.nodeMenu.addItem("编辑备注",{handler:this.edit_focus_note.bind(this)});
    
    }catch(e){alert(e)}
  }
}


