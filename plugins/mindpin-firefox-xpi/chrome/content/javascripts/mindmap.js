if(typeof(Mindpin)=='undefined'){Mindpin={}};
Mindpin.Mindmap = {
  init: function(){
    this.get_mindmaps();
    var sidebar = getSidebarWindow();
    // 双击导图
    sidebar.$("#mindmap_list").dblclick(function(){
      Mindpin.Mindmap.open_item();
    })
    // 导入导图表单相关事件
    this.import_mindmap_form_event();
  },

  // 导入导图表单相关事件
  import_mindmap_form_event : function(){
    if(this.import_mindmap_form_event_load) return;

    this.import_mindmap_form_event_load = true;
    
    var sidebar = getSidebarWindow();
    // 导入导图
    sidebar.$("#import_mindmap_btn").click(function(){
      sidebar.$("#mindmap_deck")[0].selectedIndex = 1;
    });
    // 导入导图文件
    sidebar.$("#select_mindmap_file").click(function(){
      var nsIFilePicker = Components.interfaces.nsIFilePicker;
       //创建组件
      var fp = Components.classes["@mozilla.org/filepicker;1"]
          .createInstance(nsIFilePicker);
      //初始化组件, 选择打开单个文件
      fp.init(window, "选择导图文件", nsIFilePicker.modeOpen);
      //添加文件过滤器
      fp.appendFilter("导图文件(*.mmap)","*.mmap");
      //显示对话框
      var rv = fp.show();
      // 选择了文件
      if(rv==nsIFilePicker.returnOK || rv==nsIFilePicker.returnReplace){
        sidebar.$("#import_mindmap_file")[0].value = fp.file.path;
      }
    })
    // 开始导入导图文件
    sidebar.$("#start_import_mindmap").click(function(){
      var title = sidebar.$("#import_mindmap_title")[0].value;
      if(!title){
        alert(title)
        return alert("标题不能为空")
      }
      var file_path = sidebar.$("#import_mindmap_file")[0].value;
      var extension_name = /\.([^\.]*)$/.exec(file_path)[1]
      var import_file_base64 = sidebar.Mindpin.Mindmap.get_base64_from_file_path(file_path);

      sidebar.$.ajax({url:Mindpin.IMPORT_MINDMAP_URL,type:"POST",
        data:{title:title,import_file_base64:import_file_base64,type:extension_name},
        success:function(mindmap){
          sidebar.Mindpin.Mindmap.import_mindmap_form_reset();
          sidebar.Mindpin.Mindmap.TreeView.items.unshift(mindmap);
          sidebar.Mindpin.Mindmap.show_treeview_items_to_tree();

          sidebar.$("#mindmap_deck")[0].selectedIndex = 0;
          sidebar.new_tab(Mindpin.edit_mindmap_url(mindmap.id))
        }
      })
    });
    // 取消导入导图
    sidebar.$("#cancel_import_btn").click(function(){
      sidebar.Mindpin.Mindmap.import_mindmap_form_reset();
      sidebar.$("#mindmap_deck")[0].selectedIndex = 0;
    });
  },

  // 重置导入导图表单
  import_mindmap_form_reset : function(){
    var sidebar = getSidebarWindow();
    sidebar.$("#import_mindmap_file")[0].value = ""
    sidebar.$("#import_mindmap_title")[0].value = ""
  },

  // 根据文件路径，用 base64 编码 文件的数据
  get_base64_from_file_path : function(path){
    var file = Components.classes["@mozilla.org/file/local;1"]
		.createInstance(Components.interfaces.nsILocalFile);
	file.initWithPath( path );
	stream = Components.classes["@mozilla.org/network/file-input-stream;1"]
		.createInstance(Components.interfaces.nsIFileInputStream);
	stream.init(file,	0x01, 00004, null);

    var bstream = Components.classes["@mozilla.org/binaryinputstream;1"] .createInstance(Components.interfaces.nsIBinaryInputStream);
    bstream.setInputStream(stream);

      var size = 0;
      var file_data = "";
      while(size = bstream.available()) {
        file_data += bstream.readBytes(size);
      }

     return window.btoa(file_data);
  },

  get_mindmaps: function(){
    var user_id = Mindpin.LoginManager.get_logined_user().id;
    var url = Mindpin.user_mindmaps_url(user_id);
    var sidebar = getSidebarWindow();
    sidebar.$.ajax({url:url,success:function(json){
      sidebar.Mindpin.Mindmap.TreeView.items = json.mindmaps;
      sidebar.Mindpin.Mindmap.show_treeview_items_to_tree();
    }});
  },

  // 把缓存里的导图数据 显示在 导图列表里
  show_treeview_items_to_tree: function(){
    var sidebar = getSidebarWindow();
    sidebar.Mindpin.Mindmap.TreeView.rowCount = sidebar.Mindpin.Mindmap.TreeView.items.length;
    sidebar.$("#mindmap_list")[0].view = sidebar.Mindpin.Mindmap.TreeView;
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