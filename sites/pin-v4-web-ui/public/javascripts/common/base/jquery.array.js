jQuery.extend({
  __arrayPrototype: {
    max:function(){
      return Math.max.apply(Math, this.arr);
    },
    max_index:function(){
      return jQuery.inArray(this.max(), this.arr);
    },
    min:function(){
      return Math.min.apply(Math, this.arr);
    },
    min_index:function(){
      return jQuery.inArray(this.min(), this.arr);
    }
  },
	array: function(arr) {
		if (arr === Array.prototype) { jQuery.extend(Array.prototype, jQuery.__arrayPrototype); }
		else { return jQuery.extend({ arr: arr }, jQuery.__arrayPrototype); }
	}
});

