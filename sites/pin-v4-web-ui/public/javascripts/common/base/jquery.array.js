jQuery.extend({
  __arrayPrototype: {
    max:function(){
      if(0 == this.arr.length) return null;
      return Math.max.apply(Math, this.arr);
    },
    max_index:function(){
      return jQuery.inArray(this.max(), this.arr);
    },
    min:function(){
      if(0 == this.arr.length) return null;
      return Math.min.apply(Math, this.arr);
    },
    min_index:function(){
      return jQuery.inArray(this.min(), this.arr);
    },
    
		select:function(func){
		  var re = [];
			jQuery.each(this.arr, function(index, item){
        if(func(item)) re.push(item);
			})
			return jQuery.array(re);
		},
		map:function(func){
		  var re = [];
		  jQuery.each(this.arr, function(index, item){
		    re.push(func(item));
		  })
		  return jQuery.array(re);
		},
		
		without:function(value){
		  return this.select(function(item){
        return value != item;
			})
		}
  },
	array: function(arr) {
		if (arr === Array.prototype) { jQuery.extend(Array.prototype, jQuery.__arrayPrototype); }
		else { return jQuery.extend({ arr: arr }, jQuery.__arrayPrototype); }
	}
});


