pie.Hash = function(){
  this.items = {};
  this.size = 0;
  this.set = function(key, value){
    if(!this.contain(key)){ this.size++; } 
    this.items[key] = value;
  }
  this.get = function(key){
    return this.items[key] || null;
  }
  this.remove = function(key){
    if(this.contain(key)){ this.size--; }
    delete this.items[key];
  }
  this.contain = function(key){
    return null != this.get(key);
  },
  this.each = function(func){
    jQuery.each(this.items, function(k, v){
      func(v);
    })
  }
}