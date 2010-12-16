pie.mindmap.JSONLoader = Class.create({
  initialize: function(options){
    options = options || {};

    this.url = options.url;

    //运行时参数
    this.json = {};
  },
  request:function(callback){
    new Ajax.Request(this.url+".js",{
      method:"get",
      onSuccess:callback.bind(this)
    })
  },
  load:function(){
    //show loading animate...

    //加载
    this.request(function(trans){
      var json=trans.responseText.evalJSON();
      //json以嵌套形式返回，将来需要改成数组形式
      this.mindmap.root = new pie.mindmap.Node(json,this.mindmap);
      this.mindmap._load();
    }.bind(this));
  }
});