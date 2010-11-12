/* 历史记录和页面加载框架
 * ben7th 2010.1.26
 * http://www.mindpin.com
 * require:
 *  prototype
 *  rsh
 * */

window.dhtmlHistory.create({
  toJSON: function(o) {return Object.toJSON(o);},
  fromJSON: function(s) {return s.evalJSON();}
});

pie.history = {
  /* 在页面上维护一个 pie.history.hash 变量
   * 该变量用于记录当前页面的各部分内容（以url标识）
   **/
  hash:new Hash(),

  //历史记录是否已被第一次加载
  loaded:false,

  //加载计数器
  load_counter:new Hash(),
  _counter_change:function(key,change){
    var hash = this.load_counter.get(key)
    if(hash!=null){
      hash.set('count',hash.get('count') + change);
      return hash.get('count');
    }
  },

  //页面加载时被运行
  page_load:function() {
    dhtmlHistory.initialize();
    dhtmlHistory.addListener(this.historyListener.bind(this));
    this._1st_time_load(); //触发历史记录更新
  },

  _1st_time_load:function(){
    //确保不管以何种方式加载页面（刷新或直接载入）都会执行且只执行一次历史记录的加载
    if(!this.loaded){
      dhtmlHistory.fireHistoryEvent(dhtmlHistory.currentLocation)
    }
  },

  historyListener:function(new_location) {
    this.loaded = true;
    // 根据 new_location 变量 计算新的 pie.history.hash 的值
    // 比较新值 和原来的值的差异 根据这个差异 来确定页面应该产生什么样的加载请求
    // 新增的 url，在相应的position加载
    // 减少的 url，关闭相应position的cell
    // position变化的 url，目前暂且先不处理 —— 1月26日

    if(new_location.blank()){
      // 加载首页
      this._load(this.index_hash,{change_history:false});
      this.hash = new Hash();
    }else{
      // 非首页
      //计算新的page_hash
      var new_hash = this.urls_str_to_hash(new_location);
      this._load(new_hash,{close_cell:true});
      //覆盖hash
      this.hash = new_hash;
    }
  },
  
  _load:function(new_hash,options){
    var old_hash = this.hash;
    new_hash = $H(new_hash);
    options = options||{};

    this.index_hash = this.index_hash || new Hash();

    //生成加载计数器
    var counter_key = Math.random();
    this.load_counter.set(counter_key,$H({'hash':new_hash,'count':0}));

    //遍历cells中各部分，对照new_hash加载该加载的，关闭该关闭的
    this.cells.each(function(cell_name){
      var old_url = encodeURI(old_hash.get(cell_name) || '')
      var new_url = new_hash.get(cell_name) || '';

      if((new_url != old_url) || options.force_load){
        if(new_url.blank()){
          if(this.index_hash.get(cell_name)!='$KEEP' && options.close_cell) pie.cell._close_cell(cell_name);
        }else{
          if(new_url == '$KEEP') return;
          this._counter_change(counter_key,+1)
          this._ajax_load(cell_name, new_url, options.change_history, counter_key);
        }
      }
    }.bind(this))
  },

  _ajax_load:function(position,url,change_history,counter_key){
    var history = pie.history;

    new Ajax.Request(url,{
      method:'get',
      parameters:{'PL':position},
      onCreate:function(){
      },
      onSuccess:function(){
        //根据有无 counter_key 分两种情况
        if(change_history!=false){
          if(counter_key){
            if(history._counter_change(counter_key,-1) == 0){
              var history_hash = history.load_counter.get(counter_key).get('hash')
              history.merge_hash(history_hash);
            }
          }else{
            pie.history.merge(position,url);
          }
        }
        setTimeout(pie.cell.refresh_page_selectors,1);
      },
      onFailure:function(){
      }
    })
  },

  urls_str_to_hash:function(str){
    try{
      var arr1 = str.split(',')
      var hash = new Hash();
      arr1.each(function(x){
        if(x.blank()) return;
        var ax = x.split(':');
        hash.set(ax[0],ax[1])
      })
      return hash;
    }catch(e){alert(e)}
  },

  hash_to_location_str:function(hash){
    return hash.map(function(kv){
      return kv.key + ":" + kv.value
    }).join(',');
  },

  merge:function(key,value){
    var hash = this._merge(key,value)
    dhtmlHistory.add(this.hash_to_location_str(hash))
  },

  merge_hash:function(new_hash){
    var hash = {}
    new_hash.each(function(h){
      hash = this._merge(h.key,h.value)
    }.bind(this));
    dhtmlHistory.add(this.hash_to_location_str(hash))
  },

  _merge:function(key,value){
    var hash = this.hash;
    value = value.gsub(/http:\/\/([^\/]*)\//,'/'); // bug fix
    hash.set(key,value);
    return hash;
  },

  remove:function(key){
    var hash = this.hash;
    hash.unset(key)
    if(window.location.href.include('#')){
      dhtmlHistory.add(this.hash_to_location_str(hash))
    }
  }
}

//页面加载时，运行page_load方法，载入历史记录
pie.load(function(){
  pie.history.page_load();
});