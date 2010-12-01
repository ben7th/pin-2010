if(typeof(Mindpin)=='undefined'){Mindpin={}};
Mindpin.Mindmap = {
  init: function(){
    this.get_mindmaps();
    var sidebar = getSidebarWindow();
    // 双击导图
    sidebar.$("#mindmap_list").dblclick(function(){
      Mindpin.Mindmap.open_item();
    })
    // 新建导图
    sidebar.$("#create_mindmap").click(function(){
    });
  },

  get_mindmaps: function(){
    var user_id = Mindpin.LoginManager.get_logined_user().id;
    var url = Mindpin.user_mindmaps_url(user_id);
    var sidebar = getSidebarWindow();
    sidebar.$.ajax({url:url,success:function(json){
      sidebar.Mindpin.Mindmap.TreeView.items = json.mindmaps;
      sidebar.Mindpin.Mindmap.TreeView.rowCount = json.mindmaps.length;
      sidebar.$("#mindmap_list")[0].view = sidebar.Mindpin.Mindmap.TreeView;
    }});
  },

  open_item : function(){
    try {
      var sidebar = getSidebarWindow();
      var tree = sidebar.$("#mindmap_list")[0];
      var row = tree.currentIndex;
      if (tree.view.rowCount <= 0) {
        return;
      }
      new_tab(Mindpin.edit_mindmap_url(sidebar.Mindpin.Mindmap.TreeView.items[row].id))
    } catch (e) {
    //ignore
    }
  },

  create_success: function(mindmap_id){
    new_tab(Mindpin.edit_mindmap_url(mindmap_id))
  }
};

Mindpin.Mindmap.TreeView = {
        items: [],
        rowCount : 0,
        getCellText : function(row,column){
            if (column.id == "mindmap_title") return this.items[row].title;
            if (column.id == "mindmap_created_at") return this.items[row].created_at;
            if (column.id == "mindmap_updated_at") return this.items[row].updated_at;
            return null;
        },
        getImageSrc : function(row, col) {return null;},
        setTree: function(treebox){
            this.treebox = treebox;
        },
        isContainer: function(row){
            return false;
        },
        isSeparator: function(row){
            return false;
        },
        isSorted: function(){
            return false;
        },
        getLevel: function(row){
            return 0;
        },
        getRowProperties: function(row,props){},
        getCellProperties: function(row,col,props){},
        getColumnProperties: function(colid,col,props){}
    };